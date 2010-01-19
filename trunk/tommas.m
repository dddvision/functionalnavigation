% Trajectory Optimization Manager for Multiple Algorithms and Sensors
classdef tommas < tommasConfig & handle
  
  properties (GetAccess=private,SetAccess=private)
    optimizer
  end
  
  methods (Access=public)
    
    function this=tommas
      fprintf('\n');
      fprintf('\ntommas::tommas');
      warning('on','all');
      intwarning('off');
      reset(RandStream.getDefaultStream);
      this.optimizer=unwrapComponent(this.optimizer);
      defineProblem(this.optimizer,this.dynamicModel,this.measures,this.dataURI);
    end
    
    function step(this)
      step(this.optimizer);
    end
    
    function [xEst,cEst]=getResults(this)
      [xEst,cEst]=getResults(this.optimizer);
    end    
  end
  
end
