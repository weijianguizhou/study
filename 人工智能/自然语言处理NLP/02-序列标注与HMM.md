# 序列标注与 HMM

> 序列标注（Sequence Labeling）是 NLP 的"骨架任务"：分词、词性标注（POS）、命名实体识别（NER）全都属于它。本章从概率图模型出发，完整推导 **HMM（隐马尔可夫模型）** 与 **Viterbi 解码**，再对比 **CRF** 与 **BiLSTM-CRF**，最后给出 numpy 实现。

---

## 1. 序列标注任务

### 1.1 任务定义

给定一个词序列（观察序列）$\mathbf{x} = (x_1, x_2, \dots, x_n)$，为**每个位置**预测一个标签（状态）：

$$
\hat{\mathbf{y}} = \arg\max_{\mathbf{y}} P(\mathbf{y} \mid \mathbf{x}), \quad \mathbf{y} = (y_1, y_2, \dots, y_n)
$$

关键在"标注有**序列依赖**"：当前位置的标签不只取决于当前词，还受**邻居标签**影响（如"动词后面更可能是名词"）。

### 1.2 三个典型任务

| 任务 | 输入 | 标签 | 示例 |
|------|------|------|------|
| **中文分词** | 汉字序列 | B/M/E/S（词首/词中/词尾/单字） | 研究/生命/科学 → 研(B)究(E) 生(B)命(E) 科(B)学(E) |
| **词性标注 POS** | 词序列 | 名词/动词/形容词…… | 我(NN) 爱(VV) 北京(NR) |
| **命名实体识别 NER** | 词序列 | B-PER/I-PER/O…… | 张( B-PER) 三(I-PER) 在(O) 北京(B-LOC) |

以分词为例，B/M/E/S 标注让"切分"变成"逐字分类"：

```
句子:   我  喜  欢  自  然  语  言  处  理
标签:   S   B   M   E   B   M   E   B   E
切分:   我 | 喜欢 | 自然 | 语言 | 处理
```

**边界一致性约束**：标签序列必须合法（B 后面才能是 M/E，E 后面不能是 B……），这正是概率图模型比逐位置独立分类多出来的价值。

---

## 2. 概率图模型与 HMM

### 2.1 概率图模型直觉

把变量之间的依赖关系画成**图**，节点是随机变量，边是依赖：

- **生成式模型**：建模联合概率 $P(X, Y)$，再通过贝叶斯求 $P(Y \mid X)$。HMM、朴素贝叶斯属此类。
- **判别式模型**：直接建模条件概率 $P(Y \mid X)$。CRF 属此类，见第 5 节。

### 2.2 HMM 的假设

HMM（Hidden Markov Model）假设存在一个**不可观测的马尔可夫链**（状态序列 $Y$），它按概率"生成"可观测的输出序列 $X$。语言背景：状态=词性/词边界，观测=具体的词/字。

HMM 依赖两个关键假设（一阶）：

1. **齐次马尔可夫假设**（状态只依赖前一状态）：

$$
P(y_t \mid y_{1:t-1}) = P(y_t \mid y_{t-1})
$$

2. **观测独立假设**（当前观测只依赖当前状态）：

$$
P(x_t \mid y_{1:t}, x_{1:t-1}) = P(x_t \mid y_t)
$$

> 马尔可夫链的数学背景见 [[../../数理基础/随机过程/马尔可夫链|马尔可夫链]]，这里的 HMM 就是"隐藏的马尔可夫链 + 观测发射"。

### 2.3 HMM 五元组

HMM 由五元组 $\lambda = (S, O, A, B, \pi)$ 描述：

| 符号 | 名称 | 含义 |
|------|------|------|
| $S = \{s_1, \dots, s_N\}$ | 状态集合 | 如词性标签集合（大小 $N$） |
| $O = \{o_1, \dots, o_M\}$ | 观测集合 | 如词表（大小 $M$） |
| $A = [a_{ij}]_{N \times N}$ | 转移概率矩阵 | $a_{ij} = P(y_{t+1}=s_j \mid y_t = s_i)$ |
| $B = [b_j(k)]_{N \times M}$ | 发射概率矩阵 | $b_j(k) = P(x_t = o_k \mid y_t = s_j)$ |
| $\pi = [\pi_i]$ | 初始状态分布 | $\pi_i = P(y_1 = s_i)$ |

概率模型对任意序列展开为：

