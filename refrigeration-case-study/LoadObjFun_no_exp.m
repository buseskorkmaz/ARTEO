function f = LoadObjFun_no_exp(x) 
global  Current_Load_Target  gprMdlLP_machine1 gprMdlLP_machine2 SteadyState significance LOData explore_signal gprMdlLP_machine3 gprMdlLP_machine4 gprMdlLP_machine5
        [mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,x(1), 'Alpha', significance); 
        [mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,x(2), 'Alpha', significance);
        [mean_machine3, sigma_machine3,interval_machine3] = predict(gprMdlLP_machine3,x(3), 'Alpha', significance);
        [mean_machine4, sigma_machine4,interval_machine4] = predict(gprMdlLP_machine4,x(4), 'Alpha', significance);
        [mean_machine5, sigma_machine5,interval_machine5] = predict(gprMdlLP_machine5,x(5), 'Alpha', significance);
               
%       no  exploration
        f = (mean_machine1+mean_machine2+mean_machine3+mean_machine4+mean_machine5)^2 + 1000*(x(1)+x(2)+x(3)+x(4)+x(5)- Current_Load_Target)^2;
