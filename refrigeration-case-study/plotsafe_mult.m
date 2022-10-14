DataMat_machine1=[LOData.LoadMachine1 LOData.PowerMachine1];
DataMat_machine2=[LOData.LoadMachine2 LOData.PowerMachine2];
DataMat_machine3=[LOData.LoadMachine3 LOData.PowerMachine3];
DataMat_machine4=[LOData.LoadMachine4 LOData.PowerMachine4];
DataMat_machine5=[LOData.LoadMachine5 LOData.PowerMachine5];

x=[0:5:820];
x=x';
yreal_machine1(:,1)=polyval([-9e-08 4e-05 -0.0052 0.7765 15.661],x(:,1));
yreal_machine2(:,1)=polyval([-1.42718017e-08 1.87477980e-05 -8.28649653e-03 1.88469092 -2.19952823],x(:,1));
yreal_machine3(:,1)=polyval([-1.53490519e-09  2.28838030e-06 -9.59520873e-04 6.18821903e-01 7.51758182e+01],x(:,1));
yreal_machine4(:,1)=polyval([-1.53490519e-09  2.28838030e-06 -9.59520873e-04 6.18821903e-01 7.51758182e+01],x(:,1));
yreal_machine5(:,1)=polyval([-1.53490519e-09  2.28838030e-06 -9.59520873e-04 6.18821903e-01 7.51758182e+01],x(:,1));
y=x;
y(:,1)=1580;
% kernel = 'squaredexponential';