$$
P(\mathbf{x}, \mathbf{y}; \lambda) =
\pi_{y_1} \prod_{t=1}^{n-1} a_{y_t, y_{t+1}} \prod_{t=1}^{n} b_{y_t}(x_t)
$$

### 2.4 HMM 的三个基本问题

1. **概率计算**（评估）：给定 $\lambda$，计算 $P(\mathbf{x} \mid \lambda)$。→ 前向/后向算法。
2. **学习**（参数估计）：给定观测序列，估计 $A, B, \pi$。→ Baum-Welch（EM）。
3. **解码**（预测）：给定 $\lambda$ 和 $\mathbf{x}$，求最可能的隐藏序列：

$$
\hat{\mathbf{y}} = \arg\max_{\mathbf{y}} P(\mathbf{y} \mid \mathbf{x}, \lambda)
$$

解码问题就是本文重点的 **Viterbi 算法**。

---

## 3. Viterbi 算法（动态规划）

### 3.1 问题复杂度

朴素做法枚举所有 $N^n$ 条状态路径，指数爆炸。但 HMM 的马尔可夫结构让最优子结构成立——**到达位置 $t$ 状态 $s_j$ 的最优路径只与前一位置的最优路径有关**，可用动态规划。

### 3.2 递推公式

定义**最大对数（或概率）路径值** $\delta_t(j)$：到时刻 $t$ 且 $y_t = s_j$ 的所有路径中，概率最大的值。

**初始化**（$t=1$）：

$$
\delta_1(j) = \pi_j \cdot b_j(x_1), \quad \psi_1(j) = 0
$$

**递推**（$t = 2, \dots, n$）：

$$
\delta_t(j) = \max_{1 \le i \le N} \left[ \delta_{t-1}(i) \cdot a_{ij} \right] \cdot b_j(x_t)
$$

同时**回溯指针**记录使上式最大的前一状态：

$$
\psi_t(j) = \arg\max_{1 \le i \le N} \left[ \delta_{t-1}(i) \cdot a_{ij} \right]
$$

**终止**（$t = n$）：

$$
P^* = \max_{1 \le j \le N} \delta_n(j), \qquad y_n^* = \arg\max_{1 \le j \le N} \delta_n(j)
$$

**回溯**（$t = n-1, \dots, 1$）：

$$
y_t^* = \psi_{t+1}(y_{t+1}^*)
$$

为避免数值下溢，工程上通常对 $\delta$ 取对数，把乘法变加法：

$$
\delta_t(j) = \max_i \left[ \delta_{t-1}(i) + \log a_{ij} \right] + \log b_j(x_t)
$$

**时间复杂度** $O(n \cdot N^2)$，**空间复杂度** $O(n \cdot N)$。

---

## 4. Viterbi 解码示例（词性标注）

考虑微型例子：状态集合 $\{N \text{(名词)}, V \text{(动词)}\}$，句子 "小明 看 书"（观测序列 $x_1 x_2 x_3$）。

参数（示意）：

$$
\pi = \begin{bmatrix} 0.6 \\ 0.4 \end{bmatrix} \text{（N, V）},\quad
A = \begin{bmatrix} 0.5 & 0.5 \\ 0.4 & 0.6 \end{bmatrix},\quad
B = \begin{bmatrix} 0.5 & 0.2 & 0.3 \\ 0.1 & 0.7 & 0.2 \end{bmatrix}
$$

其中 $B$ 的行是 N/V，列依次是"小明/看/书"。逐步计算 $\delta$：

**t=1**：
$$
\delta_1(N) = 0.6 \times 0.5 = 0.30, \quad \delta_1(V) = 0.4 \times 0.1 = 0.04
$$

**t=2**（观测"看"，$b_N(\text{看})=0.2, b_V(\text{看})=0.7$）：

$$
\delta_2(N) = \max(0.30 \times 0.5,\ 0.04 \times 0.4) \times 0.2 = \max(0.15, 0.016) \times 0.2 = 0.0300,\ \psi_2(N)=N
$$

$$
\delta_2(V) = \max(0.30 \times 0.5,\ 0.04 \times 0.6) \times 0.7 = \max(0.15, 0.024) \times 0.7 = 0.1050,\ \psi_2(V)=N
$$

**t=3**（观测"书"，$b_N(\text{书})=0.3, b_V(\text{书})=0.2$）：

$$
\delta_3(N) = \max(0.0300 \times 0.5,\ 0.1050 \times 0.4) \times 0.3 = 0.0420 \times 0.3 = 0.0126,\ \psi_3(N)=V
$$

