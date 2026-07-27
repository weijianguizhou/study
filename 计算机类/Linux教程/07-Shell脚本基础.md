# Shell 脚本基础

> Shell 脚本是 Linux 系统管理与运维自动化的核心技能。掌握了 Shell 脚本，你就能将重复的命令行工作自动化，真正发挥 Linux 的强大威力。

---

## 一、Shell 是什么

### 1.1 Shell 的定义

**Shell = 命令解释器**，是用户与 Linux 内核之间的中间层。

```
用户 → Shell（解释命令）→ 内核（执行操作）→ 硬件
```

- 我们输入的命令被 Shell 解析后，传递给内核执行
- Shell 既是**命令语言**（交互式执行），也是**脚本语言**（批处理执行）
- Shell 脚本的本质：将一系列命令写入文件，批量执行

### 1.2 常见 Shell 种类

| Shell | 全称 | 特点 | 用途 |
|-------|------|------|------|
| **bash** | Bourne Again SHell | Linux 默认，功能丰富 | 绝大多数发行版默认 |
| **sh** | Bourne Shell | Unix 原始 shell，轻量 | 脚本兼容性 |
| **zsh** | Z Shell | 兼容 bash，插件/主题多 | macOS 默认，开发者喜爱 |
| **fish** | Friendly Interactive SHell | 语法友好，自动补全强大 | 交互式使用 |
| **dash** | Debian Almquist Shell | 极轻量，POSIX 兼容 | 系统脚本（启动脚本） |

```bash
# 查看当前使用的 Shell
$ echo $SHELL
/bin/bash

# 查看系统中有哪些 Shell
$ cat /etc/shells
/bin/sh
/bin/bash
/usr/bin/bash
/usr/bin/zsh
/bin/zsh
/bin/dash

# 查看 bash 版本
$ bash --version
GNU bash, version 5.1.16(1)-release (x86_64-pc-linux-gnu)
```

### 1.3 Shebang (`#!`) 的含义

每个 Shell 脚本的第一行通常是：

```bash
#!/bin/bash
```

- `#!` 叫做 **Shebang**（或 Hashbang）
- 告诉系统用哪个解释器来执行这个脚本
- 可以是：`#!/bin/bash`、`#!/bin/zsh`、`#!/usr/bin/env python3` 等
- **`#!/usr/bin/env bash`** 更可移植（从 PATH 中找 bash）

```bash
# 不同语言的 Shebang 示例
#!/bin/bash          # Bash 脚本
#!/bin/sh            # POSIX sh 脚本（更兼容）
#!/usr/bin/env python3   # Python 脚本
#!/usr/bin/env node      # Node.js 脚本
```

> 注意：如果脚本用 `bash script.sh` 执行，Shebang 行会被忽略。

---

## 二、第一个脚本

### 2.1 编写 Hello World

```bash
#!/bin/bash
echo "Hello, World!"
echo "当前时间: $(date)"
echo "当前用户: $USER"
```

### 2.2 创建与运行脚本

```bash
# 第一步：创建脚本文件
$ nano hello.sh

# 第二步：赋予执行权限
$ chmod +x hello.sh

# 第三步：查看权限
$ ls -l hello.sh
-rwxr-xr-x 1 john john 96 Jul 27 14:30 hello.sh

# 第四步：执行脚本
$ ./hello.sh
Hello, World!
当前时间: Mon Jul 27 14:30:15 CST 2026
当前用户: john
```

### 2.3 为什么是 `./hello.sh` 而不是 `hello.sh`？

这涉及 **PATH 环境变量**的概念：

```bash
# 查看当前的 PATH
$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 如果直接输入 hello.sh，系统会在 PATH 中搜索，找不到就报错
$ hello.sh
bash: hello.sh: command not found

# ./ 表示"当前目录"，告诉系统在当前目录找
$ ./hello.sh    # 正确
```

**运行脚本的三种方式**：

```bash
# 方式1：作为可执行文件运行（需要 +x 权限）
$ chmod +x hello.sh
$ ./hello.sh

# 方式2：用 bash 解释器直接运行（不需要 +x 权限）
$ bash hello.sh

# 方式3：用 source 或 . 在当前 shell 环境中执行（不启动子 shell）
$ source hello.sh
$ . hello.sh    # 等效
```

`source` 与 `./` 的关键区别：

```bash
# 创建测试脚本
$ cat > test_var.sh << 'EOF'
#!/bin/bash
export MY_VAR="hello from script"
EOF

# 方式1：./ 执行 — 在子 shell 中运行，变量不会传递到当前 shell
$ chmod +x test_var.sh
$ ./test_var.sh
$ echo $MY_VAR
                       # 空！变量在子 shell 中，退出后消失

# 方式2：source 执行 — 在当前 shell 中运行，变量保留
$ source test_var.sh
$ echo $MY_VAR
hello from script       # 变量保留！
```

---

## 三、变量

### 3.1 定义变量

```bash
# 定义变量：等号两边不能有空格！
$ name="John"
$ age=25
$ pi=3.14159

# 错误示范
$ name = "John"    # bash 会把 name 当成命令执行
bash: name: command not found

$ name= John       # 同上
bash: John: command not found
```

**变量命名规则**：
- 只能包含字母、数字、下划线
- 不能以数字开头
- 区分大小写（`Name` 和 `name` 是不同变量）
- 通常使用大写字母命名环境变量，小写字母命名局部变量

### 3.2 使用变量

```bash
$ name="Alice"
$ echo $name
Alice

$ echo ${name}       # 推荐：用 {} 包裹变量名，避免歧义
Alice

# {} 的必要性
$ count=5
$ echo "第${count}个文件"      # 正确
第5个文件
$ echo "第$count个文件"        # bash 会去找 $count个 变量
第                          # 输出错误

# 多变量场景
$ first_name="Zhang"
$ last_name="San"
$ echo "${first_name} ${last_name}"
Zhang San
```

### 3.3 只读变量

```bash
$ readonly PI=3.14159
$ echo $PI
3.14159
$ PI=3.14
bash: PI: readonly variable     # 不能修改只读变量

# declare -r 也能设置只读
$ declare -r GRAVITY=9.8
$ GRAVITY=10.0
bash: GRAVITY: readonly variable
```

### 3.4 删除变量

```bash
$ temp_var="I will be deleted"
$ echo $temp_var
I will be deleted

$ unset temp_var
$ echo $temp_var
                        # 空输出，变量已删除

# unset 不能删除只读变量
$ unset PI
bash: unset: PI: cannot unset: readonly variable
```

### 3.5 变量类型：环境变量 vs 局部变量

```bash
# 局部变量（只在当前 shell 中有效）
$ local_var="I am local"

# 用 export 把局部变量提升为环境变量（子进程可访问）
$ export GLOBAL_VAR="I am global"

# 验证
$ bash -c 'echo "local_var: $local_var"'
local_var:                     # 子进程访问不到
$ bash -c 'echo "GLOBAL_VAR: $GLOBAL_VAR"'
GLOBAL_VAR: I am global        # 子进程可以访问

# 一次性导出
$ export NEW_VAR="hello"

# 查看所有环境变量
$ env
$ printenv
$ export -p
```

### 3.6 常用内置环境变量

```bash
$ echo "HOME = $HOME"
HOME = /home/john

$ echo "USER = $USER"
USER = john

$ echo "PATH = $PATH"
PATH = /usr/local/bin:/usr/bin:/bin

$ echo "PWD = $PWD"
PWD = /home/john/projects

$ echo "SHELL = $SHELL"
SHELL = /bin/bash

$ echo "UID = $UID"
UID = 1000

$ echo "HOSTNAME = $HOSTNAME"
HOSTNAME = my-server

$ echo "LANG = $LANG"
LANG = zh_CN.UTF-8

$ echo "OLDPWD = $OLDPWD"
OLDPWD = /home/john          # 上一个工作目录

$ echo "RANDOM = $RANDOM"
RANDOM = 18342               # 每次访问生成随机数（0-32767）
```

### 3.7 特殊变量（重点）

```bash
# 编写脚本来展示特殊变量
$ cat > special_vars.sh << 'EOF'
#!/bin/bash
echo "脚本名(\$0): $0"
echo "第1个参数(\$1): $1"
echo "第2个参数(\$2): $2"
echo "第3个参数(\$3): $3"
echo "参数个数(\$#): $#"
echo "所有参数-分开(\$@): $@"
echo "所有参数-合并(\$*): $*"
echo "当前进程PID(\$\$): $$"
echo "脚本退出码(\$?): $?"
EOF

$ chmod +x special_vars.sh
$ ./special_vars.sh apple banana cherry

脚本名($0): ./special_vars.sh
第1个参数($1): apple
第2个参数($2): banana
第3个参数($3): cherry
参数个数($#): 3
所有参数-分开($@): apple banana cherry
所有参数-合并($*): apple banana cherry
当前进程PID($$): 12345
脚本退出码($?): 0
```

`$@` 与 `$*` 的关键区别：

```bash
# 用引号包裹时的区别才显现
$ cat > diff_args.sh << 'EOF'
#!/bin/bash
echo "=== \$@ (保留独立参数) ==="
for arg in "$@"; do
    echo "参数: $arg"
done

echo ""
echo "=== \$* (所有参数合并为一个字符串) ==="
for arg in "$*"; do
    echo "参数: $arg"
done
EOF

$ chmod +x diff_args.sh
$ ./diff_args.sh "hello world" foo bar

=== $@ (保留独立参数) ===
参数: hello world
参数: foo
参数: bar

=== $* (所有参数合并为一个字符串) ===
参数: hello world foo bar
```

**常用特殊变量速查表**：

| 变量 | 含义 |
|------|------|
| `$0` | 脚本名称 |
| `$1` ~ `$9` | 第1~9个位置参数 |
| `${10}` | 第10个位置参数（需要花括号） |
| `$#` | 参数个数 |
| `$@` | 所有参数（各自独立） |
| `$*` | 所有参数（合并为字符串） |
| `$$` | 当前进程 PID |
| `$!` | 最后一个后台进程 PID |
| `$?` | 上一条命令的退出码（0=成功） |
| `$-` | 当前 shell 的选项标志 |

