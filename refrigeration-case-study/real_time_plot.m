operating_interval_machine1 = [56:220]';
operating_interval_machine2 = [237:537]';
operating_interval_machine3 = [194:795]';

target_load = LOData.Load_Target;
load_machine1 = LOData.LoadMachine1;
load_machine2 = LOData.LoadMachine2;
load_machine3 = LOData.LoadMachine3;
load_machine4 = LOData.LoadMachine4;
load_machine5 = LOData.LoadMachine5;

power_machine1 = LOData.PowerMachine1;
power_machine2 = LOData.PowerMachine2;
power_machine3 = LOData.PowerMachine3;
power_machine4 = LOData.PowerMachine4;
power_machine5 = LOData.PowerMachine5;

significance = 0.1;
curr_iteration = 0;

means_for_machine1 =[];
sigmas_for_machine1 = [];

means_for_machine2 = [];
sigmas_for_machine2 = [];

means_for_machine3 = [];
sigmas_for_machine3 = [];

means_for_machine4 = [];
sigmas_for_machine4 = [];

means_for_machine5 = [];
sigmas_for_machine5 = [];


set(0,'DefaultLineLineWidth',2)
fig = figure;
fig.Position(3:4)=[1200,600];

for i = 1:length(target_load)

    iterations = length(unique(target_load(1:i)));

    if(iterations > curr_iteration && significance >= 0.05 )
        decay = 0.04 ;
        significance = significance * (1. / (1+decay * iterations)); 
        curr_iteration = iterations;   
    end

    gprMdlLP_machine1 = fitrgp(load_machine1(1:i),power_machine1(1:i), 'KernelFunction','ardsquaredexponential'); 
    gprMdlLP_machine2 = fitrgp(load_machine2(1:i),power_machine2(1:i), 'KernelFunction','squaredexponential');
    gprMdlLP_machine3 = fitrgp(load_machine3(1:i),power_machine3(1:i), 'KernelFunction','squaredexponential'); 
    gprMdlLP_machine4 = fitrgp(load_machine4(1:i),power_machine4(1:i), 'KernelFunction','squaredexponential');
    gprMdlLP_machine5 = fitrgp(load_machine5(1:i),power_machine5(1:i), 'KernelFunction','squaredexponential');

    [mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,operating_interval_machine1, 'Alpha', significance); 
    [mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,operating_interval_machine2, 'Alpha', significance);
    [mean_machine3, sigma_machine3,interval_machine3] = predict(gprMdlLP_machine3,operating_interval_machine3, 'Alpha', significance); 
    [mean_machine4, sigma_machine4,interval_machine4] = predict(gprMdlLP_machine4,operating_interval_machine3, 'Alpha', significance);
    [mean_machine5, sigma_machine5,interval_machine5] = predict(gprMdlLP_machine5,operating_interval_machine3, 'Alpha', significance); 
   
    means_for_machine1 = [means_for_machine1 ; [mean_machine1]];
    sigmas_for_machine1 = [sigmas_for_machine1 ; [sigma_machine1]];

    means_for_machine2 = [means_for_machine2 ; [mean_machine2]];
    sigmas_for_machine2 = [sigmas_for_machine2 ; [sigma_machine2]];

    means_for_machine3 = [means_for_machine3 ; [mean_machine3]];
    sigmas_for_machine3 = [sigmas_for_machine3 ; [sigma_machine3]];

    means_for_machine4 = [means_for_machine4 ; [mean_machine4]];
    sigmas_for_machine4 = [sigmas_for_machine4 ; [sigma_machine4]];

    means_for_machine5 = [means_for_machine5 ; [mean_machine5]];
    sigmas_for_machine5 = [sigmas_for_machine5 ; [sigma_machine5]];

    yreal_machine1(:,1)=polyval([-9e-08 4e-05 -0.0052 0.7765 15.661],operating_interval_machine1);
    yreal_machine2(:,1)=polyval([-1.42718017e-08 1.87477980e-05 -8.28649653e-03 1.88469092 -2.19952823],operating_interval_machine2);
    yreal_machine3(:,1)=polyval([-1.53490519e-09  2.28838030e-06 -9.59520873e-04 6.18821903e-01 7.51758182e+01],operating_interval_machine3);
    yreal_machine4(:,1)=polyval([-1.53490519e-09  2.28838030e-06 -9.59520873e-04 6.18821903e-01 7.51758182e+01],operating_interval_machine3);
    yreal_machine5(:,1)=polyval([-1.53490519e-09  2.28838030e-06 -9.59520873e-04 6.18821903e-01 7.51758182e+01],operating_interval_machine3);

    subplot(1,2,1)
    title("Small Compressor")
    plot(operating_interval_machine1, mean_machine1,'-r');
    hold
    plot(operating_interval_machine1,yreal_machine1, '-g');
    xlim([45 220]);
    ylim([0 180]);
    ylabel('Power Consumption');
    xlabel('Load');    
    
    subplot(1,2,2)
    title("Large Compressor")
    plot(operating_interval_machine3, mean_machine3,'-b');
    hold
    plot(operating_interval_machine3,yreal_machine3, '-g');
    xlim([180 800]);
    ylim([0 600]);
    ylabel('Power Consumption');
    xlabel('Load');   
  
    sgtitle("Self-Learning Power Consumption Curves")
%     pause(0.01)
    drawnow;
end

writematrix(means_for_machine1, "machine1_means3.csv")
writematrix(means_for_machine2, "machine2_means3.csv")
writematrix(means_for_machine3, "machine3_means3.csv")
writematrix(means_for_machine4, "machine4_means3.csv")
writematrix(means_for_machine5, "machine5_means3.csv")

writematrix(sigmas_for_machine1, "machine1_sigmas3.csv")
writematrix(sigmas_for_machine2, "machine2_sigmas3.csv")
writematrix(sigmas_for_machine3, "machine3_sigmas3.csv")
writematrix(sigmas_for_machine4, "machine4_sigmas3.csv")
writematrix(sigmas_for_machine5, "machine5_sigmas3.csv")


