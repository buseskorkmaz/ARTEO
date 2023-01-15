function [sys,x0,str,tss]=load_opt(t,x, u,flag,Param,X_ss)
switch flag

case 0	% Initialize the states and sizes
   [sys,x0,str,tss] = mdlInitialSizes(t,x,u,X_ss);
   
    % ****************
  	%  Outputs
  	% ****************   
     
case 3   % Calculate the outputs
   
   sys = mdlOutputs(t,x, u,Param);
   
   % ****************
   % Update
   % ****************
case 1	% Obtain derivatives of states

   sys = mdlDerivatives(t,x, u,Param);

otherwise
   sys = [];
end

% ******************************************
% Sub-routines or Functions
% ******************************************

% ******************************************
% Initialization
% ******************************************

function [sys,x0,str,tss] = mdlInitialSizes(t,x,u,X_ss);

global LOData gprMdlLP_machine1 gprMdlLP_machine2  Current_Load_Target PMax LOModelData curr_iteration SteadyState gprMdlLP_machine3 gprMdlLP_machine4 gprMdlLP_machine5 total_uncertainty
% This handles initialization of the function.
% Call simsize of a sizes structure.
sizes = simsizes;
sizes.NumContStates  = 0;     % continuous states
sizes.NumDiscStates  = 0;     % discrete states
sizes.NumOutputs     = 5;     % outputs of model 
sizes.NumInputs      = 11;     % inputs of model
sizes.DirFeedthrough = 1;     % System is causal
sizes.NumSampleTimes = 1;     %
sys = simsizes(sizes);        %
x0  = X_ss;                   % Initialize the states 

str = [];	                  % set str to an empty matrix.
tss = [250,0];	              % sample time: [period, offset].
curr_iteration = 0;
total_uncertainty= [];
% ******************************************
%  Outputs
% ******************************************

function [sys] = mdlOutputs(t,x,u,Param);
global LOData gprMdlLP_machine1 gprMdlLP_machine2 Current_Load_Target PMax LOModelData SteadyState explore explore_signal gprMdlLP_machine3 gprMdlLP_machine4 gprMdlLP_machine5 significance total_uncertainty

% Inputs
% Update data history with new measurements


LOData.Load_Target=[LOData.Load_Target; u(1)];

LOData.LoadMachine1=[LOData.LoadMachine1; u(2)];
LOData.LoadMachine2=[LOData.LoadMachine2; u(3)];
LOData.LoadMachine3=[LOData.LoadMachine3; u(4)];
LOData.LoadMachine4=[LOData.LoadMachine4; u(5)];
LOData.LoadMachine5=[LOData.LoadMachine5; u(6)];

LOData.PowerMachine1=[LOData.PowerMachine1; u(7)];
LOData.PowerMachine2=[LOData.PowerMachine2; u(8)];
LOData.PowerMachine3=[LOData.PowerMachine3; u(9)];
LOData.PowerMachine4=[LOData.PowerMachine4; u(10)];
LOData.PowerMachine5=[LOData.PowerMachine5; u(11)];

operating_interval_machine1 = [56:220]';
operating_interval_machine2 = [237:537]';
operating_interval_machine3 = [194:795]';

[mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,operating_interval_machine1, 'Alpha', significance); 
[mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,operating_interval_machine2, 'Alpha', significance);
[mean_machine3, sigma_machine3,interval_machine3] = predict(gprMdlLP_machine3,operating_interval_machine3, 'Alpha', significance); 
[mean_machine4, sigma_machine4,interval_machine4] = predict(gprMdlLP_machine4,operating_interval_machine3, 'Alpha', significance);
[mean_machine5, sigma_machine5,interval_machine5] = predict(gprMdlLP_machine5,operating_interval_machine3, 'Alpha', significance); 
sum1 = sum(sigma_machine1);
sum2 = sum(sigma_machine2);
sum3 = sum(sigma_machine3);
sum4 = sum(sigma_machine4);
sum5 = sum(sigma_machine5);

total_uncertainty = [total_uncertainty; sum1+sum2+sum3+sum4+sum5];
explore = [explore; explore_signal];
disp(explore_signal)


% Steady State Detection for machine 1
mean_Load_var_machine1 = mean([LOData.LoadMachine1(end,1)-LOData.LoadMachine1(end-1,1) LOData.LoadMachine1(end-1,1)-LOData.LoadMachine1(end-2,1) LOData.LoadMachine1(end-2,1)-LOData.LoadMachine1(end-3,1)]);
mean_Power_var_machine1 = mean([LOData.PowerMachine1(end,1)-LOData.PowerMachine1(end-1,1) LOData.PowerMachine1(end-1,1)-LOData.PowerMachine1(end-2,1) LOData.PowerMachine1(end-2,1)-LOData.PowerMachine1(end-3,1)]);

% Steady State Detection for machine 2
mean_Load_var_machine2 = mean([LOData.LoadMachine2(end,1)-LOData.LoadMachine2(end-1,1) LOData.LoadMachine2(end-1,1)-LOData.LoadMachine2(end-2,1) LOData.LoadMachine2(end-2,1)-LOData.LoadMachine2(end-3,1)]);
mean_Power_var_machine2 = mean([LOData.PowerMachine2(end,1)-LOData.PowerMachine2(end-1,1) LOData.PowerMachine2(end-1,1)-LOData.PowerMachine2(end-2,1) LOData.PowerMachine2(end-2,1)-LOData.PowerMachine2(end-3,1)]);

