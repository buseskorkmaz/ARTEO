
% Figure 9

% set(0,'DefaultLineLineWidth',2)
% subplot(2,2,[1,2]);
% yyaxis left
% plot(z1000.GP_signals_output.time, z1000.GP_signals_output.signals(1).values, Color="k")
% hold
% plot(z1000.GP_signals_output.time, z1000.GP_signals_output.signals(2).values)
% plot(z10000.GP_signals_output.time, z10000.GP_signals_output.signals(2).values, Color="#f08080")
% ylabel("Target Load [kW]")
% ylim([0 2500])
% yyaxis right
% plot(z1000.GP_signals_output.time, z1000.GP_signals_output.signals(3).values)
% plot(z10000.GP_signals_output.time, z10000.GP_signals_output.signals(3).values)
% % xlabel("Time [ms]")
% xlim([0 3000])
% ylim([0 500])
% legend("Target cooling load", "Achieved cooling load (z = 1000)", "Achieved cooling load (z = 10000)", "Small compressor load (z = 1000)", "Small compressor load (z = 10000)", Location="best")
% subplot(2,2,[3, 4]);
% yyaxis left
% plot(z1000.GP_signals_output.time, z1000.GP_signals_output.signals(13).values, Color="#ff00ff")
% hold
% plot(z10000.GP_signals_output.time, z10000.GP_signals_output.signals(13).values, Color="#653a92")
% yline(1580,'--', Color="#0000ff",LineWidth=1)
% ylabel("Power Consumption [kW]")
% ylim([0 1700])
% yyaxis right
% plot(z1000.GP_signals_output.time, z1000.GP_signals_output.signals(8).values, Color="#3a6792")
% plot(z10000.GP_signals_output.time, z10000.GP_signals_output.signals(8).values, Color="#92653a")
% xlabel("Time [ms]")
% xlim([0 3000])
% ylim([0 200])
% legend('Total power consumption (z = 1000)', 'Total power consumption (z = 10000)', 'Maximum power threshold', 'Small compressor power consumption (z = 1000)', "Small compressor power consumption (z = 10000)", Location="best")
% saveas(gcf,'different_z_comparison_cons.png')

% Figure 6

set(0,'DefaultLineLineWidth',2)
subplot(2,2,[1,2]);
% plot(time,new_target_load)
% hold
% 
% plot(time,achieved_total_load)
% plot(time,consumed_total_power)
% xlim([0 42000])
% xlabel("Time")
% legend('Target load', 'Achieved total load','Consumed total power', 'Achieved load machine1', ...
%      'Achieved load machine2', 'Achieved load machine3', 'Achieved load machine4', 'Achieved load machine5')

plot(z1000.GP_signals_output.time, z1000.GP_signals_output.signals(1).values, Color="k")
hold
plot(z1000.GP_signals_output.time, z1000.GP_signals_output.signals(2).values, Color="#f08080")
plot(optimization.optimization.time, optimization.optimization.signals(2).values, Color="#ffdab9")
% xlabel("Time [ms]")
ylabel("Target Load [kW]")
ylim([0 4500])
xlim([0 42000])
legend("Target cooling load", "Achieved cooling load (ARTEO)","Achieved cooling load (full knowledge)")

subplot(2,2,[3, 4]);
plot(z1000.GP_signals_output.time, z1000.GP_signals_output.signals(13).values, Color="#ff00ff")
hold
plot(optimization.optimization.time, optimization.optimization.signals(13).values, Color="#708090")
yline(1580,'--', Color="#0000ff",LineWidth=1)
xlabel("Time [ms]")
ylabel("Power Consumption [kW]")
ylim([0 3000])
xlim([0 42000])
legend('Total power consumption (ARTEO)','Total power consumption (full knowledge)', 'Maximum power threshold')
% saveas(gcf,'opt_comparison.png')

% Figure 5, 6

% set(0,'DefaultLineLineWidth',2)
% subplot(2,2,[1,2]);
% plot(time,new_target_load)
% hold
% 
% plot(time,achieved_total_load)
% plot(time,consumed_total_power)
% xlim([0 42000])
% xlabel("Time")
% legend('Target load', 'Achieved total load','Consumed total power', 'Achieved load machine1', ...
%      'Achieved load machine2', 'Achieved load machine3', 'Achieved load machine4', 'Achieved load machine5')

% replicate full simulation figures 

