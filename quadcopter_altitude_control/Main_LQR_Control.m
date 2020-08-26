% EE-6310: Optimal Control and Estimation.
% Project: Vertical Position control of a Quad-copter using LQR Controller.
% Author: Desai Parth .M. (Electrical Engineering)
% Missouri University of Science and Technology.
% ----------------------------------------------------------------------
% READ ME:
% To check constant reference tracking, 
%    - Diable the reference signal for loop (line 37),
%    - Reduce simulation time to 10 seconds for better visibility.
%    - Change reference signal in the Tracker.m function file (line 21).    
%    - Change the simulation time to 10 seconds and the input type to 
%      step in the simulink model file.
% ----------------------------------------------------------------------
clear all;
close all;
clc;
%
% -------------- LINEAR QUADRATIC REGULATOR (LQR) ANALYSIS -------------
% X0 = [5 10 0 0 0 0]'; % Initial Conditions
% [t,x] = ode45(@Regulator,[0 10],X0); % ODE call for LQR control.
% % ------------------------------ PLOTS -------------------------------
% figure; subplot(2,1,1);
% plot(t,x(:,1)); grid on;
% legend('z'); title('Quad-copter Vertical Position Regulation');
% ylabel('Vertical Position State (z)'); xlabel('Time (secs)');
% %
% subplot(2,1,2);
% plot(t,x(:,2)); grid on;
% legend('w'); title('Quad-copter Vertical Velocity Regulation');
% ylabel('Vertical Velocity State (w)'); xlabel('Time (secs)');
%
% --------------- LINEAR QUADRATIC TRACKER (LQT) ANALYSIS --------------
X0 = [5 0 0 0 0 0]'; % Initial Conditions
[t,x] = ode45(@Tracker,[0 20],X0); % ODE call for LQT control.
% --- Run Simulink PID Controller Model for Position Tracking.
% sim('Vertical_System_Control'); % P Controller
sim('Vertical_System_Control_PID'); % PID Controller
% ------------------------------ PLOTS ---------------------------------
% --- Generate reference signal for plotting.
for i = 1:length(t)
    Ref_Track(i,1) = (3 + (0.5*sin((6.28/10)*t(i,1))));
end
figure;
plot(t,Ref_Track(:,1),'r'); hold on;
plot(t,x(:,1),'b'); hold on;
% plot(P_Ctrlr_Pos(:,1),P_Ctrlr_Pos(:,2),'b'); hold on;
plot(P_Ctrlr_Pos_PID(:,1),P_Ctrlr_Pos_PID(:,2),'m');
grid on;
legend('Ref. Track','LQR','PID'); 
title('Sine Tracking Reference: Quad-copter Vertical Position');
ylabel('Vertical Position State (z)'); xlabel('Time (secs)');
%
figure;
plot(t,x(:,2),'b'); hold on;
% plot(P_Ctrlr_Speed(:,1),P_Ctrlr_Speed(:,2),'b'); hold on;
plot(P_Ctrlr_Speed_PID(:,1),P_Ctrlr_Speed_PID(:,2),'m');
grid on;
legend('LQR','PID','location','SouthEast'); 
title('Sine Tracking Reference: Quad-copter Vertical Velocity');
ylabel('Vertical Velocity State (w)'); xlabel('Time (secs)');
%
% -------------------------------- END ---------------------------------
