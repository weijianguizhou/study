# TensorFlow简介
##  TensorFlow是什么
TensorFlow是深度学习领域使用最为广泛的一个Google的开源软件库（最初由Google brain team进行开发的内部库，由于它的易用性Google决定把它开源出来）.

采取数据流图，用于数值计算.

- 节点——处理数据

- 线——节点间的输入输出关系

数据流图中的数据叫做tensor, 表示张量, 即N维数据, tensor在数据流图中流动表示计算的过程, 这也是tensorflow名字的由来.

## TensorFlow核心概念
- 图（Graph）：图是TensorFlow中表达计算逻辑的基本方式。图由节点（Nodes）和边（Edges）组成，节点表示操作或数据，边表示张量之间的依赖关系。通过构建图，可以将复杂的计算过程分解为一系列简单的子任务，每个子任务由一个节点表示。

- 张量（Tensor）：张量是一个多维数组，可以看作是标量、向量、矩阵和更高维度的扩展。在TensorFlow中，张量是各种数据类型的核心，包括数值数据、图像、音频等。张量的维度和形状可以根据实际应用场景进行调整。

- 操作（Operation）：操作是图中的节点，表示对张量进行的某种计算。每个操作都有一个输入和一个输出，输入和输出都是张量。例如，矩阵乘法、加法、减法等都是操作。在定义操作时，需要指定输入和输出的张量以及相关的参数。

- 会话（Session）：其作用是分配CPU或GPU资源来运行一张图Graph。一个会话Session的目的简单来说就是操作Operation的执行和张量Tensor的计算。需要注意的是，TensorFlow2.0版本后已经取消了Session模块，并且不需要新建图Graph再新建会话Session来运行 。

如图所示，张量[5, 3]进入节点a，分别流向了节点b、c进行prod和sum两个操作，结果15和8又同时流入节点d进行add操作，最后输出结果23。由此发现，图Graph实际上是一个由数据流图表示的计算过程，即张量Tensor在图Graph中的流动过程。而每一个节点则对应一个操作Operation。
![[TensorFlow计算流程示意图.png]]
包括生成张量Tensor在内，上图包括abcd四个操作，代码表示为：
```python
import tensorflow as tf
a = tf.constant([5, 3], name='input_a')
b = tf.reduce_prod(a, name='prod_b')
c = tf.reduce_sum(a, name='sum_c')
d = tf.add(b, c, name='add_d')
```
## 张量
张量（Tensor）是一个广义上的多维数组，维度可以是0、1、2等整数，它能够容纳任意类型的数据，如整数、浮点数、布尔值、字符串等。
```python
improt tensorflow as tf
a=tf.constant(1)#0维张量
a=tf.constant([1.1,1.2,1.3])#1维张量
a=tf.constant([1,2],[3,4])#2维张量
a=tf.constant([[[1,2],[3,4]],[[5,6],[7,8]]])#3维张量
```
张量对象可以通过多种方式创建，例如使用tf.constant()、tf.Variable()、tf.placeholder()等函数，或者通过一些运算间接创建。

虽然张量等同于多维数组，但是在python语言中张量和数组的表现形式还是有所区别的。
```python
import tensorflow as tf
import numpy as np
a = np.arange(0, 5)
b = tf.convert_to_tensor(a, dtype=tf.int64)
print(a)
print(b)

# 运行结果
[0 1 2 3 4]
tf.Tensor([0 1 2 3 4], shape=( 5 , ), dtype=int64)
```
## 模型

机器学习模型训练涉及到三个核心概念：数学模型、损失函数、优化算法。

**数学模型**

数学模型通常是指一个将输入数据映射到预测输出的模型。它不是一个预先定义好的固定函数，而是从历史数据中推导出来的。当输入不同的数据时，机器学习算法的输出会发生变化，即机器学习模型发生改变。常见的模型包括监督学习模型：线性回归、多元回归、决策树等；无监督模型：聚类模型K-means，降维模型PCA等。

**损失函数**

