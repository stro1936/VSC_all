%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PMSG_B2B
% Date: 14/05/2021
% Authors: M. Cheah
% =========================================================================
close all; clear all; clc
format long;
% =========================================================================

%% General parameters

% AC grid: Thevenin equivalent
Sn1=5e6;             % Base power
Un1=690;              % Base AC voltage
f1=50;                  % Base frequency
SCR1=5;                 % Short-circuit ratio
Scc1=SCR1*Sn1;          % Short-circuit power
Xcc1=Un1^2/Scc1;        % Short-circuit impedance
Lcc1=Xcc1/(2*pi*f1);    % Shot-circuit inductance
Rcc1=Xcc1/100;          % Short-circuit resistance

% DC grid: ideal
Vdcref=1200;

% Other parameters
sat_current=1.1;        % Current saturation
epsilon=1;              % Used for the current saturation
magnitud_delay=1e-5;    % Constant delay for simulation    
plots_step=1e-4;        % Plot samples step 

%% 2L-VSC

Sn_n1=Sn1;                           % Base power
cosfi_n1=1;
f_n1=f1;
w_n1=2*pi*f_n1;
Un_n1=Un1;                          % Line-line voltage
Vpeak_n1=Un_n1/sqrt(3)*sqrt(2);     % Peak voltage
Xn_n1=Un_n1^2/Sn_n1;                % Base impedance
Ln_n1=Xn_n1/(2*pi*f_n1);            % Base inductance

Rg_n1=Rcc1;                         % Thevenin resistance
Lg_n1=Lcc1;                         % Thevenin inductance
Rc_n1=0.01*Xn_n1;                   % Converter grid coupling filter resistance (1% of Zb)
Lc_n1=0.1*Ln_n1;                    % Converter grid coupling filter inductance (max 10% of Zb to limit voltage droop of VSC)
Cac_n1=0.025*(1/(w_n1*Xn_n1));      % Converter grid coupling filter capacitance (max 5% of Cb, but usually 1/2 of that value)


vaini_n1=Vpeak_n1;                  % Three-phase system initial voltages
vbini_n1=-1/2*Vpeak_n1;
vcini_n1=-1/2*Vpeak_n1;

Vdcref_n1=Vdcref;                   % Base DC voltage
tau_C=0.04;                         % Time response of DC capacitor
Cdc=2*tau_C*Sn_n1/Vdcref_n1^2;      % DC capacitor


% PLL tuning
ts_pll_n1=0.025;
xi_pll_n1=0.707;
omega_pll_n1=4/(ts_pll_n1*xi_pll_n1);
kp_pll_n1=xi_pll_n1*2*omega_pll_n1/Vpeak_n1;
tau_pll_n1=2*xi_pll_n1/omega_pll_n1;
ki_pll_n1=kp_pll_n1/tau_pll_n1;

% Current control
taus=1e-3;
kp_s_n1=Lc_n1/taus;
ki_s_n1=Rc_n1/taus;

% Power loops
tauPQ=1e-2;                 % At least 10 times slower than current loop. However, with Cac limited to approx. 50 times.

kp_P_n1=taus/tauPQ;
kp_Q_n1=kp_P_n1;
ki_P_n1=1/tauPQ;
ki_Q_n1=ki_P_n1;

% DC voltage control
psi_Vdc=2;
wn_Vdc=10*2*pi; %100*2*pi
kp_dc=2*Cdc*psi_Vdc*wn_Vdc;
ki_dc=Cdc*wn_Vdc^2;



%% Parameters PMSG
wr=2*pi*f1;

fluxm=2.5;
p=2;%Parelles de pols
Rs=0.01;
Lqd=0.05/(2*pi*50);
Lq=Lqd;
Ld=Lqd;

%Control parameters
tau_m=5e-3;
kp_mq=Lq/tau_m;
kp_md=Ld/tau_m;
ki_m=Rs/tau_m;



%% Scenario configuration and linearisation:

Tsim=1.5;

t_step_P=0.75;
t_step_Q=0.5;


P_set=0.8*Sn_n1;
Q_set=0.2*Sn_n1;
P_step=0.1*Sn_n1;
Q_step=0.1*Sn_n1;

Te_ref_init = 1e6/(w_n1/p);
Te_ref_final = 5e6/(w_n1/p);
Q_mach_ref = 0.5e6;


%% Turbine Load Model
Pn = Sn1;
vwn = 14;
D = 88;
N = 80;
Jtot = 9e4;
c1 = 0.44;
c2 = 125;
c6 = 6.94;
c7 = 16.5;
c9 = -0.002;
A = pi*(D/2)^2;
rho = 1.225;
pitch = 0;
K1 = 20;
K2 = 1;
Kcp = (1/2)*rho*A*((D/2)^3)*(c1*((c2+c6*c7)^3)*exp((c2+c6*c7)/-c2))/((c2^2)*(c7^4));