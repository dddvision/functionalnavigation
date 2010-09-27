classdef MatlabGAConfig < handle
  properties (Constant=true,GetAccess=protected)
    popSize = 10; % (10) number of trajectories to use for optimization
    maxEdges = 10; % (10) maximum number of edges to compute for each measure
    
    % Genetic Algorithm parameters (see gaoptimset for details) 
    CrossoverFraction = 0.5;
    CreationFcn = @gacreationuniform;
    CreationFcnArgs = {};
    FitnessScalingFcn = @fitscalingprop;
    FitnessScalingFcnArgs = {};
    SelectionFcn = @selectionstochunif;
    SelectionFcnArgs = {};
    CrossoverFcn = @crossoversinglepoint;
    CrossoverFcnArgs = {};
    MutationFcn = @mutationuniform;
    MutationFcnArgs = {0.02};
    
    verbose = true; % (true) enable verbose errors and warnings
  end
end
