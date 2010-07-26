classdef MatlabGAConfig < handle
  properties (Constant=true,GetAccess=protected)
    maxEdges=5; % maximum number of edges to compute for each measure
    
    % Genetic Algorithm parameters (see gaoptimset for details) 
    PopulationSize = 20;
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
  end
end
