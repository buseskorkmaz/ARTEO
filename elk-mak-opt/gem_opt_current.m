ilimit = 160*1.41;

safe_seed1 = [20; 4];
safe_seed2 = [6; 25];

% safe_seed1 = [10; 15; 7];
% safe_seed2 = [2; 12; 20];

ref_signal = Step_reference_generator();
% ref_signal = load('ref_signal_current.mat').ref_signal;

gprMdlLP_machine1 = fitrgp(safe_seed1, Calc_current1(safe_seed1));
gprMdlLP_machine2 = fitrgp(safe_seed2, Calc_current2(safe_seed2));

prev_torque_one = safe_seed1;
prev_current_one = Calc_current1(safe_seed1);

prev_torque_two = safe_seed2;
prev_current_two = Calc_current2(safe_seed2);
opt_references = [];
predicted_one = [];
predicted_two = [];
explore = [false];
total_unc = [];

means_machine1 = [];
means_machine2 = [];

sigmas_machine1 = [];
sigmas_machine2 = [];

for i = 1:length(ref_signal)

    x = [0:38]';
    [mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,x); 
    [mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,x);
    
    total_unc = [total_unc; sum(sigma_machine1) + sum(sigma_machine2)];
    means_machine1 = [means_machine1;mean_machine1];
    means_machine2 = [means_machine2;mean_machine2];
    sigmas_machine1 = [sigmas_machine1;sigma_machine1];
    sigmas_machine2 = [sigmas_machine1];sigma_machine2;

    if i < 5

        % m1
        f = figure;
        plot(x, mean_machine1);
        hold
        plot(x, Calc_current1(x));
        legend("Predict M1", "Real M1");

        % m2
        f = figure;
        plot(x, mean_machine2);
        hold
        plot(x, Calc_current2(x));
        legend("Predict M2", "Real M2");
    end
    
    if i > 1 && ref_signal(i-1) - real_current_one - real_current_two < 5 &&ref_signal(i) == ref_signal(i-1) &&(abs(prev_torque_one(end,1) - prev_torque_one(end-1,1)) < 0.5) && abs(prev_torque_two(end,1) - prev_torque_two(end-1,1)) < 0.5
        exp = true;
    else
        exp = false;
    end

    explore = [explore; exp];

    options = optimoptions('fmincon',"EnableFeasibilityMode",true, "SubproblemAlgorithm","cg", 'MaxIterations',500000, "Display","iter");
    ref_torque = fmincon(@(x)Objective_function(x,ref_signal(i),gprMdlLP_machine1, gprMdlLP_machine2,exp), ...
        [prev_torque_one(end,1), prev_torque_two(end,1)],[],[],[],[],[0, 0],[38,38],@(x)Max_current_constraint(x,gprMdlLP_machine1, gprMdlLP_machine2), options);
    
    [mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,ref_torque(1)); 
    [mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,ref_torque(2));

    opt_references = [opt_references; mean_machine1+mean_machine2];

    prev_torque_one = [prev_torque_one; ref_torque(1)];
    prev_torque_two = [prev_torque_two; ref_torque(2)];

    real_current_one = Calc_current1(ref_torque(1));
    real_current_two = Calc_current2(ref_torque(2));

    prev_current_one = [prev_current_one; real_current_one];
    prev_current_two = [prev_current_two; real_current_two];

    predicted_one = [predicted_one;mean_machine1];
    predicted_two = [predicted_two;mean_machine2];
    
    if abs(prev_torque_one(end,1) - prev_torque_one(end-1,1)) > 0.5
        gprMdlLP_machine1 = fitrgp(prev_torque_one, prev_current_one);
    end

    if abs(prev_torque_two(end,1) - prev_torque_two(end-1,1)) > 0.5
        gprMdlLP_machine2 = fitrgp(prev_torque_two, prev_current_two);
    end
    
end

