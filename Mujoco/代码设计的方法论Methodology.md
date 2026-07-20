##  1.方法论
MuJoCo仿真的coding可以分为两个方面：控制部分与可视化部分。

控制部分的核心是：

- 加载模型与数据.
- 实时仿真更新
- 控制器设计

可视化部分的核心是：

- 加载可视化部分
- 实时仿真更新
- 可视化回调设计

从整个程序控制流程的角度来说，应该满足如下的控制流程：
![[程序流程控制.png|3000]]
伪代码如下：
```text
// 1. initilization
initControlData();
initVisualData();

// 2. callback function
// 此处按照controller与visualization所规定的callback函数进行补充

// 3. realtime simulation
while(...) {
    updateControlData();
    updateVisualData();
}

// 4. end simulation
deleteControlData();
deleteVisualData();
```
## 2. 初始化

### 2.1 initControlData函数

在这里，我们主要需要做三件事：

- 加载模型与数据
- 设置初始化条件
- 加载控制器

**(注意：以下代码中C++使用面向过程编程，Python使用面向对象编程，故Python代码中会出现成员变量self.)**

C++

```cpp
// 1. 加载模型与数据
mjModel* m = mj_loadXML("mymodel.xml", NULL, errstr, errstr_sz);
mjData* d = mj_makeData(m);
// 2. 设置初始化条件
d->qpos[0] = 0.1;
d->qvel[0] = 2.0;
d->qvel[2] = 5.0;
// 3. 加载控制器
mjcb_control = myController;  // myController为控制器接口
```

Python

```python3
# 1. 加载模型与数据
self.model = mj.MjModel.from_xml_path(xml_path)
self.data = mj.MjData(self.model)
# 2. 设置初始化条件
self.data.qpos[0] = 0.1
self.data.qvel[0] = 2.0
self.data.qvel[2] = 5.0
# 3. 加载控制器
mj.set_mjcb_control(self.controller)
```

### 2.2 initVisualData函数

在这里，我们主要需要做三件事：

- 加载GLFW与可视化数据
- 设置初始化条件
- 加载可视化回调函数

C++

```cpp
// 1. 加载GLFW与可视化数据    
// init GLFW
if(!glfwInit())
    mju_error("Could not initialize GLFW");

// create window, make OpenGL context current, request v-sync
GLFWwindow* window = glfwCreateWindow(1200, 900, "Demo", NULL, NULL);
glfwMakeContextCurrent(window);
glfwSwapInterval(1);

// data structures
mjvCamera cam;                      // abstract camera
mjvOption opt;                      // visualization options
mjvScene scn;                       // abstract scene
mjrContext con;                     // custom GPU context

// initialize visualization data structures
mjv_defaultCamera(&cam);
mjv_defaultOption(&opt);
mjv_defaultScene(&scn);
mjr_defaultContext(&con);
mjv_makeScene(m, &scn, 10000);                // space for 2000 objects
mjr_makeContext(m, &con, mjFONTSCALE_150);   // model-specific context

// 2. 加载可视化回调函数
// install GLFW mouse and keyboard callbacks
glfwSetKeyCallback(window, keyboardCB);
glfwSetCursorPosCallback(window, cursorPosCB);
glfwSetMouseButtonCallback(window, mouseButtonCB);
glfwSetScrollCallback(window, scrollCB);

// 3. 设置初始化条件
// frame
opt.frame = mjFRAME_WORLD;
// camera parameters
// 注意：相机的坐标以及缩放参数可根据合适的值调整，这个可以在实时仿真中输出并打印
double arr_view[] = {8.0， 90.0， -45.0, 0.000000, 0.000000, 0.000000};
cam.distance = arr_view[0];
cam.azimuth = arr_view[1];
cam.elevation = arr_view[2];
cam.lookat[0] = arr_view[3];
cam.lookat[1] = arr_view[4];
cam.lookat[2] = arr_view[5];
```

Python

