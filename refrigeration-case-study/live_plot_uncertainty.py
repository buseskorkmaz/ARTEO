from matplotlib import style
import matplotlib.pyplot as plt
import numpy as np
import time
import pandas as pd
from matplotlib.animation import FuncAnimation
import matplotlib.gridspec as gridspec

# This code reproduces Figure 3, 4, 5, 6

def plot_live_gp(i):
    global significance, current_iteration

    if i > 4:
        
        real_machine1 = np.poly1d([-9e-08, 4e-05, -0.0052, 0.7765, 15.661])
        real_machine1_curve = real_machine1(operating_interval_machine1)
        
        real_machine2 = np.poly1d([-1.42718017e-08, 1.87477980e-05, -8.28649653e-03, 1.88469092, -2.19952823])
        real_machine2_curve = real_machine2(operating_interval_machine2)

        real_machine3 = np.poly1d([-1.53490519e-09,  2.28838030e-06, -9.59520873e-04, 6.18821903e-01, 7.51758182e+01])
        real_machine3_curve = real_machine3(operating_interval_machine3)

        mean_machine1 = machine1_means[(i-3)*len(operating_interval_machine1):(i-2)*len(operating_interval_machine1)]
        mean_machine2 = machine2_means[(i-3)*len(operating_interval_machine2):(i-2)*len(operating_interval_machine2)]
        mean_machine3 = machine3_means[(i-3)*len(operating_interval_machine3):(i-2)*len(operating_interval_machine3)]
        mean_machine4 = machine4_means[(i-3)*len(operating_interval_machine3):(i-2)*len(operating_interval_machine3)]
        mean_machine5 = machine5_means[(i-3)*len(operating_interval_machine3):(i-2)*len(operating_interval_machine3)]

        sigma_machine1 = machine1_sigmas[(i-3)*len(operating_interval_machine1):(i-2)*len(operating_interval_machine1)]
        sigma_machine2 = machine2_sigmas[(i-3)*len(operating_interval_machine2):(i-2)*len(operating_interval_machine2)]
        sigma_machine3 = machine3_sigmas[(i-3)*len(operating_interval_machine3):(i-2)*len(operating_interval_machine3)]
        sigma_machine4 = machine4_sigmas[(i-3)*len(operating_interval_machine3):(i-2)*len(operating_interval_machine3)]
        sigma_machine5 = machine5_sigmas[(i-3)*len(operating_interval_machine3):(i-2)*len(operating_interval_machine3)]

        t_crit = 1.96

        upper_ci_machine1 = mean_machine1+sigma_machine1*t_crit
        lower_ci_machine1 = mean_machine1-sigma_machine1*t_crit

        upper_ci_machine2 = mean_machine2+sigma_machine2*t_crit
        lower_ci_machine2 = mean_machine2-sigma_machine2*t_crit

        upper_ci_machine3 = mean_machine3+sigma_machine3*t_crit
        lower_ci_machine3 = mean_machine3-sigma_machine3*t_crit

        upper_ci_machine4 = mean_machine4+sigma_machine4*t_crit
        lower_ci_machine4 = mean_machine4-sigma_machine4*t_crit

        upper_ci_machine5 = mean_machine5+sigma_machine5*t_crit
        lower_ci_machine5 = mean_machine5-sigma_machine5*t_crit

        partial_explore = explore[:i,]
        target_points_index = np.where(partial_explore==0)
        explored_points_index = np.where(partial_explore==1)
   
        # clear axis
        ax.cla()
        ax1.cla()
        ax2.cla()
        ax3.cla()
        ax4.cla()
        ax5.cla()
        ax6.cla()

        ax.set_title("Small Compressor")
        ax.plot(operating_interval_machine1, mean_machine1,'-r', label='GP predictions')
        ax.plot(operating_interval_machine1, real_machine1_curve, 'darkgreen', label= 'Real curve')
        ax.fill_between(operating_interval_machine1,lower_ci_machine1, upper_ci_machine1, 
        alpha=0.8, 
        color="cyan",
        label=r"$\pm$ 1.96 std. dev.",
        )
        ax.scatter(load_machine1[i-1], power_machine1[i-1], marker='x', color='blue', label="Last chosen point", s=300)
        if target_points_index != []:
            ax.scatter(load_machine1[target_points_index], power_machine1[target_points_index], c='orange', label='Load optimized solution')
            ax.scatter(load_machine1[explored_points_index], power_machine1[explored_points_index], c='indigo', label='Exploration based solution')

        ax.set_xlim(56,219)
        ax.set_ylim(0,250)
        ax.set_xlabel("Cooling Load $kW_{thermal}$")
        ax.set_ylabel("Power Consumption $kW_{electric}$") 
        lgnd = ax.legend(prop={'size': 6})
        lgnd.legendHandles[3]._sizes = [30]

        ax1.set_title("Medium Compressor")
        ax1.plot(operating_interval_machine2, mean_machine2,'-r')
        ax1.plot(operating_interval_machine2, real_machine2_curve, 'darkgreen')
        ax1.fill_between(operating_interval_machine2,lower_ci_machine2, upper_ci_machine2, 
        alpha=0.8, 
        color="cyan",
        # label=r"$\pm$ 1 std. dev.",
        )
        ax1.scatter(load_machine2[i-1], power_machine2[i-1], marker='x', color='blue', s=260)
        if target_points_index != []:
            ax1.scatter(load_machine2[target_points_index], power_machine2[target_points_index], c='orange')
            ax1.scatter(load_machine2[explored_points_index], power_machine2[explored_points_index], c='indigo')
        
        ax1.set_xlim(237,536)
        ax1.set_ylim(0,600)
        ax1.set_xlabel("Cooling Load $kW_{thermal}$")
        # ax1.set_ylabel("Power Consumption $kW_{electric}$") 

        # Large Compressor 1
        ax2.set_title("Large Compressor-1")
        ax2.plot(operating_interval_machine3, mean_machine3,'-r')
        ax2.plot(operating_interval_machine3, real_machine3_curve, 'darkgreen')
        ax2.fill_between(operating_interval_machine3,lower_ci_machine3, upper_ci_machine3, 
        alpha=0.8, 
        color="cyan",
        # label=r"$\pm$ 1 std. dev.",
        )
        ax2.scatter(load_machine3[i-1], power_machine3[i-1], marker='x', color='blue', s=260)
        if target_points_index != []:
            ax2.scatter(load_machine3[target_points_index], power_machine3[target_points_index], c='orange')
            ax2.scatter(load_machine3[explored_points_index], power_machine3[explored_points_index], c='indigo')
        
        ax2.set_xlim(194,794)
        ax2.set_ylim(0,650)
        ax2.set_xlabel("Cooling Load $kW_{thermal}$")
        # ax2.set_ylabel("Power Consumption $kW_{electric}$") 

        # Large Compressor 2
        ax3.set_title("Large Compressor-2")
        ax3.plot(operating_interval_machine3, mean_machine4,'-r')
        ax3.plot(operating_interval_machine3, real_machine3_curve, 'darkgreen')
        ax3.fill_between(operating_interval_machine3,lower_ci_machine4, upper_ci_machine4, 
        alpha=0.8, 
        color="cyan",
        # label=r"$\pm$ 1 std. dev.",
        )
        ax3.scatter(load_machine4[i-1], power_machine4[i-1], marker='x', color='blue', s=260)
        if target_points_index != []:
            ax3.scatter(load_machine4[target_points_index], power_machine4[target_points_index], c='orange')
            ax3.scatter(load_machine4[explored_points_index], power_machine4[explored_points_index], c='indigo')
        
        ax3.set_xlim(194,794)
        ax3.set_ylim(0,650)
        ax3.set_xlabel("Cooling Load $kW_{thermal}$")
        # ax3.set_ylabel("Power Consumption $kW_{electric}$") 


        # Large Compressor 3
        ax4.set_title("Large Compressor-3")
        ax4.plot(operating_interval_machine3, mean_machine5,'-r')
        ax4.plot(operating_interval_machine3, real_machine3_curve, 'darkgreen')
        ax4.fill_between(operating_interval_machine3,lower_ci_machine5, upper_ci_machine5, 
        alpha=0.8, 
        color="cyan",
        # label=r"$\pm$ 1 std. dev.",
        )
        ax4.scatter(load_machine5[i-1], power_machine5[i-1], marker='x', color='blue', s=260)
        if target_points_index != []:
            ax4.scatter(load_machine5[target_points_index], power_machine5[target_points_index], c='orange')
            ax4.scatter(load_machine5[explored_points_index], power_machine5[explored_points_index], c='indigo')
        
        ax4.set_xlim(194,794)
        ax4.set_ylim(0,650)
        ax4.set_xlabel("Cooling Load $kW_{thermal}$")
        # ax4.set_ylabel("Power Consumption $kW_{electric}$") 
        
        ax5.set_title("Target Load")
        ax5.plot(np.arange(0, (i-3)*250, dtype=int), np.repeat(target_load[3:i],250), color='black', label='Target load')
        ax5.plot(np.arange(0, (i-3)*250, dtype=int), np.repeat(load_machine1[4:i+1],250) + np.repeat(load_machine2[4:i+1],250) + np.repeat(load_machine3[4:i+1],250) + np.repeat(load_machine4[4:i+1],250) + np.repeat(load_machine5[4:i+1],250), color='lightcoral', label='Achieved total load')
        ax5.set_xlim(0,(i-3)*250)
        ax5.set_ylim(0,4250)
        ax5.set_ylabel('Target Load')
        ax5.set_xlabel('Time')   
        ax5.legend()

        ax6.set_title("Real Power Consumption (total)")
        ax6.plot(np.arange(0, (i-3)*250, dtype=int), np.repeat(power_machine1[3:i] + power_machine2[3:i] + power_machine3[3:i] + power_machine4[3:i] + power_machine5[3:i],250), color='magenta', label='Real power consumption')
        ax6.hlines(1580, xmin=0, xmax=(i-3)*250, color='blue', label = 'Maximum power')
        ax6.set_xlim(0,(i-3)*250)
        ax6.set_ylim(0,2500)
        ax6.set_ylabel('Power Consumption')
        ax6.set_xlabel('Time')   
        ax6.legend()

        lines_labels = [ax.get_legend_handles_labels() for ax in fig.axes]
        lines, labels = [sum(lol, []) for lol in zip(*lines_labels)]
        fig.legend(lines, labels, loc='lower right')
    
        plt.suptitle("Self Safe-Learning Power Consumption Curves", fontweight="bold")


