import numpy as np
import matplotlib.pyplot as plt

def f_orig(t, V, W, I):
    dVdt = 0.04 * V**2 + 5 * V + 140 - W + I
    dWdt = 0.02 * (0.2 * V - W)
    return dVdt, dWdt
def f_approx(t, V, W, I):
    # fixed-point arithmetic 기준, Shifting-friendly한 계수들을 이용해 근사
    dVdt = 0.04 * V**2 + 5 * V + 140 - W + I
    dWdt = 1/64 * (1/4 * V - W)
    return dVdt, dWdt

def approxTest():
    I0 = 2.0
    dI = 1.0
    I_list = np.arange(I0, I0 + 9 * dI, dI)

    plt.figure(figsize=(10, 6))

    for i in range(len(I_list)):
        plt.subplot(3, 3, i + 1)
        testUnderI(I_list[i], [f_orig, f_approx])

    plt.suptitle('Approximation Test for Neuron Model', fontsize=16)
    plt.tight_layout()
    plt.show()

# 두 모델 f1과 f2에 따른 수치적분 결과를 plot해서 비교
def testUnderI(I, f_list):
    dt = 1/8 #ms
    T = np.arange(0, 300, dt)

    V = np.zeros_like(T)
    W = np.zeros_like(T)

    for k in range(len(f_list)):
        f = f_list[k]

        V[0] = -65.0
        W[0] = -15.0

        # Test #1: Original Model
        for i in range(len(T)-1):
            I_t = I if T[i] > 30 else 0.0

            dVdt, dWdt = f(T[i], V[i], W[i], I_t)
            V[i+1] = V[i] + dVdt * dt
            W[i+1] = W[i] + dWdt * dt

            if V[i+1] >= 30:
                V[i+1] = -65.0
                W[i+1] += 2.0

        if k == 0:
            plt.plot(T, V, color='blue')
        if k == 1:
            plt.plot(T, V, color='red', linestyle='--')


    plt.title(f'I = {I}mA')
    plt.xlabel('Time (ms)')
    plt.ylabel('V (mV)')

    plt.ylim(-80, 40)

    plt.grid()





if __name__ == "__main__":
    approxTest()