clear; close all; clc;

% mesh sizing
t_end = 1000;
tspan = linspace(0, t_end, 200); % seconds
xmesh = linspace(0, 1, 200); % 10 micron thick particle

% Parameters
D1 = @(u) 1e-14; % [=] m^2/s, constant diffusivity
R = 5e-6;        % [=] m, particle radius (10 um diameter)
V = 4.235;       % [=] V, phi1, phi2 , overpotential relative to Uc
csmax = 51555;   % [=] mol/m^3, maximum concentration of Li+ in solid
celec = 1000;    % [=] mol/m^3, electrolyte concentration of Li+
T = 273+25;      % [=] K, room temperature

%% Sensitivity to V
Vs = [3.9:0.2:4.7];
f1 = figure; fig_set(); hold on;
f2 = figure; fig_set(); hold on;
for n = 1:length(Vs)
    sol = solve_cathode_particle(tspan,xmesh,D1,R,Vs(n),csmax,T,celec);
    xinNMC = trapz(xmesh, 3*(xmesh.^2).*sol, 2);
    [t, cr] = c_rate(tspan, xmesh, sol);
    figure(f1); plot(t, cr); ylabel('C-rate (hr^{-1})'); ylim([0 10])
    figure(f2); plot(tspan, xinNMC); ylabel('Volume integrated \eta');
end 
figure(f1); xlabel('time (s)'); legend('3.9 V', '4.1 V', '4.3 V', '4.5 V', '4.7 V')
figure(f2); xlabel('time (s)'); legend('3.9 V', '4.1 V', '4.3 V', '4.5 V', '4.7 V')

%% Sensitivity to D
Ds = [1e-13, 1e-14, 1e-15, 1e-16];
V = 4.235;
f3 = figure; fig_set(); hold on;
f4 = figure; fig_set(); hold on;
for n = 1:length(Ds)
    D = @(u) Ds(n);
    sol = solve_cathode_particle(tspan,xmesh,D,R,V,csmax,T,celec);
    xinNMC = trapz(xmesh, 3*(xmesh.^2).*sol, 2);
    [t, cr] = c_rate(tspan, xmesh, sol);
    figure(f3); plot(t, cr); ylabel('C-rate (hr^{-1})'); ylim([0 10])
    figure(f4); plot(tspan, xinNMC); ylabel('Volume integrated \eta');
end
figure(f3);  xlabel('time (s)'); legend('10^{-13} m^2/s', '10^{-14} m^2/s', '10^{-15} m^2/s', '10^{-16} m^2/s')
figure(f4);  xlabel('time (s)'); legend('10^{-13} m^2/s', '10^{-14} m^2/s', '10^{-15} m^2/s', '10^{-16} m^2/s')

%% Sensitivity to L
Ls = [.1,2,4,5,10]*1e-6;
V = 4.235;
f5 = figure; fig_set(); hold on;
f6 = figure; fig_set(); hold on;
for n = 1:length(Ls)
    sol = solve_cathode_particle(tspan,xmesh,D1,Ls(n),V,csmax,T,celec);
    xinNMC = trapz(xmesh, 3*(xmesh.^2).*sol, 2);
    [t, cr] = c_rate(tspan, xmesh, sol);
    figure(f5); plot(t, cr); ylabel('C-rate (hr^{-1})'); ylim([0 10])
    figure(f6); plot(tspan, xinNMC); ylabel('Volume integrated \eta');
end
figure(f5); xlabel('time (s)'); legend('0.1 \mum', '2 \mum', '4 \mum', '5 \mum', '10 \mum')
figure(f6); xlabel('time (s)'); legend('0.1 \mum', '2 \mum', '4 \mum', '5 \mum', '10 \mum')

%% D = f(u)
% ocv =   [3.84, 3.93, 4.03,  4.12, 4.17,  4.27,  4.36,  4.45]
u_est =   [0.5,  0.57, 0.656, 0.73, 0.77,  0.85,  0.93,  1   ];
Ds =      [1.31, 1.26, 1.12,  1.06, 0.616, 0.679, 0.828, 1.37]*1e-14;
D2 = @(u) interp1(u_est, Ds, u);
D_cell = {D1, D2};

f7 = figure; fig_set(); hold on;
f8 = figure; fig_set(); hold on;
for n = 1:length(D_cell)
    sol = solve_cathode_particle(tspan,xmesh,D_cell{n},R,V,csmax,T,celec);
    xinNMC = trapz(xmesh, 3*(xmesh.^2).*sol, 2);
    [t, cr] = c_rate(tspan, xmesh, sol);
    figure(f7); plot(t, cr); ylabel('C-rate (hr^{-1})'); ylim([0 10])
    figure(f8); plot(tspan, xinNMC); ylabel('Volume integrated \eta');
