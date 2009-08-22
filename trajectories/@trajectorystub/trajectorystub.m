classdef trajectorystub < trajectory
  properties
    pose
    parametersPerSecond
    intrinsicStatic
    intrinsicDynamic
  end
  methods
    function this=trajectorystub
      fprintf('\n');
      fprintf('\n### trajectorystub constructor ###');
      this.parametersPerSecond=3;
      this.pose=[0;0;0;1;0;0;0];
      this.intrinsicStatic=logical(rand(1,8)>0.5);
      this.intrinsicDynamic=logical(rand(1,30)>0.5);
    end
    
    function this=setStaticSeed(this,newStaticSeed)
      this.intrinsicStatic=newStaticSeed;
    end
 
    function staticSeed=getStaticSeed(this)
      staticSeed=this.intrinsicStatic;
    end
    
    function subSeed=getDynamicSubSeed(this,tmin,tmax)
      subSeed=this.intrinsicDynamic;
    end

    function this=setDynamicSubSeed(this,newSubSeed,tmin,tmax)
      this.intrinsicDynamic=newSubSeed;
    end
     
    function [a,b]=domain(this)
      a=0;
      b=numel(this.intrinsicDynamic)/this.parametersPerSecond;
    end
   
    function posquat=evaluate(this,t)
      fprintf('\n');
      fprintf('\n### trajectorystub evaluate ###');
      
      fprintf('\nintrinsicStatic = ');
      fprintf('%d',this.intrinsicStatic);
      fprintf('\nintrinsicDynamic = ');
      fprintf('%d',this.intrinsicDynamic);
      
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