### 3.8 退出码 `$?`

```bash
# 成功执行，退出码为 0
$ ls /tmp > /dev/null
$ echo $?
0

# 失败执行，退出码非 0
$ ls /nonexistent_dir
ls: cannot access '/nonexistent_dir': No such file or directory
$ echo $?
2

# 脚本中自定义退出码
$ cat > exit_demo.sh << 'EOF'
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "用法: $0 <参数>"
    exit 1       # 退出码 1 表示参数错误
fi
echo "参数是: $1"
exit 0           # 退出码 0 表示成功
EOF

$ chmod +x exit_demo.sh
$ ./exit_demo.sh
用法: ./exit_demo.sh <参数>
$ echo $?
1

$ ./exit_demo.sh hello
参数是: hello
$ echo $?
0
```

### 3.9 命令替换

```bash
# 语法1：$(command) — 推荐
$ today=$(date +%Y-%m-%d)
$ echo "今天是: $today"
今天是: 2026-07-27

# 语法2：`command` — 反引号（旧式）
$ today=`date +%Y-%m-%d`
$ echo "今天是: $today"
今天是: 2026-07-27

# 嵌套命令替换
$ project_dir=$(ls -d $(pwd)/project-*)
$ echo $project_dir

# 强大的组合示例
$ file_count=$(ls -1 | wc -l)
$ echo "当前目录有 $file_count 个文件"
当前目录有 42 个文件

$ largest_file=$(ls -lS | head -2 | tail -1 | awk '{print $NF}')
$ echo "最大的文件: $largest_file"
最大的文件: bigdata.tar.gz

$ disk_usage=$(df -h / | tail -1 | awk '{print $5}')
$ echo "根分区使用率: $disk_usage"
根分区使用率: 45%
```

### 3.10 算术运算

```bash
# 语法1：$((expression)) — 推荐
$ a=10
$ b=3
$ echo $((a + b))
13
$ echo $((a - b))
7
$ echo $((a * b))
30
$ echo $((a / b))      # 整数除法
3
$ echo $((a % b))      # 取余
1
$ echo $((a ** b))     # 幂运算
1000
$ echo $(( (a + b) * 2 ))
26

# 语法2：let 命令
$ let c=a+b
$ echo $c
13
$ let c+=1             # 自增
$ echo $c
14

# 语法3：expr（外部命令，不推荐用于脚本）
$ expr 10 + 3
13

# 浮点数运算：bc 命令
$ echo "scale=2; 10 / 3" | bc
3.33
$ echo "scale=4; 22 / 7" | bc
3.1428

# 常用数学函数
$ echo "scale=2; sqrt(2)" | bc
1.41
$ echo "scale=10; 4*a(1)" | bc -l    # π
3.1415926532

# 实战：计算圆的面积
$ cat > circle_area.sh << 'EOF'
#!/bin/bash
read -p "请输入圆的半径: " r
area=$(echo "scale=2; 3.14159 * $r * $r" | bc)
echo "半径为 $r 的圆面积是: $area"
EOF

$ chmod +x circle_area.sh
$ ./circle_area.sh
请输入圆的半径: 5
半径为 5 的圆面积是: 78.53
```

---

## 四、字符串操作

### 4.1 三种引号的区别

```bash
$ name="World"

# 单引号 '...'：完全原样输出，不解析任何东西
$ echo 'Hello $name'
Hello $name                 # 变量未被解析

# 双引号 "..."：解析变量和转义字符
$ echo "Hello $name"
Hello World                 # 变量被解析

# 双引号中保留特殊字符的字面意义
$ echo "Hello\tWorld"
Hello\tWorld                # \t 不是 tab（默认行为）
$ echo -e "Hello\tWorld"
Hello	World                # -e 启用转义解析

# 反引号 `...`：命令替换（已过时）
$ echo "当前时间是 `date`"
当前时间是 Mon Jul 27 14:30:15 CST 2026

# 无引号：按空格拆分，进行通配符扩展
$ var="hello world"
$ echo $var
hello world                 # 被分割
$ echo "$var"
hello world                 # 保持原样
```

**引号选择指南**：

| 符号 | 变量解析 | 命令替换 | 转义字符 | 使用场景 |
|------|---------|---------|---------|---------|
| `'...'` | 否 | 否 | 否 | 纯字符串常量 |
| `"..."` | 是 | 是 | 部分 | 拼接变量输出 |
| `$'...'` | 否 | 否 | ANSI-C | 需要\n\t等控制字符 |
| 无引号 | 是 | 是 | 是 | 简单情况 |

```bash
# 实际应用
$ file_path="/home/john/my documents/report.txt"
$ ls $file_path       # 错误！空格导致路径被拆分
$ ls "$file_path"     # 正确！引号保护空格
```

### 4.2 字符串拼接

```bash
$ first="Hello"
$ second="World"

# 方式1：直接相邻
$ greeting=$first$second
$ echo $greeting
HelloWorld

# 方式2：双引号内拼接
$ greeting="$first $second"
$ echo $greeting
Hello World

# 方式3：用花括号明确变量边界
$ greeting="${first} ${second}!"
$ echo $greeting
Hello World!

# 方式4：混合拼接
$ count=5
$ echo "共有${count}个用户在线"
共有5个用户在线

# 实战：构建文件路径
$ base_dir="/var/log"
$ app_name="nginx"
$ log_file="${base_dir}/${app_name}/access.log"
$ echo $log_file
/var/log/nginx/access.log
```

### 4.3 字符串长度

```bash
$ str="Hello, Linux!"
$ echo "字符串: $str"
字符串: Hello, Linux!
$ echo "长度: ${#str}"
长度: 13

# 中文字符（UTF-8 下每个中文字符占 3 字节）
$ str_cn="你好世界"
$ echo "长度: ${#str_cn}"
长度: 4                     # bash 4.0+ 正确计算字符数

# 空字符串
$ empty=""
$ echo ${#empty}
0
```

### 4.4 子串提取

```bash
$ str="Hello, Linux World!"

# ${str:start} — 从 start 位置到结尾（0-based）
$ echo ${str:7}
Linux World!

# ${str:start:length} — 提取指定长度
$ echo ${str:0:5}
Hello

$ echo ${str:7:5}
Linux

# 负数 start — 从末尾开始计算（注意冒号前加空格或括号）
$ echo ${str:(-6)}
World!

$ echo ${str:(-6):2}
Wo

# 实战：提取文件扩展名
$ filename="document.txt"
$ echo ${filename:(-3)}        # 最后 3 个字符 = 扩展名
txt

$ filename="archive.tar.gz"
$ echo ${filename##*.}         # 更好用（后面会讲）
gz
```

### 4.5 字符串替换

```bash
$ str="Hello World World"

# ${str/old/new} — 替换第一个匹配
$ echo ${str/World/Linux}
Hello Linux World

# ${str//old/new} — 替换所有匹配
$ echo ${str//World/Linux}
Hello Linux Linux

# ${str#pattern} — 删除前缀（最短匹配）
$ path="/usr/local/bin/script.sh"
$ echo ${path#/usr/}
local/bin/script.sh

# ${str##pattern} — 删除前缀（最长匹配）
$ echo ${path##*/}
script.sh

# ${str%pattern} — 删除后缀（最短匹配）
$ echo ${path%/*}
/usr/local/bin

# ${str%%pattern} — 删除后缀（最长匹配）
$ echo ${path%%/*}
                            # 空（删到最开始的 /）

# 实战：批量重命名文件后缀
$ cat > rename_ext.sh << 'EOF'
#!/bin/bash
# 将当前目录下所有 .txt 文件重命名为 .md
for file in *.txt; do
    # 用字符串操作去掉 .txt 后缀
    base="${file%.txt}"
    new_name="${base}.md"
    echo "重命名: $file → $new_name"
    mv "$file" "$new_name"
done
echo "批量重命名完成！"
EOF

$ chmod +x rename_ext.sh

# 演示
$ touch file1.txt file2.txt file3.txt
$ ls *.txt
file1.txt  file2.txt  file3.txt

$ ./rename_ext.sh
重命名: file1.txt → file1.md
重命名: file2.txt → file2.md
重命名: file3.txt → file3.md
批量重命名完成！
```

### 4.6 判断字符串

```bash
# 判断是否为空
$ str=""
$ [ -z "$str" ] && echo "字符串为空"
字符串为空

$ str="hello"
$ [ -n "$str" ] && echo "字符串非空"
字符串非空

# 判断包含子串
$ str="hello world"
$ [[ $str == *world* ]] && echo "包含 world"
包含 world
$ [[ $str == *Linux* ]] || echo "不包含 Linux"
不包含 Linux
```

---

## 五、数组

### 5.1 定义数组

```bash
# 方式1：空格分隔的列表
$ fruits=(apple banana cherry orange)

# 方式2：逐个赋值
$ colors[0]="red"
$ colors[1]="green"
$ colors[2]="blue"

# 方式3：命令输出赋值
$ files=( $(ls *.txt 2>/dev/null) )

# 方式4：混合赋值
$ mixed=("hello" 42 3.14 "world")
```

### 5.2 访问数组

```bash
$ arr=(apple banana cherry orange mango)

# 访问单个元素（0-based）
$ echo ${arr[0]}
apple
$ echo ${arr[2]}
cherry
$ echo ${arr[4]}
mango

# 访问所有元素
$ echo ${arr[@]}
apple banana cherry orange mango
$ echo ${arr[*]}
apple banana cherry orange mango

# 获取数组长度
$ echo ${#arr[@]}
5

# 获取某个元素的长度
$ echo ${#arr[0]}
5          # "apple" 5 个字符

# 切片操作
$ echo ${arr[@]:1:3}
banana cherry orange
```

### 5.3 遍历数组

