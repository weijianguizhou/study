# 01-05 Qt Creator使用指南

## 概念解释

### Qt Creator功能概览

Qt Creator是Qt官方的集成开发环境（IDE），提供：

- **代码编辑器**：语法高亮、代码补全、代码折叠
- **项目管理**：创建、构建、运行项目
- **可视化设计**：Qt Designer集成
- **调试工具**：断点、变量查看、调用栈
- **版本控制**：Git、SVN集成
- **分析工具**：性能分析、内存分析

### 常用快捷键

| 快捷键 | 功能 |
|--------|------|
| Ctrl+N | 新建文件 |
| Ctrl+R | 运行项目 |
| Ctrl+B | 构建项目 |
| F5 | 开始/继续调试 |
| F9 | 设置/取消断点 |
| Ctrl+/ | 注释/取消注释 |
| Ctrl+Shift+R | 重命名符号 |
| Ctrl+K | 快速打开文件 |
| F1 | 查看帮助 |
| Ctrl+Shift+F | 全局搜索 |

### 构建模式

| 模式 | 说明 | 用途 |
|------|------|------|
| Debug | 包含调试信息 | 开发调试 |
| Release | 优化代码 | 发布程序 |
| Profile | 性能分析 | 性能优化 |

## 代码示例

### 使用Qt Creator创建项目

1. 文件 → 新建文件或项目
2. 选择项目类型：Application → Qt Widgets Application
3. 配置项目名称和路径
4. 选择编译器和工具包
5. 创建主窗口类
6. 完成项目创建

### 快速创建类

在项目上右键 → Add New → C++ Class

`cpp
// 自动生成的类模板
#ifndef MYCLASS_H
#define MYCLASS_H

#include <QObject>

class MyClass : public QObject
{
    Q_OBJECT
    
public:
    explicit MyClass(QObject *parent = nullptr);
    
signals:
    
public slots:
    
};

#endif // MYCLASS_H
`

## 注意事项

1. 定期清理构建目录
2. 使用Shadow Build避免污染源码目录
3. 配置合适的代码风格
4. 善用代码片段功能

## 练习题

1. 熟悉Qt Creator的界面布局
2. 使用快捷键提高开发效率
3. 配置代码编辑器的字体和颜色

