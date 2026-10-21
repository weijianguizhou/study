using TyControlSystems
using TyPlot

G = zpk(Float64[], [0, -20, -1000], 5000)
Ka = 40
sys = feedback(Ka * G, 1)

t = 0:0.01:1
step(sys, t)
grid("on")
axis([0 1 0 1.2])