损失函数（loss function）是用来估量模型预测值与真实值之间不一致程度的一个非负实值函数。通常使用L(Y, f(x))来表示，其中Y是真实值，f(x)是模型的预测值。损失函数越小，模型的准确性越好。常用的损失函数包括：均方误差损失函数，绝对值损失函数等。

**优化算法**

优化算法的作用是更新模型中的参数，按照一定的学习率逐步调整参数，使得损失函数逐渐达到最小值。优化算法应用比较广泛的是梯度下降优化算法，例如SGD、Momentum、Adam等。

**举例**

以线性回归为例，对于一些随机样本点，我们用一条直线来拟合它们的走势。我们选择用一元一次函数y=wx+b来表示这条直线，这个函数就是我们建立的数学模型。有人可能会质疑为什么要选择直线，而不是曲线，我会说都是可以的，我们的目的是让建立的数学模型更好的拟合样本数据点，如果数据点的走势恰好类似对数函数，那我们就用对数函数来建立模型。既然我们这里选择用直线来建模，那么我们的目的就是确定直线中的参数w和b，找到一条最佳逼近直线。如何衡量最佳逼近效果呢？这里就涉及到一个损失函数的概念，让真实值和预估值之间的差达到整体最小值。在计算损失函数的过程中，通常我们会先随机确定一个w和b，计算一个损失值，然后再调整w，b值，再计算一个损失值，通过比较损失值的大小，不断地调整w，b值最终让损失值达到最小值，这时的w，b值就是我们得到的最佳逼近直线。那么如何调整w，b值，让损失函数越来越小呢，这里就涉及到了优化算法，越优秀的优化算法得到的直线逼近效果越好。

部分代码示例

```python
#直线函数模型
def linear_regression(x):
    return W * x + b

#损失函数
def mean_square(y_pred,y_true):
    return tf.reduce_sum(tf.pow(y_pred-y_true,2)) / (2 * n_samples)

#梯度下降优化算法
optimizer = tf.optimizers.SGD(learning_rate)
#赋予w，b随机值
W = tf.Variable(rng.randn(),name="weight")
b = tf.Variable(rng.randn(),name="bias")
gradients = g.gradient(loss,[W,b])
#调整w，b值
optimizer.apply_gradients(zip(gradients,[W,b]))
```


## TensorFlow示例