```python
# 1. 加载GLFW与可视化数据   
self.cam = mj.MjvCamera()
self.opt = mj.MjvOption()
# Init GLFW
glfw.init()
self.window = glfw.create_window(1200, 900, "Demo", None, None)
glfw.make_context_current(self.window)
glfw.swap_interval(1)
# Initialize visualization data structures
mj.mjv_defaultCamera(self.cam)
mj.mjv_defaultOption(self.opt)
self.scene = mj.MjvScene(self.model, maxgeom=10000)
self.context = mj.MjrContext(self.model, mj.mjtFontScale.mjFONTSCALE_150.value)

# 2. 加载可视化回调函数
# Install GLFW mouse and keyboard callbacks
self.button_left = False
self.button_middle = False
self.button_right = False
self.cursor_lastx = 0
self.cursor_lasty = 0
glfw.set_key_callback(self.window, self.keyboardCB)
glfw.set_cursor_pos_callback(self.window, self.cursorPosCB)
glfw.set_mouse_button_callback(self.window, self.mouseButtonCB)
glfw.set_scroll_callback(self.window, self.scrollCB)

# 3. 设置初始化条件
// frame: world
self.opt.frame = mj.mjtFrame.mjFRAME_WORLD
// camera parameters
self.cam.lookat = [0.0, 0.0, 0.0]
self.cam.distance = 8.0
self.cam.azimuth = 90
self.cam.elevation = -45
```

## 3. 回调设计

### 3.1 控制器回调函数

我们设计一个阻力公式如下所示：

 ，其中  代表阻力大小，  代表阻力的方向

我们为了控制通常可以使用三种方式来进行控制：对执行器施加控制信号、直接作用力在关节空间、指定作用力在笛卡尔空间。其中对执行器施加控制信号需要在XML文件中设置执行器单元(后续教程涉及)，在本节中我们使用：直接作用力在关节空间，即mjData.qfrc_applied接口

C++

```cpp
void myController(const mjModel* m, mjData* d) {
    /***
        This controller adds drag force to the ball
        The drag force has the form of
        F = (cv^Tv)v / ||v||
    ***/
    double vx = d->qvel[0];
    double vy = d->qvel[1];
    double vz = d->qvel[2];
    double v = std::sqrt(vx * vx + vy * vy + vz * vz);
    double c = 1.0;
    d->qfrc_applied[0] = -c * v * vx;
    d->qfrc_applied[1] = -c * v * vy;
    d->qfrc_applied[2] = -c * v * vz;
}
```

Python

```rb
def controller(self, model, data):
    """
    This controller adds drag force to the ball
    The drag force has the form of
    F = (cv^Tv)v / ||v||
    """
    vx, vy, vz = data.qvel[0], data.qvel[1], data.qvel[2]
    v = math.sqrt(vx * vx + vy * vy + vz * vz)
    c = 1.0
    data.qfrc_applied[0] = -c * v * vx
    data.qfrc_applied[1] = -c * v * vy
    data.qfrc_applied[2] = -c * v * vz
```

### 3.2 可视化回调函数

我们需要完成使用鼠标、键盘与可视化界面进行交互时所需要的回调函数：如调整视图、重置仿真环境等。

在这里面我们不想使用过多笔墨去描述这一部分，希望读者自己根据参数去实验，得到自己想要的结果。

C++

```cpp
// keyboard callback
void keyboardCB(GLFWwindow* window, int key, int scancode, int act, int mods) {
    // backspace: reset simulation
    if(act==GLFW_PRESS && key==GLFW_KEY_BACKSPACE) {
        mj_resetData(m, d);
        mj_forward(m, d);
        initController(); 
    }
}

// mouse button callback
void mouseButtonCB(GLFWwindow* window, int button, int act, int mods) {
    // update button state
    button_left =   (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_LEFT)==GLFW_PRESS);
    button_middle = (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_MIDDLE)==GLFW_PRESS);
    button_right =  (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_RIGHT)==GLFW_PRESS);
    // update mouse position
    glfwGetCursorPos(window, &lastx, &lasty);
}

// mouse move callback
void cursorPosCB(GLFWwindow* window, double xpos, double ypos) {
    // compute mouse displacement, save
    double dx = xpos - lastx;
    double dy = ypos - lasty;
    lastx = xpos;
    lasty = ypos;
    // no buttons down: nothing to do
    if( !button_left && !button_middle && !button_right )
        return;
    // get current window size
    int width, height;
    glfwGetWindowSize(window, &width, &height);
    // get shift key state
    bool mod_shift = (glfwGetKey(window, GLFW_KEY_LEFT_SHIFT)==GLFW_PRESS ||
                      glfwGetKey(window, GLFW_KEY_RIGHT_SHIFT)==GLFW_PRESS);
    // determine action based on mouse button
    mjtMouse action;
    if(button_right)
        action = mod_shift ? mjMOUSE_MOVE_H : mjMOUSE_MOVE_V;
    else if(button_left)
        action = mod_shift ? mjMOUSE_ROTATE_H : mjMOUSE_ROTATE_V;
    else
        action = mjMOUSE_ZOOM;
    // move camera
    mjv_moveCamera(m, action, dx/height, dy/height, &scn, &cam);
}

// scroll callback
void scrollCB(GLFWwindow* window, double xoffset, double yoffset) {
    // emulate vertical mouse motion = 5% of window height
    mjtMouse action = mjMOUSE_ZOOM;
    mjv_moveCamera(m, action, 0, -0.05*yoffset, &scn, &cam);
}
```

