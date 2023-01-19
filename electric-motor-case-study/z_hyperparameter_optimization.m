
% grid-search
% z = [5, 10, 25, 50, 100];
% avg_regrets = [];
% 
% for j = 1:length(z)
%     regret = simulation_func(z(j));
%     avg_regrets = [avg_regrets; regret];
% end

% bayesian-optimization
num = optimizableVariable('z',[1,100],'Type','integer');
fun = @(x)simulation_func(x.z);
results = bayesopt(fun,[num],'Verbose',0,...
    'AcquisitionFunctionName','lower-confidence-bound', MaxObjectiveEvaluations=35)

a = sort([results.XTrace.z, results.ObjectiveTrace]);
gprMdlLP_bo = fitrgp(a(1:end,1), a(1:end,2));
range = [1:100]';
[mean, sigma, interval] = predict(gprMdlLP_bo,range);
upper = mean+1.96*sigma;
lower = mean -1.96*sigma;
[min_feasible_z, idx] = min(lower);

figure;
set(0,'DefaultLineLineWidth',2)
plot(range, mean, Color=[1 0 0]);
hold;
shade(range, mean, range, upper,'FillType', [1 2;2 1], "FillColor", [0 0 0.8],"FillAlpha", 0.1);
shade(range, lower, range, mean,'FillType', [1 2;2 1], "FillColor", [0 0 0.8],"FillAlpha", 0.1);
plot(range, upper, Color="b");
plot(range, lower, Color="b");
m = plot(range, mean, "Color",[1 0 0]);
v = plot([1], [-10^6], Color=[0 0 0.8]);
chosen= scatter(a(1:end,1), a(1:end,2), 'filled','o', MarkerEdgeColor="k", MarkerFaceColor="k", LineWidth=1);
min_feasible = scatter([idx], [min_feasible_z], 100, '*',LineWidth=1, MarkerEdgeColor="#7F00FF	");
xlim([1 100]);
ylim([-10^4*1, 4.5*10^4])
xlabel("z");
ylabel("Cumulative regret at the end of simulation")

legend([m v  chosen min_feasible], ["BO mean", "BO confidence bounds", "Evaluated points", "Lowest cumulative regret"])