% Steady State Detection for machine 3
mean_Load_var_machine3 = mean([LOData.LoadMachine3(end,1)-LOData.LoadMachine3(end-1,1) LOData.LoadMachine3(end-1,1)-LOData.LoadMachine3(end-2,1) LOData.LoadMachine3(end-2,1)-LOData.LoadMachine3(end-3,1)]);
mean_Power_var_machine3 = mean([LOData.PowerMachine3(end,1)-LOData.PowerMachine3(end-1,1) LOData.PowerMachine3(end-1,1)-LOData.PowerMachine3(end-2,1) LOData.PowerMachine3(end-2,1)-LOData.PowerMachine3(end-3,1)]);

% Steady State Detection for machine 4
mean_Load_var_machine4 = mean([LOData.LoadMachine4(end,1)-LOData.LoadMachine4(end-1,1) LOData.LoadMachine4(end-1,1)-LOData.LoadMachine4(end-2,1) LOData.LoadMachine4(end-2,1)-LOData.LoadMachine4(end-3,1)]);
mean_Power_var_machine4 = mean([LOData.PowerMachine4(end,1)-LOData.PowerMachine4(end-1,1) LOData.PowerMachine4(end-1,1)-LOData.PowerMachine4(end-2,1) LOData.PowerMachine4(end-2,1)-LOData.PowerMachine4(end-3,1)]);

% Steady State Detection for machine 5
mean_Load_var_machine5 = mean([LOData.LoadMachine5(end,1)-LOData.LoadMachine5(end-1,1) LOData.LoadMachine5(end-1,1)-LOData.LoadMachine5(end-2,1) LOData.LoadMachine5(end-2,1)-LOData.LoadMachine5(end-3,1)]);
mean_Power_var_machine5 = mean([LOData.PowerMachine5(end,1)-LOData.PowerMachine5(end-1,1) LOData.PowerMachine5(end-1,1)-LOData.PowerMachine5(end-2,1) LOData.PowerMachine5(end-2,1)-LOData.PowerMachine5(end-3,1)]);

if(mean_Load_var_machine1<=2 && mean_Load_var_machine2<=2 && mean_Power_var_machine1<=5 && mean_Power_var_machine2<=5 ...
        && mean_Load_var_machine3<=2 &&  mean_Power_var_machine3<=5 && mean_Load_var_machine4<=2 &&  mean_Power_var_machine4<=5 ...
        && mean_Load_var_machine5<=2 &&  mean_Power_var_machine5<=5)
    SteadyState=1;
else
    SteadyState=0;
end

% Dataset Update
if SteadyState==1
    
    LOModelData.LoadMachine1=[LOModelData.LoadMachine1;LOData.LoadMachine1(end,1)];
    LOModelData.PowerMachine1=[LOModelData.PowerMachine1;LOData.PowerMachine1(end,1)];
    
    LOModelData.LoadMachine2=[LOModelData.LoadMachine2;LOData.LoadMachine2(end,1)];
    LOModelData.PowerMachine2=[LOModelData.PowerMachine2;LOData.PowerMachine2(end,1)];
    
    LOModelData.LoadMachine3=[LOModelData.LoadMachine3;LOData.LoadMachine3(end,1)];
    LOModelData.PowerMachine3=[LOModelData.PowerMachine3;LOData.PowerMachine3(end,1)];
    
    LOModelData.LoadMachine4=[LOModelData.LoadMachine4;LOData.LoadMachine4(end,1)];
    LOModelData.PowerMachine4=[LOModelData.PowerMachine4;LOData.PowerMachine4(end,1)];
      
    LOModelData.LoadMachine5=[LOModelData.LoadMachine5;LOData.LoadMachine5(end,1)];
    LOModelData.PowerMachine5=[LOModelData.PowerMachine5;LOData.PowerMachine5(end,1)];
  
    
    % Model Update
    gprMdlLP_machine1 = fitrgp(LOModelData.LoadMachine1,LOModelData.PowerMachine1, 'KernelFunction','squaredexponential');
    gprMdlLP_machine2 = fitrgp(LOModelData.LoadMachine2,LOModelData.PowerMachine2, 'KernelFunction','squaredexponential');
    gprMdlLP_machine3 = fitrgp(LOModelData.LoadMachine3,LOModelData.PowerMachine3, 'KernelFunction','squaredexponential');
    gprMdlLP_machine4 = fitrgp(LOModelData.LoadMachine4,LOModelData.PowerMachine4, 'KernelFunction','squaredexponential');
    gprMdlLP_machine5 = fitrgp(LOModelData.LoadMachine5,LOModelData.PowerMachine5, 'KernelFunction','squaredexponential');
 
end

% Load optimization
Current_Load_Target = LOData.Load_Target(end,1);
PMax = 1580;

% options = optimoptions('fmincon','MaxIterations',500000,'ConstraintTolerance',1e-14, "EnableFeasibilityMode",true, "SubproblemAlgorithm","cg", "StepTolerance",1e-10, "MaxFunctionEvaluations",5000);
%  , "StepTolerance",1e-14, "OptimalityTolerance",1e-14);
options = optimoptions('fmincon',"EnableFeasibilityMode",true, "SubproblemAlgorithm","cg", 'MaxIterations',500000, "Display","iter");
gen_load_target = fmincon(@LoadObjFun_pure_exp,[LOData.LoadMachine1(end,1),LOData.LoadMachine2(end,1), ...
        LOData.LoadMachine3(end,1),LOData.LoadMachine4(end,1),LOData.LoadMachine5(end,1)],[],[],[],[],[56,237,194,194,194],[220,537,795,795,795],@MaxPowerConstraint, options);

% Send outputs
sys(1) = gen_load_target(1); 
sys(2) = gen_load_target(2);      
sys(3) = gen_load_target(3);
sys(4) = gen_load_target(4);
sys(5) = gen_load_target(5);
% end





