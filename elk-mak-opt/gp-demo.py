import matplotlib.pyplot as plt
import numpy as np
from matplotlib.animation import FuncAnimation
import time
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RBF


def plot_gpr_samples(gpr_model, n_samples, ax):
    """Plot samples drawn from the Gaussian process model.

    If the Gaussian process model is not trained then the drawn samples are
    drawn from the prior distribution. Otherwise, the samples are drawn from
    the posterior distribution. Be aware that a sample here corresponds to a
    function.

    Parameters
    ----------
    gpr_model : `GaussianProcessRegressor`
        A :class:`~sklearn.gaussian_process.GaussianProcessRegressor` model.
    n_samples : int
        The number of samples to draw from the Gaussian process distribution.
    ax : matplotlib axis
        The matplotlib axis where to plot the samples.
    """
    x = np.linspace(0, 5, 100)
    X = x.reshape(-1, 1)

    y_mean, y_std = gpr_model.predict(X, return_std=True)
    y_samples = gpr_model.sample_y(X, n_samples)

    # for idx, single_prior in enumerate(y_samples.T):
    #     ax.plot(
    #         x,
    #         single_prior,
    #         linestyle="--",
    #         alpha=0.7,
    #         label=f"Sampled function #{idx + 1}",
    #     )
    ax.plot(x, y_mean, color="black", label="GP prediction")
    ax.fill_between(
        x,
        y_mean - 2 * y_std,
        y_mean + 2 * y_std,
        alpha=0.1,
        color="black",
        label=r"$\pm$ 2 std. dev.",
    )
    ax.set_xlabel("x")
    ax.set_ylabel("y")
    ax.set_ylim([-3, 3])

def plot_real(ax):
   
    values = np.linspace(0,5)
    y = np.sin((values - 2.5) ** 2)
    ax.plot(
            values,
            y,
            linestyle="--",
            alpha=0.7,
            label="Example function",
    )
    ax.set_xlabel("x")
    ax.set_ylabel("y")
   


def plot_live_gp_demo(i):

    global X_train

    axs.cla()
    kernel = 1.0 * RBF(length_scale=1.0, length_scale_bounds=(1e-1, 10.0))
    gpr = GaussianProcessRegressor(kernel=kernel, random_state=0)

    # plot prior
    if i == 0:
        plot_real(ax=axs)
        plot_gpr_samples(gpr, n_samples=n_samples, ax=axs)
        axs.set_title("Samples from prior distribution")
        axs.legend(loc="best")
    # plot posterior
    else:
        y_train = np.sin((X_train[:, 0] - 2.5) ** 2)
        gpr.fit(X_train, y_train)
        plot_real(ax=axs)
        plot_gpr_samples(gpr, n_samples=n_samples, ax=axs)
        axs.scatter(X_train[:, 0], y_train, color="red", zorder=10, label="Observations")
        axs.legend(loc="best")
        axs.set_title("Samples from posterior distribution")
        new_point = rng.uniform(0, 5, 1).reshape(-1, 1)
        X_train = np.concatenate((X_train, new_point), axis=0)

    axs.set_xlim(0,5)
    fig.suptitle("GP Demo with Radial Basis Function Kernel", fontsize=18)
    plt.tight_layout()

# define and adjust figure
time.sleep(5)
# animate
rng = np.random.RandomState(4)
X_train = rng.uniform(0, 5, 1).reshape(-1, 1)
n_samples = 5
fig, axs = plt.subplots(nrows=1, figsize=(10, 8))
ani = FuncAnimation(fig, plot_live_gp_demo, interval=800)

plt.show()