% save_matrix(means_machine1, means_machine2, sigmas_machine1, sigmas_machine2, ref_signal, prev_current_one(3:end), prev_current_two(3:end), prev_torque_one(3:end), prev_torque_two(3:end), explore)
% figure;
% set(0,'DefaultLineLineWidth',2)
% % yyaxis left;
% stairs([1:length(ref_signal)]', ref_signal,LineWidth=2, Color="k");
% hold
% stairs([1:length(ref_signal)]', prev_current_one_z25(3:end) + prev_current_two_z25(3:end), "--",LineWidth=2, Color = "#ff748c")
% stairs([1:length(ref_signal)]', prev_current_one_z50(3:end) + prev_current_two_z50(3:end), ":", LineWidth=2, Color = "#008866" )
% yline(ilimit,'--', Color="#0000ff",LineWidth=1)
% % yyaxis right;
% stairs([1:length(ref_signal)]', predicted_two_z25,LineWidth=2, Color="b")
% stairs([1:length(ref_signal)]', predicted_two_z50,"-", LineWidth=2,Color="#FFA500")
% xlim([1 length(ref_signal)])
% xlabel("Time")
% ylabel("Current")
% legend("Reference current", "Total produced current (z = 25)", "Total produced current (z = 50)", "Maximum safe current", "Machine-2 current (z = 25)", "Machine-2 current (z = 50)")
% legend("Reference current", "Total produced current", "Maximum safe current")
% saveas(gcf, "ref_vs_opt.png")

figure;
set(0,'DefaultLineLineWidth',2)
stairs([1:length(ref_signal)]', predicted_one+predicted_two, Color="#00ffff", LineWidth=2);
hold
stairs([1:length(ref_signal)]', prev_current_one(3:end)+prev_current_two(3:end), "--",LineWidth=2)
% stairs([1:length(ref_signal)]', prev_current_one(3:end),LineWidth=2)
% stairs([1:length(ref_signal)]', prev_current_two(3:end),LineWidth=2)
yline(ilimit,'--', Color="#0000ff",LineWidth=1)
xlim([1 length(ref_signal)])
legend("Predicted", "Real", "Max")
% saveas(gcf, "pred_vs_real.png")

% total unc comparison
figure;
set(0,'DefaultLineLineWidth',2)
xlim([1 length(ref_signal)])
stairs([1:length(ref_signal)]', total_unc_5, LineWidth=2);
hold
stairs([1:length(ref_signal)]', total_unc_z10, LineWidth=2);
stairs([1:length(ref_signal)]', total_unc_25, LineWidth=2);
stairs([1:length(ref_signal)]', total_unc_50, LineWidth=2)
stairs([1:length(ref_signal)]', total_unc_100, LineWidth=2)
xlim([1 length(ref_signal)])
xlabel("Time")
ylabel("Total uncertainty")
% legend("z = 5", "z = 10", "z = 25", "z = 50", "z = 100")
% saveas(gcf, "total_uncertainty.png")
% 
% ref comparison
% figure;
% set(0,'DefaultLineLineWidth',2)
% xlim([1 length(ref_signal)])
% stairs([1:length(ref_signal)]', prev_torque_one(3:end), LineWidth=2);
% hold
% stairs([1:length(ref_signal)]', prev_torque_one_z10(3:end), LineWidth=2);
% stairs([1:length(ref_signal)]', prev_torque_one_z25(3:end), LineWidth=2);
% stairs([1:length(ref_signal)]', prev_torque_one_z50(3:end), LineWidth=2);
% stairs([1:length(ref_signal)]', prev_torque_one_z100(3:end), LineWidth=2);
% xlim([1 length(ref_signal)])
% legend("Ref Torque (z=5)", "Ref Torque (z=10)", "Ref Torque (z=25)", "Ref Torque (z=50)", "Ref Torque (z=100)")


% total unc comparison
% figure;
% set(0,'DefaultLineLineWidth',2)
% xlim([1 length(ref_signal)])
% stairs([1:length(ref_signal)]', prev_current_one(3:end), LineWidth=2);
% hold
% stairs([1:length(ref_signal)]', predicted_one, "--", LineWidth=2);
% % stairs([1:length(ref_signal)]', prev_current_one_z10(3:end), LineWidth=2);
% % stairs([1:length(ref_signal)]', predicted_one_z10, "--", LineWidth=2);
% % stairs([1:length(ref_signal)]', prev_current_one_z25(3:end), LineWidth=2);
% % stairs([1:length(ref_signal)]', predicted_one_z25, "--",LineWidth=2);
% % stairs([1:length(ref_signal)]', prev_current_one_z50(3:end), LineWidth=2)
% % stairs([1:length(ref_signal)]', predicted_one_z50, "--",LineWidth=2);
% stairs([1:length(ref_signal)]', prev_current_one_z100(3:end), LineWidth=2)
% stairs([1:length(ref_signal)]', predicted_one_z100, "--",LineWidth=2);
% xlim([1 length(ref_signal)])
% legend("Real current (z=5)","Predicted current (z=5)", "Real current (z=50)", "Predicted current (z=50)", "Real current (z=100)", "Predicted current (z=100)")
% %     "Real current (z=10)", "Predicted current (z=10)", "Real current (z=25)", "Predicted current (z=25)")

function ref_signal = Step_reference_generator()

        ref_signal = repelem([200]',25, 1);
%         ref_signal = repelem(normrnd(160, 50, [20,1]),10, 1);
end
   
function current = Calc_current1(x)    
    current = 5*1e-14*power(x,3) - 1e-13*power(x,2) + 6.5108*x + 9*1e-12;
end

function current = Calc_current2(x)
    current = 9*1e-15*power(x,3) + 5*1e-14*power(x,2) + 6.5108*x + 3*1e-11;
end

function value = Objective_function(x, ref, gprMdlLP_machine1, gprMdlLP_machine2, exp)
    [mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,x(1)); 
    [mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,x(2));
    if exp == true
        z=25;
    else
        z=0;
    end
    
    value =  power(ref - mean_machine1 - mean_machine2,2) - z * (sigma_machine1 + sigma_machine2);
end

function [c,ceq] = Max_current_constraint(x, gprMdlLP_machine1, gprMdlLP_machine2)
    ilimit = 160*1.41;

    [mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,x(1)); 
    [mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,x(2));
      
    i_upper_one = mean_machine1 + 5 * sigma_machine1;
    i_upper_two = mean_machine2 + 5 * sigma_machine2;

    c(1) = power(i_upper_one+i_upper_two,2) - power(ilimit,2);
    ceq = [];
end

function save_matrix(means_machine1, means_machine2, sigmas_machine1, sigmas_machine2, ref_signal, prev_current_one, prev_current_two, prev_torque_one, prev_torque_two, explore)
    
    writematrix(means_machine1, "means_machine1.csv")
    writematrix(means_machine2, "means_machine2.csv")
    writematrix(sigmas_machine1, "sigmas_machine1.csv")
    writematrix(sigmas_machine2, "sigmas_machine2.csv")
    writematrix(ref_signal, "ref_signal.csv") 
    writematrix(prev_current_one, "prev_current_one.csv")
    writematrix(prev_current_two, "prev_current_two.csv")
    writematrix(prev_torque_one, "prev_torque_one.csv")
    writematrix(prev_torque_two, "prev_torque_two.csv")
    writematrix(explore, "explore.csv")
   
end
