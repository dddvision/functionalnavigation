% Trajectory Optimization Manager for Multiple Algorithms and Sensors
classdef tommas < tommasConfig & handle
  
  properties (GetAccess=private,SetAccess=private)
    optimizerInstance
  end
  
  methods (Access=public)
    
    function this=tommas
      fprintf('\n');
      fprintf('\ntommas::tommas');
      warning('on','all');
      warning('off','MATLAB:intMathOverflow'); % see performance remark in "doc intwarning"
      reset(RandStream.getDefaultStream);
      this.optimizerInstance=unwrapComponent(this.optimizer);
      defineProblem(this.optimizerInstance,this.dynamicModel,this.measures,this.dataURI);
    end
    
    function step(this)
      step(this.optimizerInstance);
    end
    
    function [xEst,cEst]=getResults(this)
      [xEst,cEst]=getResults(this.optimizerInstance);
    end    
  end
  
end
