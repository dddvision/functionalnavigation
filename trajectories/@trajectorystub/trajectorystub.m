classdef trajectorystub < trajectory
  properties
    pose
    parametersPerSecond
    staticParameters
    dynamicParameters
  end
  methods
    function this=trajectorystub
      fprintf('\n');
      fprintf('\n### trajectorystub constructor ###');
      this.parametersPerSecond=3;
      this.pose=[0;0;0;1;0;0;0];
      this.staticParameters=logical(rand(1,8)>0.5);
      this.dynamicParameters=logical(rand(1,30)>0.5);
    end
    
    function this=staticSet(this,bits)
      this.staticParameters=bits;
    end
 
    function bits=staticGet(this)
      bits=this.staticParameters;
    end
    
    function bits=dynamicGet(this,tmin,tmax)
      bits=this.dynamicParameters;
    end

    function this=dynamicSet(this,bits,tmin,tmax)
      this.dynamicParameters=bits;
    end
    
    function cost=priorCost(this,staticBits,dynamicBits,tmin,tmax)
      cost=0;
    end
     
    function [a,b]=domain(this)
      a=0;
      b=numel(this.dynamicParameters)/this.parametersPerSecond;
    end
   
    function posquat=evaluate(this,t)
      fprintf('\n');
      fprintf('\n### trajectorystub evaluate ###');
      
      fprintf('\nstaticParameters = ');
      fprintf('%d',this.staticParameters);
      fprintf('\ndynamicParameters = ');
      fprintf('%d',this.dynamicParameters);
      
      N=numel(t);
      posquat=repmat(this.pose,[1,N]);
      posquat(2,:)=t;
      [a,b]=domain(this);
      posquat(:,t<a|t>b)=NaN;
    end
    
    function posquatdot=derivative(this,t)
      N=numel(t);
      posquatdot=zeros(7,N);
      posquatdot(2,:)=1;
      [a,b]=domain(this);
      posquatdot(:,t<a|t>b)=NaN;
    end
  end  
end
