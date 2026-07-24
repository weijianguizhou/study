# 16-STL算法

容器负责存数据，算法负责处理数据。STL算法通过**迭代器**跟容器交互——同一个`sort`能排`vector`也能排`deque`。统一接口，威力巨大。

```cpp
#include <algorithm>
#include <vector>
#include <numeric>
```

---

# 一、排序与查找

```cpp
#include <algorithm>
#include <vector>
#include <iostream>

int main() {
    std::vector<int> v = {5, 2, 8, 1, 9, 3};

    // 升序
    std::sort(v.begin(), v.end());
    for (int x : v) std::cout << x << " ";   // 1 2 3 5 8 9
    std::cout << std::endl;

    // 降序（用lambda自定义比较）
    std::sort(v.begin(), v.end(), [](int a, int b) { return a > b; });
    for (int x : v) std::cout << x << " ";   // 9 8 5 3 2 1
    std::cout << std::endl;

    // 二分查找（前提：已排序）
    bool found = std::binary_search(v.begin(), v.end(), 5);
    std::cout << (found ? "找到5" : "没有5") << std::endl;
}
```

---

# 二、find / count / accumulate

```cpp
std::vector<int> v = {1, 2, 3, 2, 5, 2};

// 找第一个2
auto it = std::find(v.begin(), v.end(), 2);
if (it != v.end())
    std::cout << "第一个2在位置 " << (it - v.begin()) << std::endl;  // 1

// 有几个2
int cnt = std::count(v.begin(), v.end(), 2);    // 3

// 求总和
int sum = std::accumulate(v.begin(), v.end(), 0);   // 15
std::cout << "总和: " << sum << std::endl;
```

`accumulate`在`<numeric>`里，初始值`0`决定返回类型——这里0是int所以返回int。`accumulate(v.begin(), v.end(), 0.0)`返回double。

---

# 三、transform（逐元素变换）

```cpp
std::vector<int> v = {1, 2, 3, 4, 5};
std::vector<int> squares(v.size());

// 每个元素平方，输出到squares
std::transform(v.begin(), v.end(), squares.begin(),
    [](int x) { return x * x; });
// squares = {1, 4, 9, 16, 25}
```

---

# 四、lambda表达式

上面反复出现的`[](int x) { return x * x; }`就是lambda——**匿名函数，就地定义，就地使用**。语法：

```
[捕获](参数) -> 返回值类型 { 函数体 }
```

```cpp
int threshold = 3;
auto it = std::find_if(v.begin(), v.end(),
    [threshold](int x) { return x > threshold; }  // 捕获外部变量threshold
);
```

`[]`是捕获列表——告诉lambda它可以"看见"哪些外部变量。`[=]`按值捕获所有，`[&]`按引用捕获所有。

---

# 五、常用算法一览

| 算法 | 做什么 |
|------|--------|
| `sort(begin,end)` | 排序 |
| `stable_sort(begin,end)` | 稳定排序 |
| `find(begin,end,val)` | 查找值 |
| `find_if(begin,end,pred)` | 按条件查找 |
| `count(begin,end,val)` | 计数 |
| `accumulate(begin,end,init)` | 累加 |
| `transform(begin,end,out,fn)` | 逐元素变换 |
| `reverse(begin,end)` | 反转 |
| `fill(begin,end,val)` | 填充 |
| `max_element(begin,end)` | 最大元素位置 |
| `min_element(begin,end)` | 最小元素位置 |
| `unique(begin,end)` | 去重（需先排序）|

---

## 下一步

- [[17-智能指针与模板|智能指针与模板]]
