% Trajectory Optimization Manager for Multiple Algorithms and Sensors
classdef tommas < tommasConfig & handle
  
  properties (GetAccess=private,SetAccess=private)
    M
  end
  
  methods (Access=public)
    
    function this=tommas
      fprintf('\n');
      fprintf('\ntommas::tommas');
      warning('on','all');
      intwarning('off');
      reset(RandStream.getDefaultStream);
      this.M=unwrapComponent(this.optimizer);
      defineProblem(this.M,this.dynamicModel,this.measures,this.dataURI);
    end
    
    function step(this)
      step(this.M);
    end
    
    function [xEst,cEst]=getResults(this)
      [xEst,cEst]=getResults(this.M);
    end    
  end
  
end