end
figure(f7); xlabel('time (s)'); legend('Static D = 1e-14', 'D = f(u)')
figure(f8); xlabel('time (s)'); legend('Static D = 1e-14', 'D = f(u)')

f9 = figure; fig_set()
s = surf(tspan,xmesh,sol'); s.EdgeColor = 'none'; view(2)
ylabel('\eta'); xlabel('times (s)')
colorbar

%% PDE solver wrapper
function sol = solve_cathode_particle(tspan,xmesh,D,L,V,csmax,T,celec)
    sol = pdepe(2,  @(x,t,u,dudx)concpde(x,t,u,dudx,D,L),...
                @icfun,...
                @(xl,ul,xr,ur,t)bcfun(xl,ul,xr,ur,t,D,L,V,csmax,T,celec),...
                xmesh, tspan); % 1D spherical model
end

%% PDE Functions
function [pl,ql,pr,qr] = bcfun(xl,ul,xr,ur,t,D,L,V,csmax,T,celec)
% boundary conditions
% xl    - lefthand boundary solution
% ul    - lefthand concentration solution

% 0(xl) ------ 1 (xr) dimensionless length (x/L)
% left  is particle center (symmetry required at x = 0)
% right is particle boundary w/ electrolyte

F = 96485;              % [=] C/mol e-, Faraday's constant

c_flux = j_flux(ur, V, csmax, T, celec)/F;  % [=] mol/(s * m^2), concentration flux

% symmetry condition
pl = 0; 
ql = 0;

% flux boundary condition
pr = c_flux*L/csmax/D(ur);
qr = 1;

end
function u0 = icfun(x)
% initial concentration of Li at all x
    u0 = 0.95;  % .95 is near fully discharged
end
function [c,f,s] = concpde(x,t,u,dudx,D,L)
% PDE formulated according to pdepe
% Inputs
%   x       - radial coordinate
%   t       - time
%   u       - concentration
%   dudx    - derivative  
%   D       - function handle for diffusivity
%   L       - radius of particle

c = L^2/D(u);
f = dudx;
s = 0;
end
function j = j_flux(ur, V, csmax, T, celec)
% Current flux expression for boundary of particle where redox event occurs
% Inputs
%   ur  - dimentionless Li conc solid-phase at interface
%   V   - overpoential relative to same reference as 
% csmax - maximum concentration of Li in solid
%   T   - temperature
% celec - electrolyte concentration of Li+
% Ouputs
%   j   - current density (A / m^2)

% constants (T,csmax)
F = 96485;          % [=] C/mol e-, Faraday's constant
R = 8.314;          % [=] J/mol/K, gas constant 

% convert inputs
cs1 = ur*csmax;     % [=] mol/m^3, convert dimensionless concentration back
n = (V - Uc(ur));  % [=] V, const overpotential at cathode surface

% kinetics paramters
a = 0.5;            % [=] - ,alpha, BV transfer coefficient
c2 = celec;          % [=] mol/m^3, intial (constant) conc of electrolyte Li
k = 2.252e-6;       % [=] [A/m^2 / (mol/m^3)^(3/2)] rate constant of rxn

% concentration dependent Butler-Volmer (BV) expression
i0 = k * ((csmax - cs1) * cs1 * c2)^a; % [=] A/m^2,  exchange i density
j = i0 * (exp(a*F*n/R/T) - exp(-a*F*n/R/T)); % [=] A/m^2, BV expression
end
function U = Uc(p)
% Cathode open circuit potential relative to reference
%Input
%   p - state of charge assumed to mean LixCO2, where x only ranges from 
%       [~0.5 - 1].

U = (-4.656 + 88.669.*(p.^2) - 401.119.*(p.^4) + 342.909.*(p.^6) - 462.471.*(p.^8) + 433.434.*(p.^10)) ...
    ./(-1 + 18.933.*(p.^2) - 79.532.*(p.^4) + 37.311.*(p.^6) - 73.083.*(p.^8) + 95.96.*(p.^10));

end

%% Unpacking
function [t, c] = c_rate(tspan, xmesh, sol)
ut = trapz(xmesh, 3*(xmesh.^2).*sol, 2); % integrate concentration in volume
ut = ut(:); tspan = tspan(:);
dudt = diff(ut)./diff(tspan);
t = (tspan(1:(end-1)) + tspan(2:end))/2;
c = abs(dudt)*3600/0.5;
end

%% Plotting functions
function fig_set()
f = gcf; f.Units = 'inches';
f.Position = [1 1 2.5 2]; f.Color = 'white';
ax = gca; ax.FontSize = 10;
end
