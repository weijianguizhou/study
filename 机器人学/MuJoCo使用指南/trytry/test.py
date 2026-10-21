import mujoco

model = mujoco.MjModel.from_xml_path("hello.xml")
data=mujoco.MjData(model)

print("nq=", model.nq,"nv=", model.nv,"nu=", model.nu)
print("timestep=",model.opt.timestep)

while data.time<1.0:
    mujoco.mj_step(model, data)

print("time=",data.time)
print("qpos=",data.qpos)
