import numpy as np
import matplotlib.pyplot as plt

plt.rcParams["font.sans-serif"] = ["SimHei"]
plt.rcParams["axes.unicode_minus"] = False


def damped_free_vibration(m, c, k, x0, v0, t_end, n=2000):

    wn = np.sqrt(k / m)
    zeta = c / (2 * np.sqrt(k * m))

    t = np.linspace(0, t_end, n)
    wd = wn * np.sqrt(1 - zeta**2)

    if zeta < 1:  # 欠阻尼
        A = np.sqrt(x0**2 + (v0 + zeta * wn * x0) ** 2 / wd**2)
        phi = np.arctan2(wd * x0, v0 + zeta * wn * x0)
        x = A * np.exp(-zeta * wn * t) * np.cos(wd * t - phi)
        label = f"欠阻尼  zeta={zeta:.3f}"

    elif zeta == 1:  # 临界阻尼
        c2 = x0
        c1 = v0 + wn * x0
        x = (c1 + c2 * t) * np.exp(-wn * t)
        label = f"临界阻尼  zeta={zeta:.3f}"

    else:  # 过阻尼
        s1 = -zeta * wn + wn * np.sqrt(zeta**2 - 1)
        s2 = -zeta * wn - wn * np.sqrt(zeta**2 - 1)
        c1 = (v0 - s2 * x0) / (s1 - s2)
        c2 = (s1 * x0 - v0) / (s1 - s2)
        x = c1 * np.exp(s1 * t) + c2 * np.exp(s2 * t)
        label = f"过阻尼  zeta={zeta:.3f}"

    return t, x, label


if __name__ == "__main__":
    m, k = 1.0, 100.0
    x0, v0 = 0.1, 0.0
    t_end = 5.0

    cases = [
        (m, 1.0, k),    # zeta ~ 0.05
        (m, 20.0, k),   # zeta ~ 1.0
        (m, 40.0, k),   # zeta ~ 2.0
    ]

    fig, ax = plt.subplots(figsize=(10, 5))
    for case in cases:
        t, x, label = damped_free_vibration(*case, x0, v0, t_end)
        ax.plot(t, x, label=label)

    ax.axhline(0, color="black", linewidth=0.8)
    ax.set_xlabel("时间 t / s")
    ax.set_ylabel("位移 x / m")
    ax.set_title("单自由度阻尼自由振动")
    ax.legend()
    ax.grid(True)
    plt.tight_layout()
    plt.show()
