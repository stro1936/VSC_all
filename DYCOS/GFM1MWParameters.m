% DYCOS project

close all
clear
clc

% Inverter parameters
Vdc = 1300;           % DC link voltage        
fsw = 5e3;            % Switching frequency [Hz]
Pnom = 0.92e6;        % Active power [W]
Qnom = 0.485e6;       % Reactive power [W]

% Grid parameters
Vbase = 690;          % Voltage line to line [RMS]
fbase = 50;           % Nominal frequency [Hz]
w = 2*pi*fbase;       % Angular frequency [rad*s]
XtoR = 6.6;
SCR = 10;
Zth = (Vbase*Vbase)/(SCR*Pnom);   % Thevenin impedance
Rth = Zth/sqrt(XtoR*XtoR+1);      % Thevenin resistance
Xth = Rth*XtoR;                   % Thevenin reactance
Lth = Xth/(2*pi*fbase);           % Thevenin inductance

% Filter parameters
Lf1 = 6.8943e-04;     % Filter inductance inverter [H]
Lf2 = 9.8835e-05;     % Filter inductance grid [H]
Cf = 6.1509e-05;      % Filter capacitance [F]
Rfc = 0.3450;         % Damping resistance [ohm]
Rf = 0.01;            % Resistance's inductance [ohm]

% Current control loop parameters
Ti = 0.2e-3;          % Fast current control loop [s]                
Kpcc = (Lf1+Lf2)/Ti;  % Proportional current control Kp        
Kicc = Rf/Ti;         % Integral current control KI  
Kffv = 0.9;           % Feedforward current control 

% Voltage control loop parameters
PhM = 30;                                           % Phase margin [°]
z = (1-sin(PhM*pi/180))/(Ti*(1+sin(PhM*pi/180)));   
k = Cf*sqrt(z*(Ti^(-1)));                           
Wm = sqrt(z*(Ti^(-1)));                             

Kpvc = k;             % Proportional voltage control Kp
Kivc = k*z;           % Integral voltage control KI 
Kffi = 0.9;           % Feedforward voltage control 

% Grid-forming dispatch
Pref = 0.5e6;                  % Active power [W]
Qref = 0.1e6;                  % Reactive power [W]
Vref = Vbase*sqrt(2)/sqrt(3);  % Voltage line-neutral [peak]

% Pref/Qref increment/decrement
Tactivepowerstep = 1.0;        % Time where the change is applied
Ppowerstep = 0e6;              % Increment active power in MW

Treactivepowerstep = 1.0;      % Time where the change is applied
Qpowerstep = 0e6;              % Increment reactive power in MVAr

% Droop control
df = 1;                        % Maximum allowable frequency deviation [Hz]
dV = 0.1;                      % Maximum allowable voltage deviation [p.u.]
Mp = (2*pi*df)/(2*Pnom);       % Active droop control constant [rad/W.s]
Nq = (Vref*dV*2)/(2*Qnom);     % Reactive droop control constant [V/Var]
Kiq = 0.007;                   % Closed-loop reactive power                

% Virtual Impedance
Rvir = 0.0293;                 % Virtual resistance [ohm]
Xvir = 0.0384;                 % Virtual reactance [ohm]

% Isolated case - load parameters
Pload = 0.92e6;                % Active power [W]
Qload = 0.0e6;                 % Reactive power [W]