df = pd.read_excel("plot_data3.xlsx")
target_load = df["target_load"].values.tolist()
load_machine1 = df["load_machine1"].values
load_machine2 = df["load_machine2"].values
load_machine3 = df["load_machine3"].values
load_machine4 = df["load_machine4"].values
load_machine5 = df["load_machine5"].values

power_machine1 = df["power_machine_1"].values
power_machine2 = df["power_machine2"].values
power_machine3 = df["power_machine3"].values
power_machine4 = df["power_machine4"].values
power_machine5 = df["power_machine5"].values

explore = df[" explore"].values

machine1_means  = pd.read_csv("machine1_means3.csv").values[:,0]
machine2_means  = pd.read_csv("machine2_means3.csv").values[:,0]
machine3_means  = pd.read_csv("machine3_means3.csv").values[:,0]
machine4_means  = pd.read_csv("machine4_means3.csv").values[:,0]
machine5_means  = pd.read_csv("machine5_means3.csv").values[:,0]

machine1_sigmas  = pd.read_csv("machine1_sigmas3.csv").values[:,0]
machine2_sigmas= pd.read_csv("machine2_sigmas3.csv").values[:,0]
machine3_sigmas  = pd.read_csv("machine3_sigmas3.csv").values[:,0]
machine4_sigmas= pd.read_csv("machine4_sigmas3.csv").values[:,0]
machine5_sigmas= pd.read_csv("machine5_sigmas3.csv").values[:,0]

operating_interval_machine1 = np.arange(56, 221, dtype=int)
operating_interval_machine2 = np.arange(237, 538, dtype=int)
operating_interval_machine3 = np.arange(194, 796, dtype=int)

significance = 0.2
current_iteration = 0

# define and adjust figure
fig = plt.figure(figsize=(9,9))
fig.subplots_adjust(left=.05, right=.99)
gs1 = gridspec.GridSpec(2, 5)
# set the spacing between axes
gs1.update(wspace=0.30, hspace=0.50) 

ax = plt.subplot(gs1[0, 0])
ax1 = plt.subplot(gs1[0, 1])
ax2 = plt.subplot(gs1[0, 2])
ax3 = plt.subplot(gs1[0, 3])
ax4 = plt.subplot(gs1[0, 4])
ax5 = plt.subplot(gs1[1, :2])
ax6 = plt.subplot(gs1[1, 2:4])

# ax.set_facecolor('#DEDEDE')
# ax1.set_facecolor('#DEDEDE')

# animate
ani = FuncAnimation(fig, plot_live_gp, interval=800)

plt.show()

