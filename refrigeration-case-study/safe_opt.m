% function [Q] = safe_opt()

% len(inputs.shape), 2*len(self.gps)
% 2 machine comparison 

operating_interval_machine1 = [56:220]';
% operating_interval_machine2 = [237:537]';
operating_interval_machine3 = [194:795]';

% in-memory
% operating_interval_matrix = [];
% 
% for i = 56:220
%     for j=194:795
%         operating_interval_matrix = [operating_interval_matrix; [i, j]];
%     end
% end

% common_operating_interval = [56:795]';

% operating_interval_machine1 = padarray(operating_interval_machine1,795-194-220+56,220, "post");
% operating_interval_machine2 = padarray(operating_interval_machine2,795-194-537+237,537, "post");


loads = [LOModelData.LoadMachine1(1), LOModelData.LoadMachine4(1)];
powers = [LOModelData.PowerMachine1(1), LOModelData.PowerMachine4(1)];
f = (powers(1) + powers(2))^2 + 1000*(loads(1) + loads(2) - 310)^2;

gprMdlLP_machine1 = fitrgp(loads, f, 'KernelFunction','squaredexponential');

[mean, sigma,interval] = predict(gprMdlLP_machine1,operating_interval_matrix, 'Alpha', significance); 

beta = 2;

qt = [mean - beta * sigma, mean + beta * sigma];

S = operating_interval_matrix(qt(:,2) < 508,:);

% expanders
G = S;

% maximizers
M = S;

% for t = 1:42000
    
    [mean, sigma,interval] = predict(gprMdlLP_machine1,operating_interval_matrix, 'Alpha', significance); 
   
    qt = [mean - beta * sigma, mean + beta * sigma];
    
    S = operating_interval_matrix(qt(:,2) < 508,:);

    max_lower = max(qt(:,1));
    
    M = operating_interval_matrix(qt(:,2) < 508 & qt(:,2) > max_lower,:);
  

% end