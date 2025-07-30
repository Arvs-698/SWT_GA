% Genetic Algorithm to determine wind turbine design variables given Cp and wind speed

clc; clear; close all;

% === User Inputs ===
Cp_input = 0.30;         % Desired Coefficient of Power (<=0.593)
V_input = 2.08;             % Wind Speed (m/s)
rho = 1.225;             % Air density (kg/m^3)

% Lower and upper bounds for [Height, Diameter, OverlapRatio, TriBladeConfig, TSR, AspectRatio]
lb = [1.000, 0.500, 0.1, 0, 0.500, 1.0];
ub = [2.000, 2.000, 0.6, 1, 2.00, 5.0];

nvars = 6;

% Fitness function: minimize swept area (as a proxy for cost/size)
fitnessFcn = @(x) x(2)^2; % Minimize rotor diameter squared

% GA options
options = optimoptions('ga', ...
    'PopulationSize', 60, ...
    'MaxGenerations', 150, ...
    'Display', 'iter');

% Integer constraint for tri-blade configuration
IntCon = 4;

% Run GA
[x_opt, fval, exitflag, output] = ga(@(x)fitnessFcn(x), nvars, [], [], [], [], lb, ub, @(x)constraints(x, Cp_input, V_input, rho), IntCon, options);

% Display results
disp('Optimal design variables:');
disp(['Height (m): ', num2str(x_opt(1))]);
disp(['Diameter (m): ', num2str(x_opt(2))]);
disp(['Overlap Ratio: ', num2str(x_opt(3))]);
disp(['Tri-Blade Configuration (1=Yes, 0=No): ', num2str(round(x_opt(4)))]);
disp(['TSR: ', num2str(x_opt(5))]);
disp(['Aspect Ratio: ', num2str(x_opt(6))]);

%% Constraint function
function [c, ceq] = constraints(x, Cp_input, V_input, rho)
    % x: [Height, Diameter, OverlapRatio, TriBladeConfig, TSR, AspectRatio]
    Height = x(1);
    Diameter = x(2);
    Overlap = x(3);
    TriBlade = x(4);
    TSR = x(5);
    Aspect = x(6);

    % Swept Area
    A = pi * (Diameter/2)^2;
    
    % Model Cp (simple placeholder, modify as needed)
    Cp_model = 0.22*(116/TSR - 0.4*Overlap - 5)*exp(-12.5/TSR);
    Cp_model = Cp_model * (1 + 0.05*TriBlade) * (1 + 0.01*(Aspect - 1)); % Adjust for tri-blade and aspect
    Cp_model = max(0, Cp_model);
    
    % Constraint: Achieve at least the input Cp
    c1 = Cp_input - Cp_model; % Cp_model >= Cp_input

    % Constraint: Height/diameter matches Aspect Ratio
    c2 = Aspect - (Height/Diameter);
    
    % Constraint: Betz limit
    c3 = Cp_model - 0.593;
    
    % Combine all inequality constraints
    c = [c1; c2; c3];
    ceq = [];
end