Python

```rb
# keyboard mode
def keyboardCB(self, window, key, scancode, action, mods):
    if action == glfw.PRESS and key == glfw.KEY_BACKSPACE:
        mj.mj_resetData(self.model, self.data)
        mj.mj_forward(self.model, self.data)
        self.initController()

def cursorPosCB(self, window, cursor_xpos, cursor_ypos):
    # compute mouse displacement, save
    cursor_dx = cursor_xpos - self.cursor_lastx
    cursor_dy = cursor_ypos - self.cursor_lasty
    self.cursor_lastx = cursor_xpos
    self.cursor_lasty = cursor_ypos
    if (not self.button_left) and (not self.button_middle) and (not self.button_right):
        return
    # get current window size
    width, height = glfw.get_window_size(window)
    # get shift key state
    PRESS_LEFT_SHIFT = glfw.get_key(window, glfw.KEY_LEFT_SHIFT) == glfw.PRESS
    PRESS_RIGHT_SHIFT = glfw.get_key(window, glfw.KEY_RIGHT_SHIFT) == glfw.PRESS
    mod_shift = PRESS_LEFT_SHIFT or PRESS_RIGHT_SHIFT
    # determine action based on mouse button
    if self.button_right:
        if mod_shift:
            action = mj.mjtMouse.mjMOUSE_MOVE_H
        else:
            action = mj.mjtMouse.mjMOUSE_MOVE_V
    elif self.button_left:
        if mod_shift:
            action = mj.mjtMouse.mjMOUSE_ROTATE_H
        else:
            action = mj.mjtMouse.mjMOUSE_ROTATE_V
    elif self.button_middle:
        action = mj.mjtMouse.mjMOUSE_ZOOM
    mj.mjv_moveCamera(self.model, action, cursor_dx / height, cursor_dy / height, self.scene, self.cam)

def mouseButtonCB(self, window, buttton, action, mods):
    self.button_left = glfw.get_mouse_button(window, glfw.MOUSE_BUTTON_LEFT) == glfw.PRESS
    self.button_middle = glfw.get_mouse_button(window, glfw.MOUSE_BUTTON_MIDDLE) == glfw.PRESS
    self.button_right = glfw.get_mouse_button(window, glfw.MOUSE_BUTTON_RIGHT) == glfw.PRESS
    self.cursor_lastx, self.cursor_lasty = glfw.get_cursor_pos(window)

def scrollCB(self, window, xoffset, yoffset):
    action = mj.mjtMouse.mjMOUSE_ZOOM
    mj.mjv_moveCamera(self.model, action, 0.0, -0.05 * yoffset, self.scene, self.cam)
```

## 4. 实时仿真过程

我们通常会按照仿真更新N步，可视化更新1步，防止可视化影响仿真效果，甚至进一步地，我们可以关掉可视化，只进行仿真，可以提速仿真过程，这在进行强化学习的时候非常有效。以下在C++中展示仿真与可视化比例关系，在Python中展示可以关掉可视化。

C++

```cpp
while(!glfwWindowShouldClose(window)) {
    // 1. 仿真更新，超过阈值后退出仿真
    double simend = 100;
    mjtNum simstart = d->time;
    while(d->time - simstart < 1.0/60.0) {
        mj_step(m, d);
    }
    if (d->time > simend)
        break;
    // 2. 可视化更新
    mjrRect viewport = {0, 0, 0, 0};
    glfwGetFramebufferSize(window, &viewport.width, &viewport.height);
    // update scene and render
    cam.lookat[0] = d->qpos[0];   // camera viewpoint update
    mjv_updateScene(m, d, &opt, NULL, &cam, mjCAT_ALL, &scn);
    mjr_render(viewport, &scn, &con);
    // swap OpenGL buffers (blocking call due to v-sync)
    glfwSwapBuffers(window);
    // process pending GUI events, call GLFW callbacks
    glfwPollEvents();
}
```

