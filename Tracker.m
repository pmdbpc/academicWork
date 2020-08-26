function xdot = Tracker(t,x)
% ------------ LINEAR QUADRATIC REGULATOR of a QUAD_COPTER SYSTEM ------
    % --- System Dynamics.
    A = [  0.0000  1.0000  0.0000  0.0000  0.0000  0.0000; 
           0.0000  0.0000 -0.0106  0.0106 -0.0106  0.0106;
           0.0000  0.0000 -10.000  0.0000  0.0000  0.0000;
           0.0000  0.0000  0.0000 -10.000  0.0000  0.0000;
           0.0000  0.0000  0.0000  0.0000 -10.000  0.0000;
           0.0000  0.0000  0.0000  0.0000  0.0000 -10.000];
    B = [0 0 1 -1 1 -1]';
    C = [0 1 0 0 0 0];
    % --- Intermediate State & Control Input Weighting for LQR Analysis.
    Q = [  10000000 0 0 0 0 0;
                  0 1 0 0 0 0;
                  0 0 1 0 0 0;
                  0 0 0 1 0 0;
                  0 0 0 0 1 0;
                  0 0 0 0 0 1];
    R = 1;
    % --- Calculate the controller gain.
    [k,S,e] = lqr(A,B,Q,R);
    K = -(R^-1)*B'*S;
	% --- Position Tracking Setting.
    % --- Constant Reference tracking.
    % ref = -1;
    % --- Sine Reference tracking. (Sine Wave Specifications: Bias = 3,
    % --- Amplitude = 1, Frequency = 0.628 rad/sec)
    ref = -(3 + (0.5*sin((6.28/10)*t)));
    % --- Defining tracking reference for the position state of the system.
    x(1,:) = (x(1,:) + ref);
    % --- Determine Closed loop control input (u = -Kx)
    ctrl_in(1,:) = K*(x(:,:));
    % --- Calculate new state values.    
    xdot(1,:) = x(2);
    xdot(2,:) = 0.0106*(-x(3)+x(4)-x(5)+x(6));
    xdot(3,:) = (-10*x(3))+(7*ctrl_in);
    xdot(4,:) = (-10*x(4))-(7*ctrl_in);
    xdot(5,:) = (-10*x(5))+(7*ctrl_in);
    xdot(6,:) = (-10*x(6))-(7*ctrl_in);
end