示例代码为线性回归模型训练代码，采用TensorFlow2.0语法，代码来源：[腾讯云示例](https://link.zhihu.com/?target=https%3A//cloud.tencent.com/developer/article/1538680)。

```python
import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt

# 参数
learning_rate = 0.01
training_steps = 1000
display_step = 50
rng = np.random

# 训练数据
X = np.array([3.3,4.4,5.5,6.71,6.93,4.168,9.779,6.182,7.59,2.167,
              7.042,10.791,5.313,7.997,5.654,9.27,3.1])
Y = np.array([1.7,2.76,2.09,3.19,1.694,1.573,3.366,2.596,2.53,1.221,
              2.827,3.465,1.65,2.904,2.42,2.94,1.3])
n_samples = X.shape[0]

# 随机初始化权重，偏置
W = tf.Variable(rng.randn(),name="weight")
b = tf.Variable(rng.randn(),name="bias")
# 线性回归(Wx+b)
def linear_regression(x):
    return W * x + b
    
# 损失函数，均方差
def mean_square(y_pred,y_true):
    return tf.reduce_sum(tf.pow(y_pred-y_true,2)) / (2 * n_samples)
    
# 随机梯度下降优化器
optimizer = tf.optimizers.SGD(learning_rate)
# 优化过程
def run_optimization():
    # 将计算封装在GradientTape中以实现自动微分
    with tf.GradientTape() as g:
        pred = linear_regression(X)
        loss = mean_square(pred,Y)
    # 计算梯度
    gradients = g.gradient(loss,[W,b])
    # 按gradients更新 W 和 b
    optimizer.apply_gradients(zip(gradients,[W,b]))
    
# 针对给定训练步骤数开始训练
for step in range(1,training_steps + 1):
    # 运行优化以更新W和b值
    run_optimization()
    if step % display_step == 0:
        pred = linear_regression(X)
        loss = mean_square(pred, Y)
        print("step: %i, loss: %f, W: %f, b: %f" % (step, loss, W.numpy(), b.numpy()))

# 绘制图
plt.plot(X, Y, 'ro', label='Original data')
plt.plot(X, np.array(W * X + b), label='Fitted line')
plt.legend()
plt.show()
```

## 4、总结

本文介绍了TensorFlow学习中的一些基本原理，也是我个人学习过程中的一些体会。这些原理其实是一些比较通用的概念，不局限于TensorFlow，后期再学习其他框架，如PyTorch就可以更快的上手了。TensorFlow1.0和TensorFlow2.0的语法差异还是比较大的，而且还不向下兼容，这给很多人带来了比较大的麻烦，尤其是大型系统更新，希望TensorFlow3.0不要再出现这样的问题。

TensorFlow总体来说还是一个比较优秀的框架，普通的机器学习、神经元网络学习、深度学习都可以适用。在我们灵活掌握框架使用方法后，重点还是要把公司的实际业务运用到机器学习中，理论和实践相结合。

---

## 5、实战：构建完整分类网络 (Keras API)

### 5.1 数据加载与预处理

```python
import tensorflow as tf
from tensorflow import keras
import numpy as np

# 加载 MNIST 数据集
(x_train, y_train), (x_test, y_test) = keras.datasets.mnist.load_data()

# 归一化到 [0, 1]
x_train = x_train.astype('float32') / 255.0
x_test = x_test.astype('float32') / 255.0

# one-hot 编码
y_train = keras.utils.to_categorical(y_train, 10)
y_test = keras.utils.to_categorical(y_test, 10)
```

### 5.2 Sequential 模型搭建

```python
model = keras.Sequential([
    keras.layers.Flatten(input_shape=(28, 28)),         # 展平 28x28 → 784
    keras.layers.Dense(128, activation='relu'),         # 隐藏层 128 神经元
    keras.layers.Dropout(0.2),                          # 防过拟合
    keras.layers.Dense(10, activation='softmax')        # 输出层 10 类
])

model.compile(
    optimizer='adam',
    loss='categorical_crossentropy',
    metrics=['accuracy']
)
```

### 5.3 训练与评估

```python
history = model.fit(
    x_train, y_train,
    batch_size=32,
    epochs=10,
    validation_split=0.2
)

test_loss, test_acc = model.evaluate(x_test, y_test)
print(f'Test accuracy: {test_acc:.4f}')
```

### 5.4 模型保存与加载

```python
# 保存
model.save('mnist_classifier.h5')

# 加载
loaded_model = keras.models.load_model('mnist_classifier.h5')
```

---

## 6、Functional API（复杂拓扑）

Sequential 只能处理线性堆叠。Functional API 支持多输入、多输出、残差连接等：

```python
inputs = keras.Input(shape=(784,))
x = keras.layers.Dense(64, activation='relu')(inputs)
residual = x  # 跳跃连接
x = keras.layers.Dense(64, activation='relu')(x)
x = keras.layers.Add()([x, residual])  # 残差连接
outputs = keras.layers.Dense(10, activation='softmax')(x)

model = keras.Model(inputs=inputs, outputs=outputs)
```

## 7、自定义训练循环

```python
optimizer = keras.optimizers.Adam()
loss_fn = keras.losses.CategoricalCrossentropy()

@tf.function  # 编译为计算图加速
def train_step(x, y):
    with tf.GradientTape() as tape:
        y_pred = model(x, training=True)
        loss = loss_fn(y, y_pred)
    grads = tape.gradient(loss, model.trainable_variables)
    optimizer.apply_gradients(zip(grads, model.trainable_variables))
    return loss
```

---

## 相关笔记

- [[1.神经网络计算过程|神经网络计算过程]]（前向传播、反向传播推导）
- [[../人工智能/机器学习与深度学习/0.绪论|深度学习绪论]]
- [[../人工智能/机器学习与深度学习/1.机器学习概述|机器学习概述]]
- [[../../数理基础/代数/Linear algebra|线性代数]]（矩阵运算、梯度的数学基础）
