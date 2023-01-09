from matplotlib import style
import matplotlib.pyplot as plt
import numpy as np
import time
import pandas as pd
from matplotlib.animation import FuncAnimation
import matplotlib.gridspec as gridspec

def plot_live_gp(i):

    if i < 5:
        time.sleep(5)

    if i > 0:

        real_machine1 = np.poly1d([5*1e-14, -1e-13, 6.5108, 9*1e-12])
        real_machine1_curve = real_machine1(operating_interval_machine1)
        
        real_machine2 = np.poly1d([9*1e-15, 5*1e-14, 6.5108, 3*1e-11])
        real_machine2_curve = real_machine2(operating_interval_machine2)

        mean_machine1 = machine1_means[(i)*len(operating_interval_machine1):(i+1)*len(operating_interval_machine1)]
        mean_machine2 = machine2_means[(i)*len(operating_interval_machine2):(i+1)*len(operating_interval_machine2)]

        print(len(mean_machine1))
        print(len(operating_interval_machine1))
      
        sigma_machine1 = machine1_sigmas[(i)*len(operating_interval_machine1):(i+1)*len(operating_interval_machine1)]
        sigma_machine2 = machine2_sigmas[(i)*len(operating_interval_machine2):(i+1)*len(operating_interval_machine2)]
       
        t_crit = 1.96

        upper_ci_machine1 = mean_machine1+sigma_machine1*t_crit
        lower_ci_machine1 = mean_machine1-sigma_machine1*t_crit

        upper_ci_machine2 = mean_machine2+sigma_machine2*t_crit
        lower_ci_machine2 = mean_machine2-sigma_machine2*t_crit

        partial_explore = explore[:i,]
        target_points_index = np.where(partial_explore==0)
        explored_points_index = np.where(partial_explore==1)
   
        # clear axis
        ax.cla()
        ax1.cla()
        ax2.cla()

        ax.set_title("Machine-1")
        ax.plot(operating_interval_machine1, mean_machine1,'-r', label='GP predictions')
        ax.plot(operating_interval_machine1, real_machine1_curve, 'darkgreen', label= 'Real curve')
        ax.fill_between(operating_interval_machine1,lower_ci_machine1, upper_ci_machine1, 
        alpha=0.8, 
        color="cyan",
        label=r"$\pm$ 1.96 std. dev.",
        )
        ax.scatter(load_machine1[i-1], prev_current_one[i-1], marker='x', color='blue', label="Last chosen point", s=300)
        if target_points_index != []:
            ax.scatter(load_machine1[target_points_index], prev_current_one[target_points_index], c='orange', label='Optimization based solution')
            ax.scatter(load_machine1[explored_points_index], prev_current_one[explored_points_index], c='indigo', label='Exploration based solution')

        ax.set_xlim(0,37)
        ax.set_ylim(0,250)
        ax.set_xlabel("Torque")
        ax.set_ylabel("Current") 
        lgnd = ax.legend(prop={'size': 6})
        lgnd.legendHandles[3]._sizes = [30]

        ax1.set_title("Machine-2")
        ax1.plot(operating_interval_machine2, mean_machine2,'-r')
        ax1.plot(operating_interval_machine2, real_machine2_curve, 'darkgreen')
        ax1.fill_between(operating_interval_machine2,lower_ci_machine2, upper_ci_machine2, 
        alpha=0.8, 
        color="cyan",
        # label=r"$\pm$ 1 std. dev.",
        )
        ax1.scatter(load_machine2[i-1], prev_current_two[i-1], marker='x', color='blue', s=260)
        if target_points_index != []:
            ax1.scatter(load_machine2[target_points_index], prev_current_two[target_points_index], c='orange', label='Optimization based solution')
            ax1.scatter(load_machine2[explored_points_index], prev_current_two[explored_points_index], c='indigo', label='Exploration based solution')

        
        ax1.set_xlim(0,37)
        ax1.set_ylim(0,250)
        ax1.set_xlabel("Torque")
        ax1.set_ylabel("Current") 

        ax2.set_title("Reference current")
        ax2.step(np.arange(0, i, dtype=int), target_load[0:i], color='black', label='Reference current')
        ax2.step(np.arange(0, i, dtype=int), prev_current_one[0:i] + prev_current_two[0:i], color='lightcoral', label='Total produced current')
        ax2.set_xlim(0,198)
        ax2.set_ylim(0,280)
        ax2.set_ylabel('Reference current')
        ax2.set_xlabel('Time')   
        ax2.legend()

        # lines_labels = [ax.get_legend_handles_labels() for ax in fig.axes]
        # lines, labels = [sum(lol, []) for lol in zip(*lines_labels)]
        # fig.legend(lines, labels, loc='lower right')
    
        plt.suptitle("ARTEO Electrical Motor Current Optimization", fontweight="bold")


target_load = pd.read_csv("ref_signal.csv",header=None).values[:,0]
load_machine1 = pd.read_csv("prev_torque_one.csv",header=None).values[:,0]
load_machine2 = pd.read_csv("prev_torque_two.csv",header=None).values[:,0]

explore = pd.read_csv("explore.csv").values[:,0]

# normal training
machine1_means  = pd.read_csv("means_machine1.csv",header=None).values[:,0]
machine2_means  = pd.read_csv("means_machine2.csv",header=None).values[:,0]

machine1_sigmas  = pd.read_csv("sigmas_machine1.csv",header=None).values[:,0]
machine2_sigmas = pd.read_csv("sigmas_machine2.csv",header=None).values[:,0]

prev_current_one  = pd.read_csv("prev_current_one.csv",header=None).values[:,0]
prev_current_two = pd.read_csv("prev_current_two.csv",header=None).values[:,0]

operating_interval_machine1 = np.arange(0, 39, dtype=int)
operating_interval_machine2 = np.arange(0, 39, dtype=int)

# define and adjust figure
fig = plt.figure(figsize=(9,9))
fig.subplots_adjust(left=.1, right=.99)
gs1 = gridspec.GridSpec(2, 2)
gs1.update(wspace=0.30, hspace=0.50) # set the spacing between axes. 

ax = plt.subplot(gs1[0, 0])
ax1 = plt.subplot(gs1[0, 1])
ax2 = plt.subplot(gs1[1, 0:])

# ax.set_facecolor('#DEDEDE')
# ax1.set_facecolor('#DEDEDE')

# animate
ani = FuncAnimation(fig, plot_live_gp, interval=800)

plt.show()