```bash
$ arr=(apple banana cherry orange mango)

# for 循环遍历
$ for fruit in "${arr[@]}"; do
>     echo "水果: $fruit"
> done
水果: apple
水果: banana
水果: cherry
水果: orange
水果: mango

# 使用索引遍历
$ for i in "${!arr[@]}"; do
>     echo "索引 $i: ${arr[$i]}"
> done
索引 0: apple
索引 1: banana
索引 2: cherry
索引 3: orange
索引 4: mango
```

### 5.4 修改数组

```bash
$ arr=(apple banana cherry)

# 追加元素
$ arr+=(orange mango)
$ echo ${arr[@]}
apple banana cherry orange mango

# 追加单个元素
$ arr+=(watermelon)
$ echo ${arr[@]}
apple banana cherry orange mango watermelon

# 修改元素
$ arr[1]="blueberry"
$ echo ${arr[@]}
apple blueberry cherry orange mango watermelon

# 删除元素（将对应位置置空，不删除索引）
$ unset arr[2]
$ echo ${arr[@]}
apple blueberry orange mango watermelon
$ echo ${#arr[@]}
5                          # 长度变为 5

# 删除整个数组
$ unset arr
$ echo ${arr[@]}
                            # 空
```

### 5.5 关联数组（Bash 4.0+）

```bash
# 声明关联数组（类似 Python 的字典）
$ declare -A user

# 赋值
$ user[name]="张三"
$ user[age]=25
$ user[city]="北京"

# 访问
$ echo ${user[name]}
张三
$ echo ${user[age]}
25

# 获取所有键
$ echo ${!user[@]}
name age city

# 获取所有值
$ echo ${user[@]}
张三 25 北京

# 遍历关联数组
$ for key in "${!user[@]}"; do
>     echo "$key -> ${user[$key]}"
> done
name -> 张三
age -> 25
city -> 北京

# 数组长度
$ echo ${#user[@]}
3
```

### 5.6 数组实战示例

```bash
# 统计每个文件类型的数量
$ cat > count_types.sh << 'EOF'
#!/bin/bash
declare -A ext_count

# 遍历当前目录所有文件
for file in *; do
    if [ -f "$file" ]; then
        ext="${file##*.}"
        ((ext_count[$ext]++))
    fi
done

echo "文件类型统计："
for ext in "${!ext_count[@]}"; do
    echo "  .$ext: ${ext_count[$ext]} 个"
done
EOF

$ chmod +x count_types.sh
$ ./count_types.sh
文件类型统计：
  .txt: 5 个
  .sh: 3 个
  .md: 2 个
  .png: 1 个
```

---

## 六、条件判断

### 6.1 `test` 命令和 `[ ]`