Python

```rb
while True:
    # 1. 仿真更新，超过阈值后退出仿真
    simstart = self.data.time
    while (self.data.time - simstart) < 1.0 / 60.0:
        mj.mj_step(self.model, self.data)
    if self.data.time > simend:
        break
    # 2. 可视化更新，is_show参数确定是否打开渲染
    if self.is_show and not glfw.window_should_close(self.window):
        # get framebuffer viewport
        viewport_width, viewport_height = glfw.get_framebuffer_size(self.window)
        viewport = mj.MjrRect(0, 0, viewport_width, viewport_height)
        # Update scene and render
        self.cam.lookat[0] = self.data.qpos[0]
        mj.mjv_updateScene(self.model, self.data, self.opt, None, self.cam,
                           mj.mjtCatBit.mjCAT_ALL.value, self.scene)
        mj.mjr_render(viewport, self.scene, self.context)
        # swap OpenGL buffers (blocking call due to v-sync)
        glfw.swap_buffers(self.window)
        # process pending GUI events, call GLFW callbacks
        glfw.poll_events()
```

## 5. 总结

除了使用GLFW库之后，还可以使用MuJoCo自带的仿真器进行可视化，以下给出完整的Python代码

```rb
import mujoco as mj
from mujoco.glfw import glfw
import mujoco.viewer
import numpy as np
import time
import os


class BallControl:
    def __init__(self, filename, is_show):
        # 1. model and data
        self.model = mj.MjModel.from_xml_path(filename)
        self.data = mj.MjData(self.model)
        self.is_show = is_show
        if self.is_show:
            self.viewer = mujoco.viewer.launch_passive(self.model, self.data, key_callback=self.keyboard_cb)
            self.viewer.opt.frame = mj.mjtFrame.mjFRAME_WORLD
            self.viewer.cam.lookat = [0.0, 0.0, 0.0]
            self.viewer.cam.distance = 8.0
            self.viewer.cam.azimuth = 90
            self.viewer.cam.elevation = -45
        # 2. init Controller
        self.init_controller()

    def init_controller(self):
        # 1. set init pos
        self.data.qpos[0] = 0.1
        self.data.qvel[0] = 2.0
        self.data.qvel[2] = 5.0
        # 2. set the controller
        mj.set_mjcb_control(self.controller)

    def controller(self, model, data):
        """
        This controller adds drag force to the ball
        The drag force has the form of
        F = (cv^Tv)v / ||v||
        """
        vx, vy, vz = data.qvel[0], data.qvel[1], data.qvel[2]
        v = np.sqrt(vx * vx + vy * vy + vz * vz)
        c = 1.0
        data.qfrc_applied[0] = -c * v * vx
        data.qfrc_applied[1] = -c * v * vy
        data.qfrc_applied[2] = -c * v * vz

    def main(self):
        sim_start, sim_end = time.time(), 10.0
        while time.time() - sim_start < sim_end:
            step_start = time.time()
            loop_num, loop_count = 50, 0
            # 1. running for 0.002*50 = 0.1s
            while loop_count < loop_num:
                loop_count = loop_count + 1
                mj.mj_step(self.model, self.data)
            # 2. GUI show
            if self.is_show:
                if self.viewer.is_running():
                    self.viewer.cam.lookat[0] = self.data.qpos[0]
                    self.viewer.sync()
                else:
                    break
            # 3. sleep for next period
            step_next_delta = self.model.opt.timestep * loop_count - (time.time() - step_start)
            if step_next_delta > 0:
                time.sleep(step_next_delta)
        if self.is_show:
            self.viewer.close()

    def keyboard_cb(self, keycode):
        if chr(keycode) == ' ':
            mj.mj_resetData(self.model, self.data)
            mj.mj_forward(self.model, self.data)
            self.init_controller()


if __name__ == "__main__":
    rel_path = "ball.xml"
    dir_name = os.path.dirname(__file__)
    xml_path = os.path.join(dir_name + "/" + rel_path)
    is_show = False
    ballControl = BallControl(xml_path, is_show)

    ballControl.main()
```
---

## 相关笔记

- [[Overview|MuJoCo 概述]]
- [[Benchmark 基准|Benchmark]] — 强化学习环境
- [[../人工智能/RL-PPO理论|PPO 理论]] — 强化学习算法
- [[../刚体动力学算法/刚体动力学算法|刚体动力学算法]] — 仿真数学基础
