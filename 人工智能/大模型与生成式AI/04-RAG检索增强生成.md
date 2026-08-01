# RAG 检索增强生成

> 大模型的知识固定在训练时刻，且会幻觉。**RAG（Retrieval-Augmented Generation，检索增强生成）**在生成前先"查资料"：从外部知识库检索相关文本，注入 prompt，让模型基于事实作答。它是当前企业知识问答、私有数据应用的**事实标准**。

## 1. RAG 的动机

### 1.1 三个痛点

| 痛点 | 表现 | RAG 的解法 |
|------|------|-----------|
| 知识截止 | 不知道训练后的新事件 | 检索最新文档 |
| 私有数据 | 企业内部数据不在训练集 | 检索企业内部知识库 |
| 幻觉 | 编造不存在的细节 | 提供原文作为依据 |

### 1.2 为什么不用微调解决

- RAG 是**即插即用**的：知识变了，只需更新索引，不用重训；
- 微调"记知识"成本高且易遗忘（见 [[03-微调|微调]]），RAG 按需取用；
- 工程上两者互补：**RAG 管事实，微调管风格/格式**。

## 2. 架构与流程

### 2.1 两大组件

$$
\text{RAG} = \underbrace{\text{Retriever}(\text{检索器})}_{\text{找相关文档}} + \underbrace{\text{Generator}(\text{生成器})}_{\text{LLM 基于文档作答}}
$$

### 2.2 完整流水线

```
离线（建立索引）                    在线（问答）
─────────────                      ────────────
文档 → 切分(chunking)              用户问题
   → 向量化(embedding)        ┌──► 向量化(query embedding)
   → 存入向量库 ──────────────►│──► 检索 top-k
                                │──► (重排序 rerank)
                                │──► 注入 prompt 模板
                                └──► LLM 生成答案（附引用）
```

在线问答的形式化描述：

$$
P(a \mid q) = \sum_{d \in \mathcal{D}} P(a \mid q, d) \cdot P(d \mid q)
$$

实际实现中近似：先取最相关 $k$ 篇文档 $d_1..d_k$，再让 LLM 在给定上下文中生成答案。

## 3. 嵌入（Embedding）与向量检索

### 3.1 Embedding 模型

把文本映射为向量，使**语义相近 → 向量相近**。与 [[../深度学习教程/12-Transformer与大模型|Transformer]] 中的 token embedding 不同，这里用专门的 sentence/retrieval embedding 模型（如 `bge-large-zh`、`text-embedding-3`、`gte`）。

### 3.2 相似度：余弦相似度

$$
\text{sim}(\mathbf{q}, \mathbf{d}) = \frac{\mathbf{q} \cdot \mathbf{d}}{\|\mathbf{q}\|_2 \, \|\mathbf{d}\|_2} = \cos\theta
$$

为什么不用欧氏距离：文本向量常用归一化后余弦相似度更稳定，且不随向量长度变化。

### 3.3 向量数据库

| 库 | 类型 | 特点 | 适用 |
|----|------|------|------|
| FAISS | 库（不常驻服务） | Meta 出品，ANN 检索快 | 单机/原型 |
| Chroma | 嵌入式库 | 简单、自带持久化 | 小项目、原型 |
| Milvus | 分布式向量数据库 | 大规模、云原生、支持过滤 | 生产大规模 |
| Qdrant | 向量数据库 | Rust 实现，支持过滤/重排 | 生产 |
| pgvector | PostgreSQL 扩展 | 与关系库共存 | 已有 PG 的场景 |

**ANN（近似最近邻）**：精确 KNN 是 $O(n)$ 扫描，大规模用倒排索引（IVF）或 HNSW 图近似，召回率与速度权衡。

## 4. 检索质量的关键：Chunking 与过滤

### 4.1 Chunking 策略

| 策略 | 做法 | 优点 | 缺点 |
|------|------|------|------|
| 固定长度 | 按 token/字符切 | 简单 | 切断语义 |
| 句/段落切 | 按标点/空行 | 语义完整 | 长度不均 |
| 滑动窗口 | 重叠切片 | 保留上下文 | 冗余 |
| 递归切分 | 按结构逐级切 | 平衡长度与语义 | 参数多 |
| 语义切分 | 向量相似度决定切点 | 语义最优 | 计算贵 |

**经验规则**：
- 每块 200–800 token（中文约 300–1000 字）为宜；
- 相邻块**重叠 10–20%** 避免切断信息；
- 按文档结构（标题/段落）切分通常优于纯固定长度。

### 4.2 元数据过滤

为每块附元数据（来源、日期、部门、权限、章节），先按元数据过滤再向量检索，双保险：

```
SELECT top_k(*) FROM chunks
WHERE source = '法律文件' AND year >= 2023
ORDER BY embedding <-> $query   -- 向量相似度
LIMIT 5;
```

