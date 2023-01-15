ilimit = 160*1.41;

safe_seeds = readmatrix("safe_seeds.csv");
safe_seed1 = safe_seeds(1:101,1:end);
safe_seed2 = safe_seeds(102:201, 1:end);

% ref_signal = Step_reference_generator();
% ref_signal = load('ref_signal_current.mat').ref_signal;
ref_signal = load('ref_signal_comp.mat').ref_signal_comp;

for j = 33:100

    disp("---------------------iteration"+string(j))

    gprMdlLP_machine1 = fitrgp(safe_seed1(j,1:end)', Calc_current1(safe_seed1(j,1:end)'));
    gprMdlLP_machine2 = fitrgp(safe_seed2(j,1:end)', Calc_current2(safe_seed2(j,1:end)'));
    
    refs  = [200; 200];
    limit = [ilimit; ilimit];
    
    prev_obj = power(refs - Calc_current1(safe_seed1(j,1:end)') - Calc_current2(safe_seed2(j,1:end)'),2);
    prev_constraint = limit - Calc_current1(safe_seed1(j,1:end)')- Calc_current2(safe_seed2(j,1:end)');
    
    safe_ucb_obj = fitrgp([refs,safe_seed1(j,1:end)',safe_seed2(j,1:end)'],  prev_obj, Standardize=true);
    safe_ucb_constraint = fitrgp([safe_seed1(j,1:end)',safe_seed2(j,1:end)'], prev_constraint);
    
    prev_torque_one = safe_seed1(j,1:end)';
    prev_current_one_arteo = Calc_current1(safe_seed1(j,1:end)');
    
    prev_torque_two = safe_seed2(j,1:end)';
    prev_current_two_arteo = Calc_current2(safe_seed2(j,1:end)');
    opt_references = [];
    predicted_one = [];
    predicted_two = [];
    explore = [false];
    total_unc = [];
    
    means_machine1 = [];
    means_machine2 = [];
    
    sigmas_machine1 = [];
    sigmas_machine2 = [];
    
    arteo_avg_regret_one = [];
    arteo_avg_regret_two = [];
    
    safe_ucb_regret_one = [];
    safe_ucb_regret_two = [];
    
    predicted_obj = prev_obj;
    predicted_constraint = prev_constraint;
    
    prev_current_one_ucb = Calc_current1(safe_seed1(j,1:end)');
    prev_current_two_ucb = Calc_current2(safe_seed2(j,1:end)');
    
    prev_torque_one_ucb = safe_seed1(j,1:end)';
    prev_torque_two_ucb = safe_seed2(j,1:end)';
    
    for i = 1:200
    
        x = [0:38]';
        [mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,x); 
        [mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,x);
        
        total_unc = [total_unc; sum(sigma_machine1) + sum(sigma_machine2)];
        means_machine1 = [means_machine1;mean_machine1];
        means_machine2 = [means_machine2;mean_machine2];
        sigmas_machine1 = [sigmas_machine1;sigma_machine1];
        sigmas_machine2 = [sigmas_machine1];sigma_machine2;
        
        if i > 1 && ref_signal(i-1) - real_current_one - real_current_two < 5 &&ref_signal(i) == ref_signal(i-1) &&(abs(prev_torque_one(end,1) - prev_torque_one(end-1,1)) < 0.5) && abs(prev_torque_two(end,1) - prev_torque_two(end-1,1)) < 0.5
            exp = true;
        else
            exp = false;
        end
    
        explore = [explore; exp];
    
        options = optimoptions('fmincon',"EnableFeasibilityMode",true, "SubproblemAlgorithm","cg", 'MaxIterations',500000, "Display","final");
        ref_torque = fmincon(@(x)ARTEO_Objective_function(x,ref_signal(i),gprMdlLP_machine1, gprMdlLP_machine2,exp), ...
            [prev_torque_one(end,1), prev_torque_two(end,1)],[],[],[],[],[0, 0],[38,38],@(x)Max_current_constraint(x,gprMdlLP_machine1, gprMdlLP_machine2), options);
        
        [mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,ref_torque(1)); 
        [mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,ref_torque(2));
    
        opt_references = [opt_references; mean_machine1+mean_machine2];
    
        prev_torque_one = [prev_torque_one; ref_torque(1)];
        prev_torque_two = [prev_torque_two; ref_torque(2)];
    
        real_current_one = Calc_current1(ref_torque(1)) + normrnd(0,1,1);
        real_current_two = Calc_current2(ref_torque(2)) + normrnd(0,1,1);
    
        prev_current_one_arteo = [prev_current_one_arteo; real_current_one];
        prev_current_two_arteo = [prev_current_two_arteo; real_current_two];
    
        predicted_one = [predicted_one;mean_machine1];
        predicted_two = [predicted_two;mean_machine2];
    
    %     arteo_avg_regret_one = [arteo_avg_regret_one; mean(abs(real_current_one-mean_machine1))];
    %     arteo_avg_regret_two = [arteo_avg_regret_two; mean(abs(real_current_two-mean_machine2))];
    %     
        if abs(prev_torque_one(end,1) - prev_torque_one(end-1,1)) > 0.5
            gprMdlLP_machine1 = fitrgp(prev_torque_one, prev_current_one_arteo);
        end
    
        if abs(prev_torque_two(end,1) - prev_torque_two(end-1,1)) > 0.5
            gprMdlLP_machine2 = fitrgp(prev_torque_two, prev_current_two_arteo);
        end
        
        % safe ucb       
        [x1, x2] = Safe_UCB_Objective_function(ref_signal(i),safe_ucb_obj, safe_ucb_constraint); 
    
        [mean_obj, sigma_obj,interval_machine1] = predict(safe_ucb_obj,[ref_signal(i);x1;x2]'); 
        [mean_constraint, sigma_constraint,interval_machine2] = predict(safe_ucb_constraint,[x1;x2]');
        
        predicted_obj = [predicted_obj; mean_obj];
        predicted_constraint = [predicted_constraint; mean_constraint];
    
        prev_torque_one_ucb = [prev_torque_one_ucb; x1];
        prev_torque_two_ucb = [prev_torque_two_ucb; x2];
    
        prev_current_one_ucb = [prev_current_one_ucb; Calc_current1(x1)];
        prev_current_two_ucb = [prev_current_two_ucb; Calc_current2(x2)];
    
        real_obj = (ref_signal(i) - Calc_current1(x1) -  Calc_current2(x2))^2 + normrnd(0,1,1);
        real_constraint = ilimit-Calc_current1(x1)-Calc_current2(x2) + normrnd(0,1,1);
    
        prev_obj = [prev_obj; real_obj];
        prev_constraint = [prev_constraint; real_constraint];
    
    %     if i > 1 && ref_signal(i) ~= ref_signal(i-1)
            safe_ucb_obj = fitrgp([[refs', ref_signal(1:i)']',prev_torque_one_ucb,prev_torque_two_ucb],  prev_obj, Standardize=true);
            safe_ucb_constraint = fitrgp([prev_torque_one_ucb,prev_torque_two_ucb], prev_constraint);
    %     end
     
    %     safe_ucb_regret_one = [safe_ucb_regret_one; mean(abs(real_current_one_ucb-mean_machine1))];
    %     safe_ucb_regret_two = [safe_ucb_regret_two; mean(abs(real_current_two-mean_machine2))];
     
    
    end

    writematrix(prev_current_one_arteo+string(j), "prev_current_one_arteo"+string(j)+".csv")
    writematrix(prev_current_two_arteo+string(j), "prev_current_two_arteo"+string(j)+".csv")
    writematrix(prev_current_one_ucb+string(j), "prev_current_one_ucb"+string(j)+".csv")
    writematrix(prev_current_two_ucb+string(j), "prev_current_two_ucb"+string(j)+".csv")
end

% save_matrix(means_machine1, means_machine2, sigmas_machine1, sigmas_machine2, ref_signal, prev_current_one(3:end), prev_current_two(3:end), prev_torque_one(3:end), prev_torque_two(3:end), explore)
figure;
set(0,'DefaultLineLineWidth',2)
stairs([1:200]', ref_signal(1:200),LineWidth=2, Color="k");
hold
stairs([1:200]', prev_current_one_arteo(3:202) + prev_current_two_arteo(3:202), "--",LineWidth=2, Color = "#ff748c")
stairs([1:200]', prev_current_one_ucb(3:202) + prev_current_two_ucb(3:202), ":", LineWidth=2, Color = "#005aff")
yline(ilimit,'--', Color="#0000ff",LineWidth=1)
xlim([1 200])
ylim([0 500])
xlabel("Time")
ylabel("Current")
legend("Reference current", "ARTEO produced current (z = 25)", "Safe-UCB produced current", "Maximum safe current")
% legend("Reference current", "Total produced current", "Maximum safe current")
% saveas(gcf, "ref_vs_opt.png")

figure;
set(0,'DefaultLineLineWidth',2)
stairs([1:400]', predicted_one+predicted_two, Color="#00ffff", LineWidth=2);
hold
stairs([1:400]', prev_current_one_arteo(3:402)+prev_current_two_arteo(3:402), "--",LineWidth=2)
yline(ilimit,'--', Color="#0000ff",LineWidth=1)
xlim([1 length(ref_signal)])
legend("Predicted", "Real", "Max")
% saveas(gcf, "pred_vs_real.png")

figure;
set(0,'DefaultLineLineWidth',2)
stairs([1:400]', predicted_obj(3:402), Color="#00ffff", LineWidth=2);
hold
stairs([1:400]', prev_obj(3:402), "--",LineWidth=2)
% yline(ilimit,'--', Color="#0000ff",LineWidth=1)
xlim([1 400])
legend("Predicted", "Real", "Max")
% saveas(gcf, "pred_vs_real.png")


% regret comparison
% figure;
% set(0,'DefaultLineLineWidth',2)
% % stairs([1:length(ref_signal)]', avg_regret_one_z25,  LineWidth=2)
% plot([1:25]', normalize(avg_regret_one_z25(1:25)),  LineWidth=2)
% hold
% % stairs([1:length(ref_signal)]', avg_regret_one_z50,  LineWidth=2)
% plot([1:25]', normalize(avg_regret_one_z50(1:25)),  LineWidth=2)
% % stairs([1:length(ref_signal)]', avg_regret_one_z100,  LineWidth=2)
% plot([1:25]', normalize(avg_regret_one_z100(1:25)),  LineWidth=2)
% xlim([1 25])
% legend("Machine2-regret (z=25)", "Machine2-regret (z=50)", "Machine2-regret (z=100)")

function ref_signal = Step_reference_generator()

%         ref_signal = repelem([200]',25, 1);
         ref_signal = repelem(normrnd(160, 50, [100,1]),10, 1);
end
   
function current = Calc_current1(x)    
    current = 5*1e-14*power(x,3) - 1e-13*power(x,2) + 6.5108*x + 9*1e-12;
end

function current = Calc_current2(x)
    current = 9*1e-15*power(x,3) + 5*1e-14*power(x,2) + 6.5108*x + 3*1e-11;
end

function value = ARTEO_Objective_function(x, ref, gprMdlLP_machine1, gprMdlLP_machine2, exp)
    [mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,x(1)); 
    [mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,x(2));
    if exp == true
        z=25;
    else
        z=0;
    end
    
    value =  power(ref - mean_machine1 - mean_machine2,2) - z * (sigma_machine1 + sigma_machine2);
end

function [x1, x2] = Safe_UCB_Objective_function(ref, safe_ucb_obj, safe_ucb_constraint)
    refs = repelem([ref],39, 1);
    x = [0:38]';
    input = [refs, x, x];
    [mean_obj, sigma_obj,interval] = predict(safe_ucb_obj,input); 
    [mean_constraint, sigma_constraint,interval] = predict(safe_ucb_constraint,[x,x]);
    [mean_obj_sorted, idxs]= sort(mean_obj - 5 * sigma_obj, "ascend");
%     x1 = x(idxs(1));
%     x2 = x(idxs(1));
     
    for i = 1:length(x)
        idx = idxs(i);
        if mean_constraint(idx) + 5*sigma_constraint(idx) >= 0
           x1 = x(idx);
           x2 = x(idx);
           break
        end
    end

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