% plot(out.GP_signals_output.time, out.GP_signals_output.signals(1).values, Color="k")
% hold
% plot(time, gp_achieved_total_load(4:end), Color="#f08080")
% % plot(time, opt_achieved_total_load(4:end), Color="#ffdab9")
% % xlabel("Time [ms]")
% ylabel("Target Load [kW]")
% ylim([0 4500])
% xlim([0 42000])
% legend("Target cooling load", "Achieved cooling load")
% 
% subplot(2,2,[3, 4]);
% plot(time, gp_power_consumption(4:end), Color="#ff00ff")
% hold
% % plot(time, opt_power_consumption(4:end), Color="#708090")
% yline(1580,'--', Color="#0000ff",LineWidth=1)
% xlabel("Time [ms]")
% ylabel("Power Consumption [kW]")
% ylim([0 3000])
% xlim([0 42000])
% legend('Total power consumption', 'Maximum power threshold')
% saveas(gcf,'full_simulation_load_power.png')

% new figure
% figure;
% set(0,'DefaultLineLineWidth',2)
% subplot(5,1,1);
% plot(out.GP_signals_output.time, out.GP_signals_output.signals(2).values, Color="k")
% ylim([0 3200])
% % legend("Target cooling load", Location="best")
% ylabel("Target Load [kW]")
% subplot(5,1,2:3);
% plot(out.GP_signals_output.time, out.GP_signals_output.signals(2).values, Color="#ff00ff")
% hold
% % plot(out.GP_signals_output.time, out.GP_signals_output.signals(2).values)
% ylabel("Achieved Load [kW]")
% plot(out.GP_signals_output.time, out.no_exp_GP_signals_output.signals(2).values)
% plot(out.GP_signals_output.time, out.no_unc_GP_signals_output.signals(2).values)
% plot(out.GP_signals_output.time, out.pure_exp_GP_signals_output.signals(2).values)
% % xlabel("Time [ms]")
% xlim([0 8000])
% ylim([1500 2600])
% legend("Conditionally exploration+uncertainty", "No exploration","No uncertainty","Always exploration+uncertainty", Location="best")
% subplot(5,1,4:5);
% plot(out.GP_signals_output.time, out.GP_signals_output.signals(13).values, Color="#ff00ff")
% hold
% yline(1580,'--', Color="#0000ff",LineWidth=1)
% % plot(out.GP_signals_output.time, out.GP_signals_output.signals(13).values, Color="#ff00ff")
% ylabel("Power Consumption [kW]")
% ylim([1050 1800])
% plot(out.GP_signals_output.time, out.no_exp_GP_signals_output.signals(13).values)
% plot(out.GP_signals_output.time, out.no_unc_GP_signals_output.signals(13).values)
% plot(out.GP_signals_output.time, out.pure_exp_GP_signals_output.signals(13).values)
% xlabel("Time [ms]")
% xlim([0 8000])
% legend("Conditionally exploration+uncertainty", 'Maximum power threshold', "No exploration","No uncertainty","Always exploration+uncertainty", Location="best")
% 
% % box1
% annot_box = axes();
% annot_box.Position = [0.35 0.55 0.25 0.1]; % xlocation, ylocation, xsize, ysize
% plot(annot_box,out.GP_signals_output.time(1280:2530), out.pure_exp_GP_signals_output.signals(2).values(1280:2530), Color="[0.4940, 0.1840, 0.5560]	"); axis tight
% % plot(out.GP_signals_output.time(1280:2530), out.no_unc_GP_signals_output.signals(2).values(1280:2530), Color="[0.9290, 0.6940, 0.1250]");
% % hold
% % plot(out.GP_signals_output.time(1280:2530), out.no_exp_GP_signals_output.signals(2).values(1280:2530), Color="r");
% % plot(annot_box,out.GP_signals_output.time(1280:2530), out.pure_exp_GP_signals_output.signals(2).values(1280:2530), Color="[0.4940, 0.1840, 0.5560]	"); axis tight
% annotation('ellipse',[.33 .675 .29 .04], Color="#66B2FF")
% annotation('line',[.335 .35],[.69 .65], Color="#66B2FF")
% annotation('line',[.615 .6],[.69 .65], Color="#66B2FF")
% 
% % box2
% annot_box2 = axes();
% yyaxis right;
% annot_box2.YAxis(1).TickLabels = [];
% annot_box2.YAxis(2).Color = "k";
% annot_box2.Position = [0.15 0.15 0.1 0.1]; % xlocation, ylocation, xsize, ysize
% plot(out.GP_signals_output.time(270:740), out.no_unc_GP_signals_output.signals(13).values(270:740), Color="[0.9290, 0.6940, 0.1250]", LineStyle="-");
% hold
% plot(out.GP_signals_output.time(270:740), out.pure_exp_GP_signals_output.signals(13).values(270:740), Color="[0.4940, 0.1840, 0.5560]",LineStyle="-");
% plot(out.GP_signals_output.time(270:740), out.no_exp_GP_signals_output.signals(13).values(270:740), Color="r",LineStyle="-");
% yline(1580,'--', Color="#0000ff",LineWidth=2)
% annotation('ellipse',[.14 .3 .09 .04], Color="#66B2FF")
% annotation('line',[.143 .15],[.315 .25], Color="#66B2FF")
% annotation('line',[.23 .245],[.315 .25], Color="#66B2FF")
% % legend(annot_box2, "no exp", "no unc")
% % ylim([0 200])
% 
% % box3
% annot_box3 = axes();
% yyaxis right;
% annot_box3.YAxis(1).TickLabels = [];
% annot_box3.YAxis(2).Color = "k";
% annot_box3.Position = [0.7 0.15 0.1 0.1]; % xlocation, ylocation, xsize, ysize
% plot(annot_box3,out.GP_signals_output.time(3050:3500), out.pure_exp_GP_signals_output.signals(13).values(3050:3500), Color="[0.4940, 0.1840, 0.5560]", LineStyle="-"); axis tight;
% hold
% % plot(out.GP_signals_output.time(3050:3500), out.no_unc_GP_signals_output.signals(13).values(3050:3500), Color="[0.9290, 0.6940, 0.1250]",LineStyle="-");
% plot(out.GP_signals_output.time(3050:3500), out.no_exp_GP_signals_output.signals(13).values(3050:3500), Color="r",LineStyle="-");
% annotation('ellipse',[.72 .27 .09 .04], Color="#66B2FF")
% annotation('line',[.723 .70],[.3 .25],Color="#66B2FF")
% annotation('line',[.81 .8],[.3 .25],Color="#66B2FF")