### 4.3 混合检索（Hybrid Search）

**BM25（词法）** 捕捉精确关键词（专有名词、型号、公式）；**向量（语义）** 捕捉同义改写。二者互补：

| 场景 | BM25 | 向量检索 |
|------|------|----------|
| 专有名词（"RWKV-5"） | 准 | 可能被同义干扰 |
| 同义改写（"汽车"/"轿车"） | 漏 | 准 |
| 拼写变体 | 差 | 好 |

**融合（Reciprocal Rank Fusion, RRF）**：

$$
\text{RRF}(d) = \sum_{r \in R} \frac{1}{k + \text{rank}_r(d)}
$$

把两个榜单的排名融合为分数，$k$ 常取 60。

### 4.4 重排序（Reranker）

第一轮粗召回（如 top 50）后，用一个**交叉编码器（cross-encoder）**精排为 top 5。交叉编码器把"问题+文档"拼一起过 Transformer 打分，精度高但慢，只对候选子集做：

```
阶段1 双编码器（Bi-encoder）粗召回 50 条  ← 快、可预计算向量
阶段2 交叉编码器（Cross-encoder）精排 5 条 ← 慢、只对候选做
```

## 5. RAG 的演进路线

### 5.1 Naive RAG

最简实现（上文 2.2 流程）：切块 → 向量化 → 检索 → 生成。局限：检索质量差、幻觉仍在、无法回答需要多文档推理的问题。

### 5.2 Advanced RAG

对查询与检索做工程优化：

- **Query 改写**：澄清、改写、分解多跳问题（`多跳 → 子问题列表`）；
- **多路召回**：向量 + BM25 + 元数据过滤同时召回再融合；
- **重排序**：交叉编码器精排；
- **上下文压缩**：把过长 chunk 压缩到只保留相关句子；
- **自查询（Self-Query）**：LLM 先生成结构化的检索条件（关键词 + 元数据过滤）再检索。

### 5.3 Modular RAG / GraphRAG

组件模块化组合，并可叠加**知识图谱**（链接 [[../经典AI教程/02-知识图谱|知识图谱]]）：

- **GraphRAG**（微软）：先用 LLM 从文档抽取实体与关系构建图，再对子图做社区摘要，适合**全局性、跨文档**问题（如"整个语料讲了哪些主题"）；
- **Agentic RAG**：由 [[06-AI智能体|Agent]] 决定"查什么、查几次、要不要追问"，可处理复杂多步问题；
- **自我反思 RAG（Self-RAG）**：让模型自评"检索到的内容够不够、答案是否被支持"，必要时重检索。

### 5.4 演进对比

| 类型 | 检索方式 | 适合问题 | 复杂度 |
|------|----------|----------|--------|
| Naive RAG | 单路向量 | 事实型单文档 | 低 |
| Advanced RAG | 改写+多路+重排 | 事实型、较精确 | 中 |
| GraphRAG | 图谱+社区摘要 | 全局/跨文档 | 高 |
| Agentic RAG | Agent 决策检索 | 复杂多步 | 高 |

## 6. 评估 RAG 系统

### 6.1 三个核心指标

1. **检索命中率（Recall@k）**：答案来源是否在 top-k 中 —— 检索器质量；
2. **忠实度（Faithfulness）**：答案是否**完全可由检索到的文档支持**（无幻觉）—— 生成器质量；
3. **答案相关性（Answer Relevance）**：答案是否真正回答了问题—— 端到端质量。

**忠实度**计算思路：用 LLM 判断答案中的每个断言是否在上下文中被支持：