% i = 300;
% d = (1:i)';
% figure;
% set(0,'DefaultLineLineWidth',2)
% plot([1:i]', cumsum(avg_regrets(1:300)), LineWidth=2)
% hold
% plot([1:i]', cumsum(avg_regrets(301:600)), LineWidth=2)
% plot([1:i]', cumsum(avg_regrets(601:900)), LineWidth=2)
% plot([1:i]', cumsum(avg_regrets(901:1200)), LineWidth=2)
% plot([1:i]', cumsum(avg_regrets(1201:1500)), LineWidth=2)
% % semilogy([1:i]', cumsum(avg_regrets(1501:1800)), LineWidth=2)
% xlim([1 i])
% % ylim([10 10^4])
% xlabel("Time")
% ylabel("Cumulative regret")
% legend("ARTEO regret (z=5)","ARTEO regret (z=10)","ARTEO regret (z=25)", ...
%     "ARTEO regret (z=50)","ARTEO regret (z=100)","ARTEO regret (z=100)")

function avg_regret = simulation_func(z)

    ilimit = 160*1.41;
    
    safe_seed1 = [20; 4];
    safe_seed2 = [6; 25];
    
    % safe_seed1 = [10; 15; 7];
    % safe_seed2 = [2; 12; 20];
    
%     ref_signal = Step_reference_generator();
%     ref_signal = load('ref_signal_current.mat').ref_signal;
    ref_signal = load('ref_signal_comp.mat').ref_signal_comp;
    
    gprMdlLP_machine1 = fitrgp(safe_seed1, Calc_current1(safe_seed1));
    gprMdlLP_machine2 = fitrgp(safe_seed2, Calc_current2(safe_seed2));
    
    prev_torque_one = safe_seed1;
    prev_current_one_arteo = Calc_current1(safe_seed1);
    
    prev_torque_two = safe_seed2;
    prev_current_two_arteo = Calc_current2(safe_seed2);
    opt_references = [];
    predicted_one = [];
    predicted_two = [];
    explore = [false];
%     total_unc = [];
    
%     means_machine1 = [];
%     means_machine2 = [];
%     
%     sigmas_machine1 = [];
%     sigmas_machine2 = [];
    
    arteo_avg_regret_one = [];
    z1=z;

    for i = 1:300
        
%         if mod(i, 10) == 0
%             z1 =  z1/i;
%         end

        if ref_signal(i) > ilimit
            optimal = ilimit;
        else
            optimal = ref_signal(i);
        end
    
        x = [0:38]';
        [mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,x); 
        [mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,x);
        
%         total_unc = [total_unc; sum(sigma_machine1) + sum(sigma_machine2)];
%         means_machine1 = [means_machine1;mean_machine1];
%         means_machine2 = [means_machine2;mean_machine2];
%         sigmas_machine1 = [sigmas_machine1;sigma_machine1];
%         sigmas_machine2 = [sigmas_machine1];sigma_machine2;
        
        if i > 1 && ref_signal(i-1) - real_current_one - real_current_two < 5 &&ref_signal(i) == ref_signal(i-1) &&(abs(prev_torque_one(end,1) - prev_torque_one(end-1,1)) < 0.5) && abs(prev_torque_two(end,1) - prev_torque_two(end-1,1)) < 0.5
            exp = true;
        else
            exp = false;
        end
    
        explore = [explore; exp];
    
        options = optimoptions('fmincon',"EnableFeasibilityMode",true, "SubproblemAlgorithm","cg", 'MaxIterations',500000, "Display","iter");
        ref_torque = fmincon(@(x)ARTEO_Objective_function(x,ref_signal(i),gprMdlLP_machine1, gprMdlLP_machine2,exp,z1), ...
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
    
        arteo_avg_regret_one = [arteo_avg_regret_one; abs(optimal-Calc_current1(ref_torque(1))-Calc_current2(ref_torque(2)))];
         
        if abs(prev_torque_one(end,1) - prev_torque_one(end-1,1)) > 0.5
            gprMdlLP_machine1 = fitrgp(prev_torque_one, prev_current_one_arteo);
        end
    
        if abs(prev_torque_two(end,1) - prev_torque_two(end-1,1)) > 0.5
            gprMdlLP_machine2 = fitrgp(prev_torque_two, prev_current_two_arteo);
        end
        
        avg_regret_cum = cumsum(arteo_avg_regret_one);
        avg_regret = avg_regret_cum(end);
    end

%     figure;
%     set(0,'DefaultLineLineWidth',2)
%     stairs([1:i]', ref_signal(1:i),LineWidth=2, Color="k");
%     hold
%     stairs([1:i]', prev_current_one_arteo(3:i+2) + prev_current_two_arteo(3:i+2), "--",LineWidth=2, Color = "#ff748c")
%     yline(ilimit,'--', Color="#0000ff",LineWidth=1)
%     xlim([1 i])
%     ylim([0 500])
%     xlabel("Time")
%     ylabel("Current")
%     legend("Reference current", "Total produced current", "Maximum safe current")

end


function ref_signal = Step_reference_generator()

        ref_signal = repelem([200]',300, 1);
%          ref_signal = repelem(normrnd(160, 50, [100,1]),10, 1);
end
   
function current = Calc_current1(x)    
    current = 5*1e-14*power(x,3) - 1e-13*power(x,2) + 6.5108*x + 9*1e-12;
end

function current = Calc_current2(x)
    current = 9*1e-15*power(x,3) + 5*1e-14*power(x,2) + 6.5108*x + 3*1e-11;
end

function value = ARTEO_Objective_function(x, ref, gprMdlLP_machine1, gprMdlLP_machine2, exp,z1)
    [mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,x(1)); 
    [mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,x(2));
    if exp == true
        z=z1;
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