$$
\delta_3(V) = \max(0.0300 \times 0.5,\ 0.1050 \times 0.6) \times 0.2 = 0.0630 \times 0.2 = 0.0126,\ \psi_3(V)=V
$$

**终止**：$y_3^* = \arg\max(0.0126, 0.0126)$，取 $V$；**回溯** $\psi_3(V)=V \Rightarrow y_2^*=V$，$\psi_2(V)=N \Rightarrow y_1^*=N$。

**解码结果**：`小明/N，看/V，书/V`——注意它没有把"书"标成名词，正是联合优化了转移+发射的结果（此例中 $V \to V$ 转移更平滑）。

---

## 5. 从 HMM 到 CRF

### 5.1 HMM 的局限

1. **观测独立假设太强**：真实文本里当前词受前后多个词影响，不是只看当前状态。
2. **难以融合任意特征**：HMM 只能建模"状态-状态"和"状态-观测"，无法加入"当前词是否大写""是否出现在地名库"这类**灵活特征**。
3. 生成式建模联合概率 $P(X,Y)$，而真正要的是判别 $P(Y \mid X)$。

### 5.2 CRF（条件随机场）

CRF（Conditional Random Field）直接建模条件概率，并允许定义任意特征函数。线性链 CRF 的框架（状态 $Y$ 构成一阶马尔可夫链）：

$$
P(\mathbf{y} \mid \mathbf{x}) =
\frac{1}{Z(\mathbf{x})}
\exp\Big( \sum_{t=1}^{n} \sum_{k} \lambda_k f_k(y_t, x_t)
       + \sum_{t=1}^{n-1} \sum_{l} \mu_l g_l(y_t, y_{t+1}, \mathbf{x}) \Big)
$$

- $f_k$：**发射/状态特征**，如 $\mathbf{1}\{x_t=\text{"北京"},\ y_t=\text{B-LOC}\}$。
- $g_l$：**转移特征**，如 $\mathbf{1}\{y_t=\text{B-LOC},\ y_{t+1}=\text{I-LOC}\}$。
- $\lambda_k, \mu_l$：可学习的权重。
- $Z(\mathbf{x})$：配分函数，对所有标签序列求和归一化，保证 $\sum_{\mathbf{y}} P(\mathbf{y}|\mathbf{x}) = 1$。

### 5.3 HMM vs CRF 对比

| 维度 | HMM | CRF |
|------|-----|-----|
| 建模对象 | 联合 $P(X,Y)$（生成式） | 条件 $P(Y\mid X)$（判别式） |
| 特征 | 仅转移/发射，模板固定 | **任意特征函数**，可叠加资源特征 |
| 长程依赖 | 只能一阶 | 转移仍一阶，但特征可含任意上下文 |
| 训练 | 极大似然/EM | 极大似然（L-BFGS，凸优化） |
| 数据量 | 少即可 | 需更多数据 |
| 序列依赖 | 有 | 有（更强表达） |

> 一句话：CRF = HMM 的结构 + 特征工程的自由。CRF 在 2015 年之前一直是序列标注的 SOTA。

---

## 6. BiLSTM-CRF：深度学习方案

### 6.1 结构

2015 年前后的主流方案：用 **BiLSTM** 提供上下文相关的发射分数，用 **CRF 层** 约束标签转移的全局一致性。

```
            输入词: 我(NN) 爱(VV) 北京(NR)
               ↓
         [词向量 + 字符向量]   (见 01 词向量)
               ↓
        BiLSTM 双向编码          ← 融合左右上下文
               ↓
        每个位置 → 发射分数 E[t, j]（到标签 j 的得分）
               ↓
          CRF 转移矩阵 T[i, j]   ← 标签之间的转移得分
               ↓
         Viterbi 解码最优标签序列
```

### 6.2 数学形式

CRF 得分函数：

$$
\text{score}(\mathbf{x}, \mathbf{y}) = \sum_{t=1}^{n} E_{t, y_t} + \sum_{t=1}^{n-1} T_{y_t, y_{t+1}}
$$

其中 $E$（发射矩阵）由 BiLSTM 输出经线性层得到，$T$（转移矩阵）是可学习参数。训练用负对数似然：

$$
\mathcal{L} = - \log P(\mathbf{y}^* \mid \mathbf{x})
= -\log \frac{e^{\text{score}(\mathbf{x}, \mathbf{y}^*)}}{Z(\mathbf{x})}
$$