for n = 3:3
% 
%     gprMdlLP_machine1 = fitrgp(DataMat_machine1(1:n,1),DataMat_machine1(1:n,2),'OptimizeHyperparameters',{'KernelFunction'});
%     gprMdlLP_machine2 = fitrgp(DataMat_machine2(1:n,1),DataMat_machine2(1:n,2),'OptimizeHyperparameters',{'KernelFunction'});
%     gprMdlLP_machine3 = fitrgp(DataMat_machine3(1:n,1),DataMat_machine3(1:n,2),'OptimizeHyperparameters',{'KernelFunction'});    
%     gprMdlLP_machine4 = fitrgp(DataMat_machine4(1:n,1),DataMat_machine4(1:n,2),'OptimizeHyperparameters',{'KernelFunction'});
%     gprMdlLP_machine5 = fitrgp(DataMat_machine5(1:n,1),DataMat_machine5(1:n,2),'OptimizeHyperparameters',{'KernelFunction'});
% 

    
    gprMdlLP_machine1 = fitrgp(DataMat_machine1(1:n,1),DataMat_machine1(1:n,2),'KernelFunction','ardsquaredexponential');
    gprMdlLP_machine2 = fitrgp(DataMat_machine2(1:n,1),DataMat_machine2(1:n,2),'KernelFunction','squaredexponential');
    gprMdlLP_machine3 = fitrgp(DataMat_machine3(1:n,1),DataMat_machine3(1:n,2),'KernelFunction','squaredexponential');
    gprMdlLP_machine4 = fitrgp(DataMat_machine4(1:n,1),DataMat_machine4(1:n,2),'KernelFunction','squaredexponential');
    gprMdlLP_machine5 = fitrgp(DataMat_machine5(1:n,1),DataMat_machine5(1:n,2),'KernelFunction','squaredexponential');


    [PowerPred_machine1,~,PowerPred_Int_machine1] = predict(gprMdlLP_machine1,x);
    [PowerPred_machine2,~,PowerPred_Int_machine2] = predict(gprMdlLP_machine2,x);
    [PowerPred_machine3,~,PowerPred_Int_machine3] = predict(gprMdlLP_machine3,x);
    [PowerPred_machine4,~,PowerPred_Int_machine4] = predict(gprMdlLP_machine4,x);
    [PowerPred_machine5,~,PowerPred_Int_machine5] = predict(gprMdlLP_machine5,x);

   

      
    set(0,'DefaultLineLineWidth',2)
    figure('Name',"Machine1 with " + n + " samples (kernel = "+ gprMdlLP_machine1.KernelFunction + ")")
    plot(x,PowerPred_machine1)
    xlim([56 220])
    xlabel("Cooling Load kW_{thermal}")
    ylabel("Power Consumption kW_{electric}")
    hold
    plot(x,PowerPred_Int_machine1(:,1))
    plot(x,PowerPred_Int_machine1(:,2))
    plot(x(:,1),yreal_machine1(:,1))
    legend('power predictions machine1','CI lower bound machine1', 'CI upper bound machine1', ...
         'actual power consumption machine1')
    
    
    figure('Name',"Machine2 with " + n + " samples (kernel = "+ gprMdlLP_machine2.KernelFunction + ")")
    plot(x,PowerPred_machine2)
    xlabel("Cooling Load kW_{thermal}")
    ylabel("Power Consumption kW_{electric}")
    xlim([237 537])
    hold
    plot(x,PowerPred_Int_machine2(:,1))
    plot(x,PowerPred_Int_machine2(:,2))
    plot(x(:,1),yreal_machine2(:,1))
    legend('power predictions machine2','CI lower bound machine2', 'CI upper bound machine2', ...
        'actual power consumption machine2')

    figure('Name',"Machine3 with " + n + " samples (kernel = "+ gprMdlLP_machine3.KernelFunction + ")")
    plot(x,PowerPred_machine3)
    xlim([194 795])
    xlabel("Cooling Load kW_{thermal}")
    ylabel("Power Consumption kW_{electric}")
    hold
    plot(x,PowerPred_Int_machine3(:,1))
    plot(x,PowerPred_Int_machine3(:,2))
    plot(x(:,1),yreal_machine3(:,1))
    legend('power predictions machine3','CI lower bound machine3', 'CI upper bound machine3', ...
       'actual power consumption machine3')

    figure('Name',"Machine4 with " + n + " samples (kernel = "+ gprMdlLP_machine4.KernelFunction + ")")
    plot(x,PowerPred_machine4)
    xlabel("Cooling Load kW_{thermal}")
    ylabel("Power Consumption kW_{electric}")
    xlim([194 795])
    hold
    plot(x,PowerPred_Int_machine4(:,1))
    plot(x,PowerPred_Int_machine4(:,2))
    plot(x(:,1),yreal_machine4(:,1))
    legend('power predictions machine4','CI lower bound machine4', 'CI upper bound machine4', ...
        'actual power consumption machine4')

    figure('Name',"Machine5 with " + n + " samples (kernel = "+ gprMdlLP_machine5.KernelFunction + ")")
    plot(x,PowerPred_machine5)
    xlabel("Cooling Load kW_{thermal}")
    ylabel("Power Consumption kW_{electric}")
    xlim([194 795])
    hold
    plot(x,PowerPred_Int_machine5(:,1))
    plot(x,PowerPred_Int_machine5(:,2))
    plot(x(:,1),yreal_machine5(:,1))
    legend('power predictions machine5','CI lower bound machine5', 'CI upper bound machine5', ...
        'actual power consumption machine5')


end

y_total = yreal_machine1 + yreal_machine2 + yreal_machine3 + yreal_machine4 + yreal_machine5;
figure("Name", "Power Consumptions")
plot(x(:,1),yreal_machine1(:,1))
hold
plot(x(:,1),yreal_machine2(:,1))
plot(x(:,1),yreal_machine3(:,1))
plot(x(:,1),yreal_machine4(:,1))
plot(x(:,1),yreal_machine5(:,1))
plot(x(:,1),y_total(:,1))
plot(x,y,'-')
legend('actual power consumption machine1', 'actual power consumption machine2','actual power consumption machine3','actual power consumption machine4', 'actual power consumption machine5', 'total consumed power', 'threshold')

