function [c,ceq] = MaxPowerConstraint(x) 
global  gprMdlLP_machine1 gprMdlLP_machine2 PMax LOData significance curr_iteration gprMdlLP_machine3 gprMdlLP_machine4 gprMdlLP_machine5 
        iterations = length(unique(LOData.Load_Target));

        if(iterations > curr_iteration && significance >= 0.05 )
            decay = 0.01 ;
            significance = significance * (1. / (1+decay * iterations));
            curr_iteration = iterations;   
        end
        
        [mean_machine_1,~,PowerPred_Int_machine1] = predict(gprMdlLP_machine1,x(1), 'Alpha', significance); 
        [mean_machine_2,~,PowerPred_Int_machine2] = predict(gprMdlLP_machine2,x(2), 'Alpha', significance);
        [mean_machine_3,~,PowerPred_Int_machine3] = predict(gprMdlLP_machine3,x(3), 'Alpha', significance);
        [mean_machine_4,~,PowerPred_Int_machine4] = predict(gprMdlLP_machine4,x(4), 'Alpha', significance);
        [mean_machine_5,~,PowerPred_Int_machine5] = predict(gprMdlLP_machine5,x(5), 'Alpha', significance);
         c(1) = max(PowerPred_Int_machine1)+max(PowerPred_Int_machine2)+max(PowerPred_Int_machine3)+max( ...
             PowerPred_Int_machine4)+max(PowerPred_Int_machine5)-PMax;

%          Gaussian Process Optimization in the Bandit Setting paper's bounds           
%          beta_machine1 = sqrt(2 * log(abs(x(1))*iterations^2*pi^2/(6*0.05)));
%          beta_machine2 = sqrt(2 * log(abs(x(2))*iterations^2*pi^2/(6*0.05)));
         
         c(1) = max(PowerPred_Int_machine1)+max(PowerPred_Int_machine2)+max(PowerPred_Int_machine3)+max(PowerPred_Int_machine4)+max(PowerPred_Int_machine5)-PMax;
         ceq = [];

