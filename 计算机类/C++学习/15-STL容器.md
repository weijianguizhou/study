# 15-STL容器

C++标准模板库(STL)提供了一堆现成的数据结构，你再也不用手写链表和哈希表了。所有容器都在`std`命名空间里，用哪个就`#include`哪个。

---

# 一、vector（动态数组）

最常用的容器——自动扩容的数组。

```cpp
#include <vector>
#include <iostream>

int main() {
    std::vector<int> v = {10, 20, 30};

    v.push_back(40);         // 加到最后
    v.push_back(50);
    std::cout << "大小: " << v.size() << std::endl;  // 5

    // 遍历
    for (int i = 0; i < v.size(); i++)
        std::cout << v[i] << " ";
    std::cout << std::endl;

    // 范围for（C++11）
    for (int x : v)
        std::cout << x << " ";
    std::cout << std::endl;

    // 常用操作
    v.pop_back();            // 删最后一个
    v.insert(v.begin(), 5);  // 在开头插入5
    v.erase(v.begin() + 1);  // 删第2个元素
    std::cout << "前三个: " << v[0] << v[1] << v[2] << std::endl;
}
```

```cmd
大小: 5
10 20 30 40 50
10 20 30 40 50
前三个: 51030
```

`vector`在底层是一块连续内存。当容量不够时，它自动分配一块更大的，把旧数据拷过去。所以**别存指向vector元素的指针**——扩容后原来的地址就失效了。

---

# 二、list（双向链表）

```cpp
#include <list>

std::list<int> lst = {1, 2, 3};
lst.push_front(0);   // 前面加
lst.push_back(4);    // 后面加
// 不能 lst[2] 这样访问——链表不支持随机访问
```

`list`的优势：在中间插入删除是$O(1)$。劣势：不能随机访问、内存不连续缓存不友好。**大多数情况用vector就够了**。

---

# 三、map（键-值对，红黑树）

```cpp
#include <map>
#include <string>

std::map<std::string, int> scores;
scores["张三"] = 95;
scores["李四"] = 88;
scores["张三"] = 97;   // 覆盖

std::cout << scores["张三"] << std::endl;   // 97

// 安全查找
auto it = scores.find("王五");
if (it != scores.end())
    std::cout << it->second << std::endl;
else
    std::cout << "找不到" << std::endl;

// 遍历
for (auto &[name, score] : scores)    // C++17结构化绑定
    std::cout << name << ": " << score << std::endl;
```

```cmd
97
找不到
李四: 88
张三: 97
```

`map`的键自动排序（默认升序）。底层是红黑树，插入/查找都是$O(\log n)$。如果不需要排序，用`unordered_map`（哈希表，$O(1)$平均）。

---

# 四、set（不重复集合）

```cpp
#include <set>

std::set<int> s = {3, 1, 4, 1, 5, 9, 2, 6};
s.insert(5);   // 5已经存在，被忽略
for (int x : s)
    std::cout << x << " ";    // 1 2 3 4 5 6 9  自动排序+去重
```

---

# 五、常用操作速查

| 操作 | 说明 |
|------|------|
| `v.size()` | 元素个数 |
| `v.empty()` | 是否为空 |
| `v.clear()` | 清空 |
| `v.front()` / `v.back()` | 首/尾元素引用 |
| `v.begin()` / `v.end()` | 迭代器（首/尾后）|

---

## 下一步

- [[16-STL算法|STL算法]] — sort、find、transform