% saveas(gcf,'different_z_comparison_cons_annot.png')

% total uncertainty 
% figure;
% set(0,'DefaultLineLineWidth',2)

% subplot(4,2,[1,4]);
% yyaxis left
% plot(z1000.GP_signals_output.time, z1000.GP_signals_output.signals(1).values, Color="k")
% hold
% plot(z1000.GP_signals_output.time, z1000.GP_signals_output.signals(2).values)
% plot(z10000.GP_signals_output.time, z10000.GP_signals_output.signals(2).values, Color="#f08080")
% ylabel("Target Load [kW]")
% ylim([0 2500])
% yyaxis right
% plot(z1000.GP_signals_output.time, z1000.GP_signals_output.signals(3).values)
% plot(z10000.GP_signals_output.time, z10000.GP_signals_output.signals(3).values)
% % xlabel("Time [ms]")
% xlim([0 8000])
% ylim([0 500])
% legend("Target cooling load", "Achieved cooling load (z = 1000)", "Achieved cooling load (z = 10000)", "Small compressor load (z = 1000)", "Small compressor load (z = 10000)", Location="best")
% 
% subplot(4,2, [5,8]);
% x = [0:length(z1000_uncertainty)-1];
% stairs(250*x, log(z500_uncertainty), "LineWidth",2);
% hold
% % plot(250*x, z500_uncertainty);
% stairs(250*x, log(z1000_uncertainty), "LineWidth",2);
% stairs(250*x, log(z10000_uncertainty), "LineWidth",2);
% % semilogy(250*x, log(z100000_uncertainty));
% % semilogy(250*x, log(z500000_uncertainty));
% % semilogy(250*x, log(minus_uncertainty));
% % semilogy(250*x, log(z10000_uncertainty));
% % semilogy(250*x, log(z50000_uncertainty));
% % plot(250*x, log(z50000_uncertainty));
% xlim([0 8000])
% ylim([7.8 10])
% ylabel("Total uncertainty (log)")
% xlabel("Time [ms]")
% legend("z = 500","z = 1000", "z = 10000")
% saveas(gcf,'uncertainty_comparison.png')
% 
% 
