# 简化模型和Benchmark
模型简化的优势自然不必多提，Benchmark这个词我最早是在学习强化学习的时候接触到的。那时候OpenAI基于强化学习训练发布了发布了一系列Benchmark环境，如Acrobot、CartPole、Pendulum等

Benchmark环境正是为了将强化学习变得简单，而不是一开始就去研究复杂系统(如30+自由度的人形机器人)。

同样地，我们也希望找到MuJoCo入门所需要的Benchmark。

# 多关节机器人
多关节机器人：由一系列关节(joint)相连的连杆(link)组成的运动链(kinematic chain)

----
以机械臂为例，我们知道：

- 连杆：机体(body) + 上臂(upper arm) + 前臂(forearm) + 手(hand)
- 关节：肩(shoulder) + 肘(elbow) + 腕(wrist)

以机械腿为例，我们知道：

- 连杆：机体(body) + 大腿(thigh) + 小腿(shank) + 足(foot)
- 关节：髋(hip) + 膝(knee) + 踝(ankle）

以轮式机器人为例，我们知道：

- 连杆：机体(body)+轮子（wheel）
- 关节：车轮关节(wheel joint)

# MuJoCo入门的Benchmark

在入门篇中，我们定义两种基础的Benchmark，即Ball元素与Pendulum元素

Ball元素研究自由落体的小球的运动控制问题，Pendulum元素研究倒立摆的运动控制问题。

进一步地：

Pendulum元素，可以延伸为一级倒立摆，二级倒立摆，欠驱动倒立摆(Acrobot、Pendubot)

Ball元素，可以延伸为浮动基座控制问题

再进一步地：

两者可以结合成双足机器人，人形机器人等更加复杂的系统。

在这里，我们给出我们即将要研究的系统：Ball，SinglePendulum、DoublePendulum(包括Acrobot)

## Ball系统

ball.xml

```xml
<mujoco>
    <asset>
        <material name="green" rgba="0 1 0 1" />
        <texture name="grid" type="2d" builtin="checker" width="512" height="512" rgb1=".1 .2 .3" rgb2=".2 .3 .4" />
        <material name="grid" texture="grid" texrepeat="1 1" texuniform="true" reflectance=".2" />
    </asset>

    <worldbody>
        <light diffuse="0.3 0.3 0.3" pos="1 0 3" dir="-1 0 -3" />
        <geom type="plane" size="10 10 0.1"  material="grid" />

        <body pos="0 0 1">
            <joint type="free"/>
            <geom type="sphere" size=".1" material="green" />
        </body>
    </worldbody>

</mujoco>
```

![[Ball系统.jpg]]
## SinglePendulum系统

single_pendulum.xml

```xml
<mujoco>
    <option gravity="0 0 0" />
    <asset>
        <material name="green" rgba="0 1 0 1" />
        <texture name="grid" type="2d" builtin="checker" width="512" height="512" rgb1=".1 .2 .3" rgb2=".2 .3 .4" />
        <material name="grid" texture="grid" texrepeat="1 1" texuniform="true" reflectance=".2" />
    </asset>

    <worldbody>
        <light diffuse="0.3 0.3 0.3" pos="1 0 3" dir="-1 0 -3" />
        <geom type="plane" size="10 10 0.1"  material="grid" />

        <body pos="0 0 2" euler="0 180 0">
            <joint name="joint1" type="hinge" axis="0 -1 0" pos="0 0 0.5" />
            <geom type="cylinder" size="0.05 0.5" mass="1" material="green" />
        </body>
    </worldbody>

</mujoco>
```
## DoublePendulum系统

double_pendulum.xml

```xml
<mujoco>
    <option gravity="0 0 -9.81" />
    <asset>
        <material name="green" rgba="0 0.9 0 1" />
        <material name="blue" rgba="0 0 0.9 1" />
        <texture name="grid" type="2d" builtin="checker" width="512" height="512" rgb1=".1 .2 .3" rgb2=".2 .3 .4" />
        <material name="grid" texture="grid" texrepeat="1 1" texuniform="true" reflectance=".2" />
    </asset>

    <worldbody>
        <light diffuse="0.3 0.3 0.3" pos="1 0 3" dir="-1 0 -3" />
        <geom type="plane" size="10 10 0.1"  material="grid" />

        <body pos="0 0 3.0" euler="0 0 0">
            <joint name="joint1" type="hinge" axis="0 -1 0" pos="0 0 -0.5" />
            <geom type="capsule" size="0.05 0.5" mass="1" material="green" />

            <body pos="0 0.1 1" euler="0 0 0">
                <joint name="joint2" type="hinge" axis="0 -1 0" pos="0 0 -0.5"  />
                <geom type="capsule" size="0.05 0.5" mass="1" material="blue" />
            </body>

        </body>
    </worldbody>

</mujoco>
```
---

## 相关笔记

- [[Overview|MuJoCo 概述]]
- [[代码设计的方法论Methodology|代码设计方法论]]
- [[../人工智能/RL-PPO理论|PPO 理论]] — 强化学习算法
- [[../人工智能/马尔可夫决策过程 (Markov Decision Process, MDP)|MDP]] — 决策框架