配分函数 $Z(\mathbf{x}) = \sum_{\mathbf{y}'} e^{\text{score}(\mathbf{x}, \mathbf{y}')}$ 用**前向算法**在 $O(nN^2)$ 内计算；解码用 Viterbi。BiLSTM 本身见 [[../深度学习教程/11-RNN与LSTM|RNN/LSTM]]。

> 现代 NER（如 BERT + Softmax）甚至不需要显式 CRF，因为预训练模型的上下文表示已隐含标签转移规律；但 BiLSTM-CRF 仍是理解"深度序列模型"的最佳教材。

---

## 7. Python 实现

### 7.1 numpy 实现 Viterbi

```python
import numpy as np

def viterbi(obs, A, B, pi):
    """
    obs: 观测序列，如 [0, 1, 2]
    A:   转移矩阵 [N, N]
    B:   发射矩阵 [N, M]
    pi:  初始分布 [N]
    返回: 最优状态序列
    """
    N = A.shape[0]
    T = len(obs)
    delta = np.zeros((T, N))
    psi   = np.zeros((T, N), dtype=int)

    delta[0] = pi * B[:, obs[0]]
    for t in range(1, T):
        for j in range(N):
            candidates = delta[t-1] * A[:, j]        # [N]
            delta[t, j] = candidates.max() * B[j, obs[t]]
            psi[t, j]   = candidates.argmax()

    path = np.zeros(T, dtype=int)
    path[-1] = delta[-1].argmax()
    for t in range(T-2, -1, -1):
        path[t] = psi[t+1, path[t+1]]                # 回溯
    return path

# 第 4 节的例子
A = np.array([[0.5, 0.5], [0.4, 0.6]])
B = np.array([[0.5, 0.2, 0.3], [0.1, 0.7, 0.2]])
pi = np.array([0.6, 0.4])
obs = [0, 1, 2]
tags = ["N", "V"]
print([tags[i] for i in viterbi(obs, A, B, pi)])     # ['N', 'V', 'V']
```

### 7.2 用 hmmlearn 训练 + 预测

```python
# pip install hmmlearn
import numpy as np
from hmmlearn import hmm

# 模拟：三个观测词，两种状态
obs_seqs = [[0, 1, 0, 2, 1], [1, 2, 1, 0, 0], [2, 1, 0, 2, 1]]
lengths = [len(s) for s in obs_seqs]
X = np.concatenate(obs_seqs).reshape(-1, 1)

model = hmm.MultinomialHMM(n_components=2, n_iter=100, random_state=7)
model.fit(X, lengths)
model.decode(np.array([0, 1, 2]).reshape(-1, 1))     # (logprob, 状态路径)
```

`hmmlearn` 用 Baum-Welch（EM）自动估计 $A, B, \pi$，`decode` 内部即 Viterbi。

### 7.3 简单 CRF 工具

```python
# pip install sklearn-crfsuite
import sklearn_crfsuite

def word2features(sent, i):
    w = sent[i]
    feats = {
        "word": w,
        "word.lower": w.lower(),
        "word[-3:]": w[-3:],
        "prefix1": w[0],
        "suffix1": w[-1],
        "is_title": w.istitle(),
    }
    if i > 0:
        feats.update({"word[-1]": sent[i-1], "prev.title": sent[i-1].istitle()})
    return feats

def sent2features(sent):
    return [word2features(sent, i) for i in range(len(sent))]

X_tr = [sent2features(s) for s in sentences]     # sentences: 词序列列表
y_tr = [tags for tags in tag_sequences]
crf = sklearn_crfsuite.CRF(algorithm="lbfgs", max_iterations=100)
crf.fit(X_tr, y_tr)
print(crf.predict([sent2features("我 爱 北京".split())]))
```

> 模型统一印象：`Viterbi(HMM) ⊂ CRF ⊂ BiLSTM-CRF` 依次把"模型表达"和"特征来源"升级，但解码骨架（Viterbi）始终不变。

---

## 相关笔记

- [[../../数理基础/随机过程/马尔可夫链|马尔可夫链]] — HMM 的概率论基础
- [[../马尔可夫决策过程 (Markov Decision Process, MDP)|MDP]] — 马尔可夫族模型的另一个重要成员
- [[../深度学习教程/11-RNN与LSTM|RNN/LSTM]] — BiLSTM 编码器
- [[01-文本表示与词向量|文本表示与词向量]] — 序列模型的输入表示
- [[../深度学习教程/12-Transformer与大模型|Transformer]] — 现代序列标注的替代方案
- [[00-NLP索引|NLP 索引]] — 回到任务全景
