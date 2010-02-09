% Trajectory Optimization Manager for Multiple Algorithms and Sensors
classdef tommas < tommasConfig & handle
  
  properties (GetAccess=private,SetAccess=private)
    dataContainerInstance
    optimizerInstance
  end
  
  methods (Access=public)
    
    function this=tommas
      fprintf('\n');
      fprintf('\ntommas::tommas');
      warning('on','all');
      warning('off','MATLAB:intMathOverflow'); % see performance remark in "doc intwarning"
      reset(RandStream.getDefaultStream);
      this.optimizerInstance=unwrapComponent(this.defaultOptimizer);
      defineProblem(this.optimizerInstance,this.defaultDynamicModel,this.defaultMeasures,this.defaultDataURI);
      
      this.dataContainerInstance=[];
      [scheme,resource]=strtok(this.defaultDataURI,':');
      if(strcmp(scheme,'matlab'))
        this.dataContainerInstance=eval(resource(2:end));
      end
    end
    
    function xRef=getReferenceTrajectory(this)
      xRef=getReferenceTrajectory(this.dataContainerInstance);
    end

    function flag=hasReferenceTrajectory(this)
      if(isempty(this.dataContainerInstance))
        flag=false;
      else
        flag=hasReferenceTrajectory(this.dataContainerInstance);
      end
    end
    
    function step(this)
      step(this.optimizerInstance);
    end
    
    function [xEst,cEst]=getResults(this)
      [xEst,cEst]=getResults(this.optimizerInstance);
    end    
  end
  
end