```bash
# `[` 是一个命令，不是语法符号！`[` 实际上是 test 的别名
$ which [
/usr/bin/[

# 两种写法等价
$ test -f /etc/passwd && echo "存在"
$ [ -f /etc/passwd ] && echo "存在"
存在

# 注意：[ 后面和 ] 前面必须有空格！
$ [-f file]     # 错误！缺少空格
$ [ -f file]    # 正确
$ [-f file ]    # 错误！
$ [ -f file ]   # 正确

# 条件表达式中的空格非常重要！
$ a=5; b=10
$ [ $a = $b ]   # 正确
$ [ $a=$b ]     # 错误！被当作一个字符串，永远为真
```

### 6.2 数值比较

```bash
$ a=10; b=20; c=10

$ [ $a -eq $c ] && echo "a 等于 c"
a 等于 c

$ [ $a -ne $b ] && echo "a 不等于 b"
a 不等于 b

$ [ $a -gt $b ] && echo "a > b"
$ [ $a -gt $b ] || echo "a 不大于 b"
a 不大于 b

$ [ $a -lt $b ] && echo "a < b"
a < b

$ [ $a -ge $c ] && echo "a >= c"
a >= c

$ [ $b -le $c ] || echo "b 不小于等于 c"
b 不小于等于 c
```

**数值比较运算符**：

| 运算符 | 含义 | 英文 |
|--------|------|------|
| `-eq` | 等于 | equal |
| `-ne` | 不等于 | not equal |
| `-gt` | 大于 | greater than |
| `-lt` | 小于 | less than |
| `-ge` | 大于等于 | greater or equal |
| `-le` | 小于等于 | less or equal |

### 6.3 字符串比较

```bash
# 字符串相等
$ name="John"
$ [ "$name" = "John" ] && echo "匹配"
匹配
$ [ "$name" = "john" ] || echo "不匹配（区分大小写）"
不匹配（区分大小写）

# 字符串不相等
$ [ "$name" != "Jane" ] && echo "不相同"
不相同

# 字符串是否为空
$ empty=""
$ [ -z "$empty" ] && echo "字符串为空"
字符串为空

$ str="hello"
$ [ -n "$str" ] && echo "字符串非空"
字符串非空

# 按字典序比较（需要 [[ ]]）
$ [[ "abc" < "abd" ]] && echo "abc < abd"
abc < abd
$ [[ "b" > "a" ]] && echo "b > a"
b > a

# 正则匹配（需要 [[ ]]）
$ email="user@example.com"
$ [[ $email =~ ^[a-z]+@[a-z]+\.[a-z]+$ ]] && echo "合法邮箱"
合法邮箱

$ phone="1234abc5678"
$ [[ $phone =~ ^[0-9]+$ ]] || echo "不是纯数字"
不是纯数字
```

### 6.4 文件测试（重点）

```bash
# 文件存在
$ [ -e /etc/passwd ] && echo "文件存在"
文件存在

# 是普通文件（非目录、非设备）
$ [ -f /etc/passwd ] && echo "是普通文件"
是普通文件

# 是目录
$ [ -d /etc ] && echo "是目录"
是目录

# 文件非空（size > 0）
$ [ -s /etc/passwd ] && echo "文件非空"
文件非空

# 可读、可写、可执行
$ [ -r /etc/passwd ] && echo "可读"
可读
$ [ -w /etc/passwd ] && echo "可写"
$ [ -x /bin/bash ] && echo "可执行"
可执行

# 符号链接
$ [ -L /bin/sh ] && echo "是符号链接"
是符号链接

# 文件比较：哪个更新
$ [ file1 -nt file2 ] && echo "file1 比 file2 新"
$ [ file1 -ot file2 ] && echo "file1 比 file2 旧"

# 文件类型判断
$ [ -b /dev/sda ] && echo "块设备文件"    # block device
$ [ -c /dev/tty ] && echo "字符设备文件"  # character device
$ [ -p /tmp/mypipe ] && echo "管道文件"   # pipe
$ [ -S /var/run/docker.sock ] && echo "套接字文件"  # socket
```

**文件测试运算符速查表**：

| 运算符 | 含义 |
|--------|------|
| `-e` | 文件存在（exist） |
| `-f` | 是普通文件（regular file） |
| `-d` | 是目录（directory） |
| `-s` | 文件非空（size > 0） |
| `-r` | 可读（readable） |
| `-w` | 可写（writable） |
| `-x` | 可执行（executable） |
| `-L` | 是符号链接（symlink） |
| `-b` | 是块设备（block device） |
| `-c` | 是字符设备（character device） |
| `-p` | 是命名管道（pipe） |
| `-S` | 是套接字（socket） |
| `-N` | 文件自上次读取后已被修改 |
| `-O` | 当前用户是该文件的属主 |
| `-G` | 当前用户与该文件的组 ID 相同 |
| `file1 -nt file2` | file1 比 file2 新（newer than） |
| `file1 -ot file2` | file1 比 file2 旧（older than） |
| `file1 -ef file2` | file1 和 file2 指向同一文件 |

### 6.5 逻辑运算

```bash
# AND（逻辑与）：&& 或 -a
$ [ 5 -gt 3 ] && [ 5 -lt 10 ] && echo "5 在 3~10 之间"
5 在 3~10 之间

$ [ 5 -gt 3 -a 5 -lt 10 ] && echo "5 在 3~10 之间（-a）"
5 在 3~10 之间（-a）

# OR（逻辑或）：|| 或 -o
$ [ 5 -lt 3 ] || [ 5 -gt 10 ] || echo "5 不在 3< 也不 >10"
5 不在 3< 也不 >10

$ [ 5 -lt 3 -o 5 -gt 10 ] || echo "5 不在 3< 也不 >10（-o）"
5 不在 3< 也不 >10（-o）

# NOT（取反）：!
$ [ ! -d /etc ] || echo "/etc 不是目录"
/etc 不是目录                    # 实际上 /etc 是目录

# 注意：[ ! -d /etc ] 取反后为假，所以 || 后面的 echo 执行了
$ [ ! -d /etc ] || echo "不是目录"  # /etc 是目录，所以 [ -d /etc ] 为真
不是目录                           # ! 取反后为假，所以执行 || 后的命令
```

### 6.6 `[[ ]]` 增强版条件判断

```bash
# [[ ]] vs [ ] 的优势：
# 1. 支持 && || 在括号内部
# 2. 不需要对变量加引号（几乎没有单词分割）
# 3. 支持正则匹配 =~
# 4. 支持模式匹配 ==

# 1. 内部使用 && 和 ||
$ age=25
$ [[ $age -gt 18 && $age -lt 60 ]] && echo "成年人"
成年人

$ fruit="apple"
$ [[ $fruit == "apple" || $fruit == "banana" ]] && echo "水果是 apple 或 banana"
水果是 apple 或 banana

# 2. 变量即使包含空格也不需要引号
$ filename="my document.txt"
$ [[ -f $filename ]] && echo "文件存在"     # 不会出错
文件存在

# 3. 正则匹配 =~
$ str="hello123"
$ [[ $str =~ ^[a-z]+[0-9]+$ ]] && echo "匹配模式"
匹配模式

$ ip="192.168.1.100"
$ [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] && echo "IP 格式正确"
IP 格式正确

# 4. 模式匹配（通配符）
$ file="script.sh"
$ [[ $file == *.sh ]] && echo "是 Shell 脚本"
是 Shell 脚本
$ [[ $file == script.* ]] && echo "文件名以 script. 开头"
文件名以 script. 开头

# 5. 模式匹配不区分大小写
$ shopt -s nocasematch    # 开启不区分大小写
$ [[ "Hello" == "hello" ]] && echo "匹配"
匹配
$ shopt -u nocasematch    # 恢复

# 6. 数值比较可以用传统运算符
$ [[ 5 < 10 ]] && echo "5 < 10"
5 < 10
$ [[ 10 >= 5 ]] && echo "10 >= 5"
10 >= 5
```

---

## 七、分支结构

### 7.1 `if` 语句

```bash
# 基本语法
if [ condition ]; then
    commands
elif [ condition ]; then
    commands
else
    commands
fi
```

**示例1：成绩判断**

```bash
$ cat > grade.sh << 'EOF'
#!/bin/bash
read -p "请输入分数（0-100）: " score

if [ -z "$score" ]; then
    echo "错误：请输入分数！"
    exit 1
fi

if [ $score -ge 90 ]; then
    echo "等级: A（优秀）"
elif [ $score -ge 80 ]; then
    echo "等级: B（良好）"
elif [ $score -ge 70 ]; then
    echo "等级: C（中等）"
elif [ $score -ge 60 ]; then
    echo "等级: D（及格）"
else
    echo "等级: F（不及格）"
fi
EOF

$ chmod +x grade.sh
$ ./grade.sh
请输入分数（0-100）: 85
等级: B（良好）

$ ./grade.sh
请输入分数（0-100）: 58
等级: F（不及格）
```

**示例2：文件类型判断**

```bash
$ cat > check_file.sh << 'EOF'
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "用法: $0 <文件路径>"
    exit 1
fi

file="$1"

if [ ! -e "$file" ]; then
    echo "'$file' 不存在"
elif [ -f "$file" ]; then
    echo "'$file' 是一个普通文件"
    echo "  大小: $(stat -c %s "$file" 2>/dev/null || stat -f %z "$file") 字节"
    if [ -s "$file" ]; then
        echo "  内容预览: $(head -c 100 "$file")"
    else
        echo "  文件为空"
    fi
elif [ -d "$file" ]; then
    echo "'$file' 是一个目录"
    echo "  包含 $(ls -1 "$file" | wc -l) 个项目"
elif [ -L "$file" ]; then
    target=$(readlink -f "$file")
    echo "'$file' 是一个符号链接 → $target"
else
    echo "'$file' 是其他类型"
fi
EOF

$ chmod +x check_file.sh
$ ./check_file.sh /etc/passwd
'/etc/passwd' 是一个普通文件
  大小: 3027 字节
  内容预览: root:x:0:0:root:/root:/bin/bash...

$ ./check_file.sh /etc
'/etc' 是一个目录
  包含 247 个项目
```

### 7.2 `case` 语句

```bash
# 基本语法
case $var in
    pattern1)
        commands
        ;;
    pattern2|pattern3)
        commands
        ;;
    *)
        commands    # 默认分支
        ;;
esac
```

**示例1：系统服务管理菜单**

```bash
$ cat > service_control.sh << 'EOF'
#!/bin/bash
echo "=================================="
echo "  服务管理脚本"
echo "=================================="
echo "1) 启动 nginx"
echo "2) 停止 nginx"
echo "3) 重启 nginx"
echo "4) 查看 nginx 状态"
echo "5) 退出"
echo "=================================="
read -p "请选择操作 [1-5]: " choice

case $choice in
    1)
        echo "正在启动 nginx..."
        sudo systemctl start nginx
        echo "nginx 已启动"
        ;;
    2)
        echo "正在停止 nginx..."
        sudo systemctl stop nginx
        echo "nginx 已停止"
        ;;
    3)
        echo "正在重启 nginx..."
        sudo systemctl restart nginx
        echo "nginx 已重启"
        ;;
    4)
        echo "nginx 状态："
        systemctl status nginx --no-pager 2>/dev/null || echo "nginx 未安装或未运行"
        ;;
    5)
        echo "再见！"
        exit 0
        ;;
    *)
        echo "无效的选择: $choice"
        exit 1
        ;;
esac
EOF
```

**示例2：识别文件类型**

```bash
$ cat > identify_file.sh << 'EOF'
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "用法: $0 <文件名>"
    exit 1
fi

filename="$1"

case $filename in
    *.sh | *.bash)
        echo "Shell 脚本文件"
        ;;
    *.py)
        echo "Python 脚本文件"
        ;;
    *.js)
        echo "JavaScript 文件"
        ;;
    *.c)
        echo "C 语言源文件"
        ;;
    *.cpp | *.cxx | *.cc)
        echo "C++ 源文件"
        ;;
    *.java)
        echo "Java 源文件"
        ;;
    *.go)
        echo "Go 语言源文件"
        ;;
    *.rs)
        echo "Rust 源文件"
        ;;
    *.md | *.markdown)
        echo "Markdown 文档"
        ;;
    *.txt)
        echo "纯文本文档"
        ;;
    *.pdf)
        echo "PDF 文档"
        ;;
    *.jpg | *.jpeg | *.png | *.gif | *.svg | *.webp)
        echo "图片文件"
        ;;
    *.mp3 | *.wav | *.flac | *.ogg)
        echo "音频文件"
        ;;
    *.mp4 | *.mkv | *.avi | *.mov)
        echo "视频文件"
        ;;
    *.zip | *.tar | *.tar.gz | *.tar.bz2 | *.tar.xz | *.7z | *.rar)
        echo "压缩文件"
        ;;
    *)
        echo "未知文件类型: ${filename##*.}"
        ;;
esac
EOF

$ chmod +x identify_file.sh
$ ./identify_file.sh main.cpp
C++ 源文件
$ ./identify_file.sh document.pdf
PDF 文档
$ ./identify_file.sh unknown.xyz
未知文件类型: xyz
```

---

## 八、循环结构

### 8.1 `for` 循环

```bash
# 语法1：遍历列表
for var in item1 item2 item3 ...; do
    commands
done

# 语法2：C 风格
for ((初始化; 条件; 步进)); do
    commands
done
```

**示例1：基本遍历**

```bash
# 遍历给定值
$ for name in Alice Bob Charlie; do
>     echo "Hello, $name!"
> done
Hello, Alice!
Hello, Bob!
Hello, Charlie!

# 遍历范围
$ for i in {1..5}; do
>     echo "第 $i 次循环"
> done
第 1 次循环
第 2 次循环
第 3 次循环
第 4 次循环
第 5 次循环

# 带步长的范围
$ for i in {1..10..2}; do
>     echo $i
> done
1
3
5
7
9

# 遍历seq命令的输出
$ for i in $(seq 1 5); do
>     echo "序号: $i"
> done
序号: 1
序号: 2
序号: 3
序号: 4
序号: 5
```

**示例2：遍历文件**

```bash
# 遍历当前目录所有 .txt 文件
$ for file in *.txt; do
>     echo "处理: $file"
>     wc -l "$file"
> done
处理: notes.txt
42 notes.txt
处理: todo.txt
15 todo.txt

# 查找并处理匹配的文件
$ for file in $(find /var/log -name "*.log" -mtime -7); do
>     echo "最近修改的日志: $file"
> done

# 递归遍历（注意文件名中有空格的情况）
$ cat > find_big_files.sh << 'EOF'
#!/bin/bash
threshold_mb=100
echo "查找当前目录下大于 ${threshold_mb}MB 的文件:"

# 使用 find -print0 + while read 安全处理带空格的文件名
find . -type f -size +${threshold_mb}M -print0 | while IFS= read -r -d '' file; do
    size=$(du -h "$file" | cut -f1)
    echo "  $size  $file"
done
EOF

$ chmod +x find_big_files.sh
```

**示例3：C 风格 for 循环**

```bash
# C 风格的 for 循环
$ for ((i=0; i<5; i++)); do
>     echo "i = $i"
> done
i = 0
i = 1
i = 2
i = 3
i = 4

# 倒计时
$ cat > countdown.sh << 'EOF'
#!/bin/bash
read -p "请输入倒计时秒数: " seconds

for ((i=seconds; i>0; i--)); do
    echo -ne "倒计时: $i 秒 \r"
    sleep 1
done
echo "时间到！            "
EOF

$ chmod +x countdown.sh
$ ./countdown.sh
请输入倒计时秒数: 5
倒计时: 1 秒
时间到！
```

### 8.2 `while` 循环

```bash
# 当条件为真时循环
while [ condition ]; do
    commands
done
```

**示例1：计数器**

```bash
$ cat > counter.sh << 'EOF'
#!/bin/bash
count=1
while [ $count -le 5 ]; do
    echo "计数: $count"
    ((count++))
done
echo "循环结束！"
EOF

$ chmod +x counter.sh
$ ./counter.sh
计数: 1
计数: 2
计数: 3
计数: 4
计数: 5
循环结束！
```

**示例2：逐行读取文件**

```bash
$ cat > read_file.sh << 'EOF'
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "用法: $0 <文件名>"
    exit 1
fi

file="$1"
line_num=0

while IFS= read -r line; do
    ((line_num++))
    echo "第 $line_num 行: $line"
done < "$file"

echo "--- 共 $line_num 行 ---"
EOF

$ chmod +x read_file.sh
$ ./read_file.sh /etc/hostname
第 1 行: my-server
--- 共 1 行 ---
```

**示例3：无限循环 + 用户交互**

```bash
$ cat > menu_loop.sh << 'EOF'
#!/bin/bash
while true; do
    echo ""
    echo "=== 主菜单 ==="
    echo "1) 显示日期时间"
    echo "2) 显示磁盘使用"
    echo "3) 显示当前用户"
    echo "4) 退出"
    read -p "请选择 [1-4]: " choice

    case $choice in
        1) echo "$(date '+%Y-%m-%d %H:%M:%S')" ;;
        2) df -h / ;;
        3) whoami ;;
        4) echo "再见！"; break ;;
        *) echo "无效选择，请重试" ;;
    esac
done
EOF

$ chmod +x menu_loop.sh
```

**示例4：等待服务就绪（实用）**

```bash
$ cat > wait_service.sh << 'EOF'
#!/bin/bash
service="nginx"
max_wait=30
waited=0

echo "等待 $service 服务启动..."

while ! systemctl is-active --quiet "$service"; do
    sleep 1
    ((waited++))
    if [ $waited -ge $max_wait ]; then
        echo "超时！$service 在 ${max_wait}s 内未启动。"
        exit 1
    fi
    echo -ne "已等待 ${waited}s...\r"
done

echo ""
echo "$service 服务已就绪！(耗时 ${waited}s)"
EOF
```

### 8.3 `until` 循环

```bash
# 当条件为假时循环（即直到条件为真才退出）
until [ condition ]; do
    commands
done
```

```bash
# until 示例：等待文件出现
$ cat > wait_file.sh << 'EOF'
#!/bin/bash
target_file="/tmp/ready.flag"

echo "等待 $target_file 文件出现..."

until [ -f "$target_file" ]; do
    sleep 2
    echo -n "."
done

echo ""
echo "文件已出现，继续执行..."
# 在这里写后续逻辑
EOF

$ chmod +x wait_file.sh

# until 示例：密码验证
$ cat > password_until.sh << 'EOF'
#!/bin/bash
correct="secret123"

until [ "$input" = "$correct" ]; do
    read -s -p "请输入密码: " input
    echo ""
done

echo "密码正确！"
EOF

$ chmod +x password_until.sh
```

### 8.4 `break` 和 `continue`

```bash
# break：立即退出整个循环
$ for i in {1..10}; do
>     if [ $i -eq 5 ]; then
>         echo "遇到 5，退出循环"
>         break
>     fi
>     echo "数字: $i"
> done
数字: 1
数字: 2
数字: 3
数字: 4
遇到 5，退出循环

# continue：跳过当前本次循环，进入下一次
$ for i in {1..10}; do
>     if [ $i -eq 5 ] || [ $i -eq 7 ]; then
>         echo "跳过 $i"
>         continue
>     fi
>     echo "处理数字: $i"
> done
处理数字: 1
处理数字: 2
处理数字: 3
处理数字: 4
跳过 5
处理数字: 6
跳过 7
处理数字: 8
处理数字: 9
处理数字: 10

# break n：跳出 n 层循环
$ for i in {1..3}; do
>     for j in {a..c}; do
>         if [ $i -eq 2 ] && [ $j = "b" ]; then
>             echo "break 2 at i=$i, j=$j"
>             break 2
>         fi
>         echo "  i=$i, j=$j"
>     done
> done
  i=1, j=a
  i=1, j=b
  i=1, j=c
  i=2, j=a
break 2 at i=2, j=b
```

### 8.5 循环实战

**实战1：批量创建用户**

```bash
$ cat > batch_users.sh << 'EOF'
#!/bin/bash
# 从文件读取用户名列表，批量创建用户

user_file="users.txt"

# 创建示例用户列表文件
cat > "$user_file" << 'EOL'
zhangsan
lisi
wangwu
zhaoliu
EOL

echo "开始批量创建用户..."

while IFS= read -r username; do
    # 跳过空行和注释行
    [[ -z "$username" || "$username" =~ ^# ]] && continue

    if id "$username" &>/dev/null; then
        echo "  用户 $username 已存在，跳过"
    else
        sudo useradd -m -s /bin/bash "$username"
        echo "  用户 $username 创建成功"
        # 设置默认密码
        echo "${username}:password123" | sudo chpasswd
        echo "  密码已设置（请提醒用户首次登录修改！）"
    fi
done < "$user_file"

echo "批量创建完成！"
EOF
```

**实战2：遍历目录处理文件**

```bash
$ cat > process_files.sh << 'EOF'
#!/bin/bash
target_dir="${1:-.}"    # 默认为当前目录

if [ ! -d "$target_dir" ]; then
    echo "错误：'$target_dir' 不是有效目录"
    exit 1
fi

success_count=0
fail_count=0
total_size=0

echo "扫描目录: $target_dir"
echo "---"

find "$target_dir" -type f -name "*.log" -print0 | while IFS= read -r -d '' file; do
    file_size=$(stat -c '%s' "$file" 2>/dev/null || echo 0)
    echo "  处理: $file ($(numfmt --to=iec $file_size))"
    ((success_count++))
done

echo "---"
echo "处理完成: 成功 $success_count 个"
EOF
```

---

## 九、函数

### 9.1 定义函数

```bash
# 语法1（推荐）
function_name() {
    commands
    [return value]
}

# 语法2
function function_name {
    commands
    [return value]
}

# 简单示例
$ hello() {
>     echo "Hello, $1!"
> }

$ hello "World"
Hello, World!
$ hello "Linux"
Hello, Linux!
```

### 9.2 函数参数

```bash
$ cat > func_params.sh << 'EOF'
#!/bin/bash

show_params() {
    echo "函数名: $0         # 在函数内部，\$0 仍是脚本名"
    echo "参数1 (\$1): $1"
    echo "参数2 (\$2): $2"
    echo "全部参数 (\$@): $@"
    echo "参数个数 (\$#): $#"
}

echo "=== 调用函数 ==="
show_params apple banana cherry

echo ""
echo "=== 脚本参数（不受函数调用影响） ==="
echo "脚本 \$1: $1"
echo "脚本 \$2: $2"
EOF

$ chmod +x func_params.sh
$ ./func_params.sh script_arg1 script_arg2

=== 调用函数 ===
函数名: ./func_params.sh         # 在函数内部，$0 仍是脚本名
参数1 ($1): apple
参数2 ($2): banana
全部参数 ($@): apple banana cherry
参数个数 ($#): 3

=== 脚本参数（不受函数调用影响） ===
脚本 $1: script_arg1
脚本 $2: script_arg2
```

### 9.3 函数返回值

```bash
# return：返回退出码（0-255）
$ cat > func_return.sh << 'EOF'
#!/bin/bash

is_even() {
    if [ $(( $1 % 2 )) -eq 0 ]; then
        return 0    # 偶数，成功
    else
        return 1    # 奇数，失败
    fi
}

# 调用并用 $? 获取返回值
is_even 42
echo "42 是偶数吗？返回码: $?"      # 0

is_even 7
echo "7 是偶数吗？返回码: $?"       # 1

# 在条件判断中使用
if is_even 100; then
    echo "100 是偶数"
else
    echo "100 是奇数"
fi
EOF

$ chmod +x func_return.sh
$ ./func_return.sh
42 是偶数吗？返回码: 0
7 是偶数吗？返回码: 1
100 是偶数
```

**返回字符串**：用 `echo` + 命令替换

```bash
$ cat > func_echo.sh << 'EOF'
#!/bin/bash

# 函数通过 echo 返回字符串
get_file_ext() {
    local filename="$1"
    echo "${filename##*.}"
}

add() {
    local a=$1
    local b=$2
    echo $((a + b))
}

get_user_info() {
    local username="$1"
    # 返回多行信息
    echo "用户名: $username"
    echo "UID: $(id -u "$username" 2>/dev/null || echo 'N/A')"
    echo "Home: $(eval echo ~$username 2>/dev/null || echo 'N/A')"
}

# 用法1：命令替换获取结果
ext=$(get_file_ext "document.pdf")
echo "扩展名: $ext"

result=$(add 10 20)
echo "10 + 20 = $result"

# 用法2：获取多行输出
echo "--- 用户信息 ---"
info=$(get_user_info "root")
echo "$info"
EOF

$ chmod +x func_echo.sh
$ ./func_echo.sh
扩展名: pdf
10 + 20 = 30
--- 用户信息 ---
用户名: root
UID: 0
Home: /root
```

### 9.4 局部变量

```bash
$ cat > local_var_demo.sh << 'EOF'
#!/bin/bash

global_var="I am global"

test_local() {
    local local_var="I am local"
    global_var="I am modified global"
    echo "函数内: local_var = $local_var"
    echo "函数内: global_var = $global_var"
}

echo "=== 调用前 ==="
echo "global_var = $global_var"
echo "local_var = $local_var"     # 空（不存在）

echo ""
echo "=== 调用函数 ==="
test_local

echo ""
echo "=== 调用后 ==="
echo "global_var = $global_var"   # 已被函数修改
echo "local_var = $local_var"     # 仍是空，函数退出后局部变量消失
EOF

$ chmod +x local_var_demo.sh
$ ./local_var_demo.sh
=== 调用前 ===
global_var = I am global
local_var =

=== 调用函数 ===
函数内: local_var = I am local
函数内: global_var = I am modified global

=== 调用后 ===
global_var = I am modified global
local_var =
```

### 9.5 函数综合实战

```bash
$ cat > backup_script.sh << 'EOF'
#!/bin/bash

set -euo pipefail

SOURCE_DIR="${1:-.}"
BACKUP_DIR="${2:-./backup}"

# 函数：检查依赖
check_deps() {
    local deps=("tar" "gzip")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo "错误: 缺少必要命令 $dep"
            exit 1
        fi
    done
}

# 函数：创建备份目录
prepare_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "创建备份目录: $dir"
    fi
}

# 函数：生成备份名
generate_name() {
    local prefix="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    echo "${prefix}_${timestamp}.tar.gz"
}

# 函数：执行备份
do_backup() {
    local src="$1"
    local dest="$2"
    echo "正在备份 $src → $dest ..."
    tar -czf "$dest" -C "$(dirname "$src")" "$(basename "$src")"
    local size=$(du -h "$dest" | cut -f1)
    echo "备份完成！大小: $size"
    echo "备份文件: $dest"
}

# 函数：清理旧备份
cleanup_old() {
    local dir="$1"
    local keep_days="${2:-7}"
    echo "清理 ${keep_days} 天前的备份..."

    local deleted=0
    find "$dir" -name "*.tar.gz" -mtime "+$keep_days" -print0 | while IFS= read -r -d '' file; do
        echo "  删除: $file"
        rm -f "$file"
        ((deleted++))
    done
}

# 主流程
echo "=== 备份脚本 ==="
check_deps
prepare_dir "$BACKUP_DIR"

backup_name=$(generate_name "backup")
backup_path="${BACKUP_DIR}/${backup_name}"

do_backup "$SOURCE_DIR" "$backup_path"
cleanup_old "$BACKUP_DIR" 30

echo "=== 备份流程完成 ==="
EOF

$ chmod +x backup_script.sh
$ ./backup_script.sh /home/john/documents ./my_backups
=== 备份脚本 ===
创建备份目录: ./my_backups
正在备份 /home/john/documents → ./my_backups/backup_20260727_143015.tar.gz ...
备份完成！大小: 15M
备份文件: ./my_backups/backup_20260727_143015.tar.gz
清理 30 天前的备份...
  删除: ./my_backups/backup_20260601_120000.tar.gz
=== 备份流程完成 ===
```

---

## 十、调试技巧

### 10.1 命令行调试

```bash
# -x 选项：执行时打印每条命令（展开后的）
$ bash -x script.sh

# 示例
$ cat > debug_demo.sh << 'EOF'
#!/bin/bash
name="World"
for i in 1 2 3; do
    echo "Hello, $name! (第 $i 次)"
done
EOF

$ bash -x debug_demo.sh
+ name=World
+ for i in 1 2 3
+ echo 'Hello, World! (第 1 次)'
Hello, World! (第 1 次)
+ for i in 1 2 3
+ echo 'Hello, World! (第 2 次)'
Hello, World! (第 2 次)
+ for i in 1 2 3
+ echo 'Hello, World! (第 3 次)'
Hello, World! (第 3 次)

# -n 选项：只检查语法，不执行
$ bash -n script.sh    # 如果有语法错误会报告

# -v 选项：打印原始代码再执行
$ bash -v script.sh
```

### 10.2 脚本内局部调试

```bash
$ cat > debug_partial.sh << 'EOF'
#!/bin/bash

echo "=== 正常执行区域 ==="
name="Alice"
count=10

# 开启调试
set -x
echo "=== 调试区域开始 ==="
result=$((count * 2))
echo "计算结果: $result"
for i in 1 2 3; do
    echo "循环 $i"
done
set +x
# 关闭调试

echo "=== 恢复正常执行 ==="
echo "最终结果: 变量 name=$name, result=$result"
EOF

$ chmod +x debug_partial.sh
$ ./debug_partial.sh
=== 正常执行区域 ===
+ echo '=== 调试区域开始 ==='
=== 调试区域开始 ===
+ result=20
+ echo '计算结果: 20'
计算结果: 20
+ for i in 1 2 3
+ echo '循环 1'
循环 1
+ for i in 1 2 3
+ echo '循环 2'
循环 2
+ for i in 1 2 3
+ echo '循环 3'
循环 3
+ set +x
=== 恢复正常执行 ===
最终结果: 变量 name=Alice, result=20
```

### 10.3 Bash 安全选项

```bash
# set -e：任何命令失败则立即退出
$ cat > demo_set_e.sh << 'EOF'
#!/bin/bash
set -e

echo "第一步：成功"
echo "第二步：也成功"
false                       # 返回非零，导致脚本退出
echo "第三步：不会执行到这里"
EOF

$ chmod +x demo_set_e.sh
$ ./demo_set_e.sh
第一步：成功
第二步：也成功
                           # 脚本在 false 处退出

# set -u：使用未定义变量时报错
$ cat > demo_set_u.sh << 'EOF'
#!/bin/bash
set -u

defined_var="hello"
echo $defined_var
echo $undefined_var          # 这行会报错退出
EOF

$ ./demo_set_u.sh
hello
./demo_set_u.sh: line 6: undefined_var: unbound variable

# set -o pipefail：管道中任一命令失败即整体失败
$ cat > demo_pipefail.sh << 'EOF'
#!/bin/bash
# 默认情况下，管道只返回最后一个命令的退出码
false | true
echo "默认: \$? = $?"         # 0（最后一个命令 true 成功）

set -o pipefail
false | true
echo "pipefail: \$? = $?"    # 1（中间命令 false 失败）
EOF

$ chmod +x demo_pipefail.sh
$ ./demo_pipefail.sh
默认: $? = 0
pipefail: $? = 1
```

### 10.4 安全脚本头

```bash
# 推荐的安全脚本开头
#!/bin/bash
set -euo pipefail
# 或者
#!/bin/bash
set -e          # 遇错即停
set -u          # 未定义变量报错
set -o pipefail # 管道错误不隐藏

# 完整的安全脚本模板
#!/bin/bash
set -euo pipefail

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# 错误处理函数
error_exit() {
    log "错误: $1" >&2
    exit 1
}

# 清理函数（脚本退出时执行）
cleanup() {
    log "清理临时文件..."
    rm -f /tmp/my_script_*.tmp
}
trap cleanup EXIT

# --- 主逻辑 ---
log "脚本开始执行"
```

### 10.5 其他调试技巧

```bash
# 1. 使用 $LINENO 输出行号
echo "当前行号: $LINENO"

# 2. 自定义 PS4 调试前缀（默认是 "+"）
export PS4='+ ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
bash -x script.sh    # 输出包含文件名、行号、函数名

# 3. 使用 trap 捕获错误位置
trap 'echo "错误发生在第 $LINENO 行，退出码: $?"' ERR

# 4. 打印变量值（最朴素的调试方法）
echo "DEBUG: name=$name, count=$count" >&2  # 输出到 stderr

# 5. 使用 bash -xv 组合打印最详细信息
bash -xv script.sh

# 6. 使用 shellcheck 静态检查（需要安装）
shellcheck script.sh    # 检查常见错误
```

---

## 十一、综合实战脚本

### 11.1 系统信息收集脚本

```bash
$ cat > sysinfo.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

separator() {
    echo "============================================"
}

section() {
    echo ""
    echo -e "${GREEN}${1}${NC}"
    separator
}

# ----- CPU 信息 -----
section "CPU 信息"
echo "型号:   $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
echo "核心数: $(nproc) 核"
echo "架构:   $(uname -m)"
echo "负载:   $(uptime | awk -F'load average:' '{print $2}' | xargs)"

# ----- 内存信息 -----
section "内存信息"
mem_info=$(free -h | grep '^Mem:')
total_mem=$(echo "$mem_info" | awk '{print $2}')
used_mem=$(echo "$mem_info" | awk '{print $3}')
free_mem=$(echo "$mem_info" | awk '{print $4}')
usage_percent=$(free | grep '^Mem:' | awk '{printf "%.1f", $3/$2*100}')
echo "总内存:   $total_mem"
echo "已用:     $used_mem"
echo "空闲:     $free_mem"
echo "使用率:   ${usage_percent}%"

# 内存使用率告警
if (( $(echo "$usage_percent > 90" | bc -l 2>/dev/null || echo 0) )); then
    echo -e "${RED}⚠ 警告：内存使用率超过 90%！${NC}"
elif (( $(echo "$usage_percent > 70" | bc -l 2>/dev/null || echo 0) )); then
    echo -e "${YELLOW}⚠ 注意：内存使用率超过 70%${NC}"
fi

# Swap 信息
swap_info=$(free -h | grep '^Swap:')
if [ -n "$swap_info" ]; then
    swap_used=$(echo "$swap_info" | awk '{print $3}')
    echo "Swap 已用: $swap_used"
fi

# ----- 磁盘信息 -----
section "磁盘信息"
echo "挂载点           容量    已用    可用    使用率"
df -h | grep '^/dev/' | while read -r line; do
    device=$(echo "$line" | awk '{print $1}')
    size=$(echo "$line" | awk '{print $2}')
    used=$(echo "$line" | awk '{print $3}')
    avail=$(echo "$line" | awk '{print $4}')
    use_pct=$(echo "$line" | awk '{print $5}')
    mount=$(echo "$line" | awk '{print $6}')
    printf "%-15s %-7s %-7s %-7s %-6s %s\n" "$device" "$size" "$used" "$avail" "$use_pct" "$mount"

    # 磁盘使用率告警
    pct_num="${use_pct//%/}"
    if [ "$pct_num" -gt 90 ] 2>/dev/null; then
        echo -e "  ${RED}⚠ 磁盘空间不足！${NC}"
    fi
done

# ----- 网络信息 -----
section "网络信息"
hostname=$(hostname)
echo "主机名:   $hostname"

# 获取 IP 地址
for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v lo); do
    ip_addr=$(ip -o -4 addr show "$iface" 2>/dev/null | awk '{print $4}' || echo "无 IP")
    echo "  接口 $iface: $ip_addr"
done

# DNS
echo "DNS:"
grep 'nameserver' /etc/resolv.conf 2>/dev/null | awk '{print "  " $2}' || echo "  无法读取"

# 默认网关
echo "默认网关: $(ip route show default 2>/dev/null | awk '{print $3}' || echo 'N/A')"

# ----- 系统信息 -----
section "系统信息"
echo "操作系统: $(cat /etc/os-release 2>/dev/null | grep '^PRETTY_NAME' | cut -d'"' -f2 || uname -o)"
echo "内核版本: $(uname -r)"
echo "运行时间: $(uptime -p 2>/dev/null | sed 's/up //' || uptime | awk -F',' '{print $1}' | sed 's/.*up //')"
echo "当前用户: $(whoami)"
echo "在线用户: $(who | wc -l) 人"

# ----- 进程信息 -----
section "进程信息"
echo "总进程数: $(ps aux --no-headers 2>/dev/null | wc -l || ps aux | tail -n +2 | wc -l)"
echo "僵尸进程: $(ps aux 2>/dev/null | grep -c '[d]efunct' || echo 0)"

# CPU Top 5 进程
echo ""
echo "CPU 占用 Top 5 进程:"
ps aux --sort=-%cpu 2>/dev/null | head -6 | tail -5 | awk '{printf "  PID:%-8s CPU:%-6s MEM:%-6s %s\n", $2, $3"%", $4"%", $11}' || echo "  不支持"

echo ""
echo -e "${GREEN}=== 系统信息收集完成 ===${NC}"
echo "报告生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
EOF

$ chmod +x sysinfo.sh
$ ./sysinfo.sh

CPU 信息
============================================
型号:   Intel(R) Core(TM) i7-10750H CPU @ 2.60GHz
核心数: 12 核
架构:   x86_64
负载:   1.23, 0.89, 0.72

内存信息
============================================
总内存:   15Gi
已用:     5.2Gi
空闲:     9.8Gi
使用率:   34.7%
Swap 已用: 0B

磁盘信息
============================================
挂载点           容量    已用    可用    使用率
/dev/sda2        234G    98G     124G    44%    /
/dev/sda1        511M    6.1M    505M    2%    /boot/efi

网络信息
============================================
主机名:   my-server
  接口 eth0: 192.168.1.100/24
DNS:
  8.8.8.8
  114.114.114.114
默认网关: 192.168.1.1

系统信息
============================================
操作系统: Ubuntu 22.04.3 LTS
内核版本: 5.15.0-91-generic
运行时间: 5 days, 3 hours, 12 minutes
当前用户: john
在线用户: 1 人

进程信息
============================================
总进程数: 312
僵尸进程: 0

CPU 占用 Top 5 进程:
  PID:12345   CPU:15.2% MEM:2.1%   chrome
  PID:23456   CPU:8.7%  MEM:1.5%   node
  PID:3456    CPU:5.1%  MEM:0.8%   mysqld
  PID:4567    CPU:3.2%  MEM:1.2%   gnome-shell
  PID:5678    CPU:2.1%  MEM:0.5%   python3

=== 系统信息收集完成 ===
报告生成时间: 2026-07-27 14:30:25
```

### 11.2 日志清理脚本

```bash
$ cat > log_cleaner.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# ===== 配置区 =====
LOG_DIR="${1:-/var/log}"     # 日志目录，默认 /var/log
RETENTION_DAYS="${2:-30}"    # 保留天数，默认 30 天
DRY_RUN="${3:-false}"        # 干跑模式（只查看不删除）

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ===== 函数定义 =====

usage() {
    echo "用法: $0 [日志目录] [保留天数] [--dry-run]"
    echo "示例:"
    echo "  $0                          # 清理 /var/log 下 30 天前的日志"
    echo "  $0 /opt/myapp/logs 7        # 清理 /opt/myapp/logs 下 7 天前的日志"
    echo "  $0 /var/log 30 --dry-run    # 干跑模式，仅查看不删除"
    exit 1
}

convert_size() {
    local bytes=$1
    if [ "$bytes" -lt 1024 ]; then
        echo "${bytes}B"
    elif [ "$bytes" -lt $((1024 * 1024)) ]; then
        echo "$((bytes / 1024))KB"
    elif [ "$bytes" -lt $((1024 * 1024 * 1024)) ]; then
        echo "$((bytes / 1024 / 1024))MB"
    else
        echo "$((bytes / 1024 / 1024 / 1024))GB"
    fi
}

is_safe_dir() {
    local dir="$1"
    local safe_dirs=("/var/log" "/tmp" "/opt" "/home")
    for safe in "${safe_dirs[@]}"; do
        [[ "$dir" == "$safe" || "$dir" == "$safe/"* ]] && return 0
    done
    return 1
}

# ===== 参数检查 =====

# 检查是否指定了 --dry-run
for arg in "$@"; do
    if [ "$arg" = "--dry-run" ] || [ "$arg" = "-n" ]; then
        DRY_RUN="true"
        break
    fi
done

# 验证日志目录
if [ ! -d "$LOG_DIR" ]; then
    echo -e "${RED}错误: 目录 '$LOG_DIR' 不存在${NC}"
    exit 1
fi

# 安全检查：只允许在安全路径下删除
if ! is_safe_dir "$LOG_DIR"; then
    echo -e "${RED}错误: '$LOG_DIR' 不在允许的清理路径中${NC}"
    echo "  允许的路径: /var/log /tmp /opt /home"
    exit 1
fi

# 验证保留天数
if ! [[ "$RETENTION_DAYS" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}错误: 保留天数必须是正整数${NC}"
    exit 1
fi

if [ "$RETENTION_DAYS" -lt 1 ]; then
    echo -e "${RED}错误: 保留天数至少为 1${NC}"
    exit 1
fi

# ===== 执行清理 =====

echo "============================================"
echo "  日志清理脚本"
echo "============================================"
echo "目标目录:   $LOG_DIR"
echo "保留天数:   $RETENTION_DAYS 天"
echo "模式:       $([ "$DRY_RUN" = "true" ] && echo '干跑（仅查看）' || echo '实际删除')"
echo "当前时间:   $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================"
echo ""

# 查找符合条件的文件
temp_file=$(mktemp)
find "$LOG_DIR" -type f \( -name "*.log" -o -name "*.log.*" -o -name "*.gz" \) \
    -mtime "+${RETENTION_DAYS}" > "$temp_file" 2>/dev/null || true

total_files=$(wc -l < "$temp_file")

if [ "$total_files" -eq 0 ]; then
    echo "没有找到 $RETENTION_DAYS 天前的日志文件。"
    rm -f "$temp_file"
    exit 0
fi

echo "找到 $total_files 个 $RETENTION_DAYS 天前的文件"
echo ""

# 计算总大小
total_bytes=0
file_list=()
while IFS= read -r file; do
    if [ -f "$file" ]; then
        size=$(stat -c '%s' "$file" 2>/dev/null || echo 0)
        total_bytes=$((total_bytes + size))
        file_list+=("$file")
    fi
done < "$temp_file"

echo "预计释放空间: $(convert_size $total_bytes)"
echo ""

if [ "$DRY_RUN" = "true" ]; then
    echo "--- [干跑模式] 以下文件将被删除 ---"
    head -20 "$temp_file" | while IFS= read -r file; do
        size=$(stat -c '%s' "$file" 2>/dev/null || echo 0)
        echo "  $(convert_size $size)  $file"
    done
    if [ "$total_files" -gt 20 ]; then
        echo "  ...（还有 $((total_files - 20)) 个文件未显示）"
    fi
    echo ""
    echo "干跑完成！实际运行请去掉 --dry-run 参数。"
else
    echo "--- 开始清理 ---"
    deleted=0
    failed=0
    freed_bytes=0

    while IFS= read -r file; do
        if [ -f "$file" ]; then
            size=$(stat -c '%s' "$file" 2>/dev/null || echo 0)
            if rm -f "$file" 2>/dev/null; then
                ((deleted++))
                freed_bytes=$((freed_bytes + size))
                echo "  [OK]  $file"
            else
                ((failed++))
                echo -e "  ${RED}[FAIL]${NC} $file" >&2
            fi
        fi
    done < "$temp_file"

    echo ""
    echo "--- 清理完成 ---"
    echo -e "${GREEN}成功删除: $deleted 个文件${NC}"
    echo -e "释放空间: $(convert_size $freed_bytes)"
    if [ $failed -gt 0 ]; then
        echo -e "${RED}删除失败: $failed 个文件${NC}"
    fi

    # 清理空目录
    echo ""
    echo "检查并清理空日志目录..."
    find "$LOG_DIR" -type d -empty -delete 2>/dev/null || true
    echo "完成"
fi

rm -f "$temp_file"
echo ""
echo "============================================"
echo "  日志清理完成"
echo "============================================"
EOF

$ chmod +x log_cleaner.sh

# 干跑测试（不实际删除）
$ ./log_cleaner.sh /var/log 30 --dry-run
============================================
  日志清理脚本
============================================
目标目录:   /var/log
保留天数:   30 天
模式:       干跑（仅查看）
当前时间:   2026-07-27 14:30:30
============================================

找到 47 个 30 天前的文件

预计释放空间: 156MB

--- [干跑模式] 以下文件将被删除 ---
  12MB  /var/log/syslog.1
  8MB  /var/log/kern.log.1
  5MB  /var/log/auth.log.1
  5MB  /var/log/nginx/access.log.10.gz
  ...（还有 27 个文件未显示）

干跑完成！实际运行请去掉 --dry-run 参数。

============================================
  日志清理完成
============================================

# 实际执行
$ sudo ./log_cleaner.sh /var/log 30
...
--- 清理完成 ---
成功删除: 47 个文件
释放空间: 156MB
```

### 11.3 服务监控与自动重启脚本

```bash
$ cat > service_monitor.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# ===== 配置 =====
SERVICE_NAME="${1:-nginx}"                    # 监控的服务名
CHECK_INTERVAL="${2:-10}"                     # 检查间隔（秒）
MAX_RESTART_ATTEMPTS="${3:-3}"                # 最大重启次数
NOTIFY_EMAIL="${4:-}"                         # 通知邮箱（可选）
LOG_FILE="/var/log/service_monitor_${SERVICE_NAME}.log"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# ===== 函数定义 =====

log() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $msg" | tee -a "$LOG_FILE"
}

log_info()  { log "INFO"  "$@"; }
log_warn()  { log "WARN"  "$@"; }
log_error() { log "ERROR" "$@"; }

# 检查服务状态
check_service() {
    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# 获取服务详情
get_service_details() {
    echo "服务名称: $SERVICE_NAME"
    echo "服务描述: $(systemctl show "$SERVICE_NAME" -p Description --value 2>/dev/null || echo 'N/A')"
    echo "PID: $(systemctl show "$SERVICE_NAME" -p MainPID --value 2>/dev/null || echo 'N/A')"
    echo "运行时间: $(systemctl show "$SERVICE_NAME" -p ActiveEnterTimestamp --value 2>/dev/null || echo 'N/A')"
    echo "内存使用: $(systemctl show "$SERVICE_NAME" -p MemoryCurrent --value 2>/dev/null || echo 'N/A') bytes"
}

# 发送通知
send_notification() {
    local subject="$1"
    local body="$2"

    if [ -n "$NOTIFY_EMAIL" ] && command -v mail &>/dev/null; then
        echo "$body" | mail -s "$subject" "$NOTIFY_EMAIL"
        log_info "已发送邮件通知到 $NOTIFY_EMAIL"
    fi

    # 也发送桌面通知（如果有 notify-send）
    if command -v notify-send &>/dev/null && [ -n "$DISPLAY" ]; then
        notify-send -u critical "$subject" "$body"
    fi

    # 写入系统日志
    logger -t "service_monitor" "$subject: $body"
}

# 重启服务
restart_service() {
    log_warn "正在重启 $SERVICE_NAME..."
    if sudo systemctl restart "$SERVICE_NAME" 2>/dev/null; then
        sleep 3
        if check_service; then
            log_info "$SERVICE_NAME 重启成功！"
            return 0
        else
            log_error "$SERVICE_NAME 重启后仍无法启动！"
            return 1
        fi
    else
        log_error "$SERVICE_NAME 重启命令执行失败"
        return 1
    fi
}

# 应用启动（首次尝试，如果服务已停止）

# 处理中断信号
cleanup() {
    log_info "监控脚本退出"
    echo ""
}
trap cleanup EXIT INT TERM

# ===== 参数验证 =====

if ! command -v systemctl &>/dev/null; then
    echo -e "${RED}错误: 此脚本需要 systemd 系统${NC}"
    exit 1
fi

# 检查服务是否存在
if ! systemctl list-unit-files "$SERVICE_NAME.service" &>/dev/null; then
    log_warn "服务 $SERVICE_NAME 可能未安装，将继续监控"
fi

# ===== 主监控循环 =====

echo "============================================"
echo "  服务监控脚本"
echo "============================================"
echo -e "监控服务: ${BLUE}$SERVICE_NAME${NC}"
echo "检查间隔: ${CHECK_INTERVAL}s"
echo "最大重启: ${MAX_RESTART_ATTEMPTS} 次"
echo "日志文件: $LOG_FILE"
echo -e "通知邮箱: ${NOTIFY_EMAIL:-未设置}"
echo "============================================"
echo ""

log_info "服务监控脚本启动"
log_info "监控目标: $SERVICE_NAME"

restart_count=0
health_count=0
fail_count=0

if check_service; then
    echo -e "初始状态: ${GREEN}运行中 ✓${NC}"
    log_info "$SERVICE_NAME 初始状态: 运行中"
else
    echo -e "初始状态: ${RED}已停止 ✗${NC}"
    log_warn "$SERVICE_NAME 初始状态: 已停止，尝试启动..."
    if restart_service; then
        restart_count=$((restart_count + 1))
    fi
fi

echo ""
echo "进入监控模式（按 Ctrl+C 退出）..."
echo ""

while true; do
    sleep "$CHECK_INTERVAL"

    if check_service; then
        health_count=$((health_count + 1))
        # 每 10 次健康检查输出一次状态
        if [ $((health_count % 10)) -eq 0 ]; then
            echo -e "[$(date '+%H:%M:%S')] ${GREEN}✓${NC} $SERVICE_NAME 运行正常 (已检查 $health_count 次)"
        fi
    else
        fail_count=$((fail_count + 1))
        echo -e "[$(date '+%H:%M:%S')] ${RED}✗${NC} $SERVICE_NAME 已停止！"

        if [ $restart_count -ge $MAX_RESTART_ATTEMPTS ]; then
            body="服务 $SERVICE_NAME 已连续停止 $fail_count 次，达到最大重启次数 ($MAX_RESTART_ATTEMPTS)，不再自动重启。

时间: $(date)
主机: $(hostname)
"
            log_error "$body"
            send_notification "[告警] $SERVICE_NAME 无法恢复 - $(hostname)" "$body"
            echo ""
            echo -e "${RED}=============================================="
            echo "  已达到最大重启次数，请手动介入！"
            echo -e "==============================================${NC}"
            exit 1
        fi

        log_warn "$SERVICE_NAME 已停止，第 $((restart_count + 1)) 次尝试重启..."

        # 收集诊断信息
        service_log=$(journalctl -u "$SERVICE_NAME" --no-pager -n 20 2>/dev/null || echo "无法获取日志")

        body="服务 $SERVICE_NAME 已停止，正在尝试自动重启。

时间: $(date)
主机: $(hostname)
重启尝试: $((restart_count + 1))/$MAX_RESTART_ATTEMPTS

最近日志:
$service_log
"
        log_warn "$body"
        send_notification "[告警] $SERVICE_NAME 已停止 - $(hostname)" "$body"

        if restart_service; then
            restart_count=$((restart_count + 1))
            body="服务 $SERVICE_NAME 已成功重启。

时间: $(date)
主机: $(hostname)
累计重启次数: $restart_count/$MAX_RESTART_ATTEMPTS
"
            send_notification "[恢复] $SERVICE_NAME 已恢复 - $(hostname)" "$body"
        else
            restart_count=$((restart_count + 1))
        fi
    fi
done
EOF

$ chmod +x service_monitor.sh

# 启动监控
$ sudo ./service_monitor.sh nginx 5
============================================
  服务监控脚本
============================================
监控服务: nginx
检查间隔: 5s
最大重启: 3 次
日志文件: /var/log/service_monitor_nginx.log
通知邮箱: 未设置
============================================

初始状态: 运行中 ✓

进入监控模式（按 Ctrl+C 退出）...

[14:30:00] ✓ nginx 运行正常 (已检查 10 次)
[14:30:50] ✓ nginx 运行正常 (已检查 20 次)
[14:31:25] ✗ nginx 已停止！
[2026-07-27 14:31:25] [WARN] nginx 已停止，第 1 次尝试重启...
[2026-07-27 14:31:25] [WARN] 正在重启 nginx...
[2026-07-27 14:31:28] [INFO] nginx 重启成功！
^C
[2026-07-27 14:31:30] [INFO] 监控脚本退出
```

---

## 十二、总结

本章全面介绍了 Bash Shell 脚本编程的核心知识：

| 知识点 | 关键内容 |
|--------|---------|
| Shell 基础 | Shell 是命令解释器，bash 是最常用的 Shell |
| 变量 | 定义无空格、`$()` 命令替换、`$?` 退出码 |
| 特殊变量 | `$0`~`$9`, `$#`, `$@`, `$$` |
| 字符串操作 | 引号区别、拼接、长度、子串、替换 |
| 数组 | 定义、访问、遍历、关联数组 |
| 条件判断 | `test`/`[ ]`, 数值/字符串/文件测试, `[[ ]]` |
| 分支结构 | `if-elif-else`, `case` 多分支 |
| 循环结构 | `for`, `while`, `until`, `break`, `continue` |
| 函数 | 定义、参数、返回值、局部变量 |
| 调试技巧 | `bash -x`, `set -x`, `set -euo pipefail` |
| 安全脚本 | `set -euo pipefail` + `trap` + 日志函数 |

掌握 Shell 脚本编程后，你可以：
- 自动化日常运维任务
- 编写系统监控和告警脚本
- 批量处理文件和目录
- 创建自动化部署工具
- 定制开发工作流

---

## 习题与实践

### 基础题

1. 编写脚本 `greet.sh`，接收一个用户名参数，输出 `Hello, <用户名>!`；如果没有提供参数，输出 `Hello, World!`

2. 编写脚本 `calculator.sh`，实现加减乘除四则运算：
   ```bash
   ./calculator.sh add 10 5    # 输出 15
   ./calculator.sh mul 3 7     # 输出 21
   ```

3. 编写脚本 `file_check.sh`，接收一个文件路径参数，判断该文件是否存在、是文件还是目录、是否可读写执行。

   **答案示例：**
   ```bash
   #!/bin/bash
   if [ $# -eq 0 ]; then
       echo "用法: $0 <文件路径>"
       exit 1
   fi
   f="$1"
   [ -e "$f" ] && echo "存在" || { echo "不存在"; exit 1; }
   [ -f "$f" ] && echo "是普通文件"
   [ -d "$f" ] && echo "是目录"
   [ -r "$f" ] && echo "可读"
   [ -w "$f" ] && echo "可写"
   [ -x "$f" ] && echo "可执行"
   ```

### 进阶题

4. 编写脚本 `backup.sh`，将指定目录压缩备份并按日期命名：
   ```bash
   ./backup.sh /home/john/projects /backup
   # 生成 /backup/projects_20260727_143000.tar.gz
   ```
   额外要求：
   - 使用函数组织代码
   - 检查源目录是否存在
   - 自动创建备份目录
   - 显示备份文件大小

5. 编写脚本 `batch_rename.sh`，批量重命名当前目录文件：
   ```bash
   ./batch_rename.sh .txt .md    # 将所有 .txt 重命名为 .md
   ./batch_rename.sh -p "IMG_"  "Photo_"  # 将 IMG_ 前缀替换为 Photo_
   ```
   提示：使用 `case` 判断操作模式。

6. 编写脚本 `monitor.sh`，监控 CPU 和内存使用率：
   - 每 5 秒采样一次
   - 当 CPU 使用率超过 80% 或内存使用率超过 90%，输出警告
   - 记录到日志文件
   - 支持 `-t` 参数指定监控时长

### 综合题

7. 编写脚本 `deploy.sh`，实现一个简单的应用部署流程：
   ```bash
   ./deploy.sh --source ./myapp --target /opt/myapp --backup
   ```
   功能要求：
   - `--source` 指定源码目录
   - `--target` 指定部署目标目录
   - `--backup` 在部署前先备份旧版本
   - 部署前检查服务是否运行，若运行则先停止
   - 部署后重启服务
   - 使用 `set -euo pipefail` 确保安全
   - 记录完整的部署日志

8. 编写脚本 `log_analyzer.sh`，分析 Web 服务器日志：
   ```bash
   ./log_analyzer.sh /var/log/nginx/access.log
   ```
   功能要求：
   - 统计总请求数
   - 统计各 HTTP 状态码的数量
   - 找出访问量 Top 10 的 IP
   - 找出访问量 Top 10 的 URL
   - 统计平均响应时间
   - 输出格式化的分析报告

> **提示**：参考 [[07-Shell脚本基础|本章]] 的综合实战示例和调试技巧，遇到问题先用 `bash -x` 调试。