$$
\text{Faithfulness} = \frac{\#\{\text{被支持的断言}\}}{\#\{\text{全部断言}\}}
$$

### 6.2 评估工具

- **RAGAS**：自动化评测 faithfulness / relevance / context precision；
- **LangSmith / 自定义 eval 集**：人工 golden 样本 + 自动打分器。

### 6.3 常见失败模式

| 失败模式 | 原因 | 对策 |
|----------|------|------|
| 检索不到 | chunk 过大/过小、embedding 不匹配 | 调 chunk、换 embedding |
| 检索到错的 | 相似但不相关 | 重排、元数据过滤 |
| 答案仍幻觉 | prompt 未约束 | 要求"仅在上下文中找答案，找不到就说不知道" |
| 多跳问题崩 | 单次检索不够 | Query 分解、Agentic RAG |

## 7. 与传统知识图谱 / 专家系统的对比

| 维度 | 专家系统/知识图谱 | RAG |
|------|-------------------|-----|
| 知识表示 | 结构化（规则、三元组、本体） | 非结构化文本向量 |
| 构建成本 | 高（人工整理、本体工程） | 低（自动切块嵌入） |
| 推理 | 规则精确、可解释 | 概率生成、可能幻觉 |
| 覆盖范围 | 窄但准 | 广但浅 |
| 查询能力 | SPARQL 精确查询 | 语义检索，灵活 |
| 维护 | 改规则要人工 | 加文档即可 |
| 互补 | 提供事实约束与精确关系 | 提供灵活理解与生成 |

> 两者正在融合：**GraphRAG** 用 LLM 自动构建图、用图增强检索；**知识图谱**为 RAG 提供实体关系和精确查询能力。关系型知识优先图谱，非结构文本优先 RAG。

## 8. Python 实战：完整 RAG 示例

用 `langchain` + `chromadb` + 本地 embedding 与 LLM，构建一个从 PDF/文本建索引到问答的完整系统。

```bash
pip install langchain langchain-community chromadb sentence-transformers
```

### 8.1 加载文档并切分

```python
from langchain_community.document_loaders import TextLoader, PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter

# 支持 .txt / .pdf 等
loader = TextLoader("knowledge.txt", encoding="utf-8")
docs = loader.load()

splitter = RecursiveCharacterTextSplitter(
    chunk_size=500,
    chunk_overlap=80,
    separators=["\n\n", "\n", "。", "！", "？", " ", ""],
)
chunks = splitter.split_documents(docs)
print(f"切分出 {len(chunks)} 个片段")
```

### 8.2 向量化并建索引

```python
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import Chroma

# 本地 embedding 模型（中文效果好）
embeddings = HuggingFaceEmbeddings(
    model_name="BAAI/bge-small-zh-v1.5"
)

vectorstore = Chroma.from_documents(
    documents=chunks,
    embedding=embeddings,
    persist_directory="./chroma_db",
)
# 生产可换 Milvus: Milvus.from_documents(...)
```

### 8.3 检索 + 注入 prompt + 生成

```python
from langchain_community.chat_models import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

# 1) 检索器：向量检索 + MMR/重排
retriever = vectorstore.as_retriever(search_kwargs={"k": 4})

# 2) Prompt 模板：限定只能基于上下文
template = """你是知识库问答助手。仅根据以下"上下文"回答问题；
如果上下文没有相关内容，请回答"知识库中没有找到相关信息"。

上下文：
{context}

问题：{question}
回答："""

prompt = ChatPromptTemplate.from_template(template)

# 3) LLM（本地 vLLM / Ollama 也兼容）
llm = ChatOpenAI(
    model="Qwen/Qwen2.5-7B-Instruct",
    base_url="http://localhost:8000/v1",
    api_key="sk-xxx",
)

# 4) 组装 RAG 链
def format_docs(docs):
    return "\n\n".join(d.page_content for d in docs)

rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

# 5) 问答
question = "知识库中提到了哪些大模型压缩方法？"
print(rag_chain.invoke(question))
```

### 8.4 混合检索 + 重排序（进阶）

```python
from langchain_community.retrievers import BM25Retriever
from langchain.retrievers.ensemble import EnsembleRetriever

bm25 = BM25Retriever.from_documents(chunks, k=4)
vector_retriever = vectorstore.as_retriever(search_kwargs={"k": 4})

# 权重融合（含 RRF 思想）
hybrid = EnsembleRetriever(
    retrievers=[vector_retriever, bm25],
    weights=[0.6, 0.4],
)

# 用交叉编码器重排
from sentence_transformers import CrossEncoder
reranker = CrossEncoder("BAAI/bge-reranker-base")

docs = hybrid.invoke(question)                      # 粗召回 8 条
pairs = [(question, d.page_content) for d in docs]
scores = reranker.predict(pairs)                    # 精排打分
top = [d for _, d in sorted(zip(scores, docs), key=lambda t: t[0], reverse=True)[:3]]
```

## 9. 生产级 RAG 清单

1. 建立 **golden 评估集**（问题 + 期望答案来源），上线前先测；
2. chunk 大小、embedding、k 值、重排都做 **A/B**；
3. 监控：检索命中率、忠实度、端到端相关性的线上抽样；
4. 权限与过滤：元数据隔离多租户数据；
5. 引用溯源：让 LLM 输出 `[来源1][来源2]`，对应到原文；
6. 缓存高频问题，降低延迟与成本。

## 相关笔记

- [[../经典AI教程/02-知识图谱|知识图谱]] — 结构化知识的另一种组织方式
- [[02-提示工程|提示工程]] — 注入上下文的 Prompt 设计
- [[01-大语言模型原理|大语言模型原理]] — 幻觉的根源
- [[06-AI智能体|AI 智能体]] — Agentic RAG 与工具调用
- [[03-微调|微调]] — 与 RAG 互补的另类适配
- [[../机器学习教程/01-模型评估与交叉验证|模型评估]] — 评估方法论
- [[../人工智能|人工智能索引]] — 全局索引
