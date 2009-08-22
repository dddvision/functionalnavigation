classdef sensorstub < sensor
  properties (GetAccess=private,SetAccess=private)
    intrinsicStatic
    intrinsicDynamic
  end  
  methods
    function this=sensorstub
      fprintf('\n');
      fprintf('\n### sensorstub constructor ###');
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
      
    function c=evaluate(this,x,tmin,tmax)
      fprintf('\n');
      fprintf('\n### sensorstub evaluate ###');
      
      fprintf('\nintrinsicStatic = ');
      fprintf('%d',this.intrinsicStatic);
      fprintf('\nintrinsicDynamic = ');
      fprintf('%d',this.intrinsicDynamic);
      
      K=numel(x);
      fprintf('\nnumber of trajectories = %d',K);
      
      fprintf('\ntime domain lower bound = %f',tmin);
      fprintf('\ntime domain upper bound = %f',tmax);

      c=zeros(1,K);
      for k=1:K
        fprintf('\n');
        fprintf('\nprocessing trajectory %d',k);
        c(k)=0.5;
        fprintf('\ncost = %f',c(k));
      end
    end
    
  end
end
