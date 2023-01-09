ilimit = 160*1.41;

safe_seed1 = [20; 4];
safe_seed2 = [6; 25];

% safe_seed1 = [10; 15; 7];
% safe_seed2 = [2; 12; 20];

% ref_signal = Step_reference_generator();
ref_signal = load('ref_signal_torque.mat').ref_signal;

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

for i = 1:length(ref_signal)
    
    if i < 5
        % m1
        x = [0:38]';
        [mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,x); 
        [mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,x);
        
        f = figure;
        plot(x, mean_machine1);
        hold
        plot(x, Calc_current1(x));
        legend("Predict M1", "Real M1");
    
        f = figure;
        plot(x, mean_machine2);
        hold
        plot(x, Calc_current2(x));
        legend("Predict M2", "Real M2");
    end
    
    if i > 1 && ref_signal(i) == ref_signal(i-1) &&(abs(prev_torque_one(end,1) - prev_torque_one(end-1,1)) < 0.5) && abs(prev_torque_two(end,1) - prev_torque_two(end-1,1)) < 0.5
        exp = true;
    else
        exp = false;
    end

    explore = [explore; exp];

    options = optimoptions('fmincon',"EnableFeasibilityMode",true, "SubproblemAlgorithm","cg", 'MaxIterations',500000, "Display","iter");
    ref_torque = fmincon(@(x)Objective_function(x,ref_signal(i),gprMdlLP_machine1, gprMdlLP_machine2,exp), ...
        [prev_torque_one(end,1), prev_torque_two(end,1)],[],[],[],[],[0, 0],[38,38],@(x)Max_current_constraint(x,gprMdlLP_machine1, gprMdlLP_machine2), options);
    
    opt_references = [opt_references; sum(ref_torque)];

    prev_torque_one = [prev_torque_one; ref_torque(1)];
    prev_torque_two = [prev_torque_two; ref_torque(2)];

    real_current_one = Calc_current1(ref_torque(1));
    real_current_two = Calc_current2(ref_torque(2));

    prev_current_one = [prev_current_one; real_current_one];
    prev_current_two = [prev_current_two; real_current_two];

    [mean_machine1, sigma_machine1,interval_machine1] = predict(gprMdlLP_machine1,ref_torque(1)); 
    [mean_machine2, sigma_machine2,interval_machine2] = predict(gprMdlLP_machine2,ref_torque(2));

    predicted_one = [predicted_one;mean_machine1];
    predicted_two = [predicted_two;mean_machine2];
    
    if abs(prev_torque_one(end,1) - prev_torque_one(end-1,1)) > 0.5
        gprMdlLP_machine1 = fitrgp(prev_torque_one, prev_current_one);
    end

    if abs(prev_torque_two(end,1) - prev_torque_two(end-1,1)) > 0.5
        gprMdlLP_machine2 = fitrgp(prev_torque_two, prev_current_two);
    end
    
end
f = figure;
set(0,'DefaultLineLineWidth',2)
stairs([1:length(ref_signal)]', ref_signal,LineWidth=2);
hold
stairs([1:length(ref_signal)]', opt_references, "--", LineWidth=2)
stairs([1:length(ref_signal)]', prev_torque_one(3:end),LineWidth=2, Color="#bbffff")
stairs([1:length(ref_signal)]', prev_torque_two(3:end),LineWidth=2, Color="#ff00ff")
legend("Reference", "Optimization", "M1", "M2")

f2 = figure;
set(0,'DefaultLineLineWidth',2)
stairs([1:length(ref_signal)]', predicted_one+predicted_two, Color="#00ffff", LineWidth=2);
hold
stairs([1:length(ref_signal)]', prev_current_one(3:end)+prev_current_two(3:end), "--",LineWidth=2)
% stairs([1:length(ref_signal)]', prev_current_one(4:end),LineWidth=2)
% stairs([1:length(ref_signal)]', prev_current_two(4:end),LineWidth=2)
yline(ilimit,'--', Color="#0000ff",LineWidth=1)
legend("Predicted", "Real", "Max")

function ref_signal = Step_reference_generator()

    ref_signal = repelem(normrnd(20, 10, [20,1]),10, 1);
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
        z=5;
    else
        z=0;
    end
    
    value =  power(ref - sum(x),2) - z * (sigma_machine1(1) + sigma_machine2(1));
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
