classdef matlabGA1
  
  properties (GetAccess=private,SetAccess=private)
    objective
    parameters
    cost
    defaultOptions;
    stepGAhandle;
  end
  
  methods (Access=public)
    function this=matlabGA1
      fprintf('\n');
      fprintf('\nmatlabGA1::matlabGA1');
      if( ~license('test','gads_toolbox') )
        error('Matlab GADS toolbox is unavailable');
      end
            
      this.defaultOptions = gaoptimset;
      this.defaultOptions.PopulationType = 'bitstring';
      this.defaultOptions.PopInitRange = [0;1];
      this.defaultOptions.CrossoverFraction = 0.6;
      this.defaultOptions.MigrationDirection = 'forward';
      this.defaultOptions.MigrationInterval = inf;
      this.defaultOptions.MigrationFraction = 0.4;
      this.defaultOptions.Generations = 1;
      this.defaultOptions.TimeLimit = inf;
      this.defaultOptions.FitnessLimit = -inf;
      this.defaultOptions.StallGenLimit = inf;
      this.defaultOptions.StallTimeLimit = inf;
      this.defaultOptions.TolFun = 0;
      this.defaultOptions.TolCon = 0;
      this.defaultOptions.InitialPenalty = 10;
      this.defaultOptions.PenaltyFactor = 100;
      this.defaultOptions.CreationFcn = @gacreationuniform;
      this.defaultOptions.CreationFcnArgs = {};
      this.defaultOptions.FitnessScalingFcn = @fitscalingrank;
      this.defaultOptions.FitnessScalingFcnArgs = {};
      this.defaultOptions.SelectionFcn = @selectionroulette;
      this.defaultOptions.SelectionFcnArgs = {};
      this.defaultOptions.CrossoverFcn = @crossovertwopoint;
      this.defaultOptions.CrossoverFcnArgs = {};
      this.defaultOptions.MutationFcn = @mutationuniform;
      this.defaultOptions.MutationFcnArgs = {0.02};
      this.defaultOptions.Vectorized = 'on';
      this.defaultOptions.LinearConstr.type = 'unconstrained';
      
      % workaround to access stepGA from the gads toolbox
      pathtemp=pwd;
      toolboxpath=fileparts(which('ga'));
      cd(fullfile(toolboxpath,'private'));
      this.stepGAhandle=@stepGA;
      cd(pathtemp);
    end
  end
  
end
