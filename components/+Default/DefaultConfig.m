classdef DefaultConfig < handle
  properties (Constant=true)
    % dynamic model parameters
    positionOffset = -1.2; % (-1.2) simulated offset in first position coordinate
    positionRateOffset = 0.2; % (0.2) simulated offset in first position rate coordinate
    positionDeviation = 2; % (2) standard deviation of initial position distribution
    positionRateDeviation = 0.1; % (1) standard deviation of initial position rate distribution
    
    % measure parameters
    dt = 0.01; % (0.01) fixed time step
    deviation = 0.01; % (0.01) standard deviation of measurement distribution
    
    % optimizer parameters
    popSize = 1; % (1) number of trajectories to optimize over
    
    % diagnostic parameters
    verbose = true; % (true) print messages to stdandard output
  end
end
