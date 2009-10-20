classdef bodyReference < trajectory
  
  properties (SetAccess=private,GetAccess=private)
    bodyPath
    bodyPathDiff
    a
  end  
  
  methods (Access=public)
    function this=bodyReference(localCache)
      S=load(fullfile(localCache,'workspace.mat'),'BodyPath');
      if(isfield(S,'BodyPath'))
        this.bodyPath=S.BodyPath([5,6,7,1,2,3,4],:);
      else
        this.bodyPath='[0*t;0*t;0*t;1+0*t;0*t;0*t;0*t]';
      end
      this.a=0;
    end
  
    function a=domain(this)
      a=this.a;
    end
  
    function posquat=evaluate(this,t)
      assert(isa(t,'double'));
      t(t<this.a)=NaN;
      posquat=double(subs(this.bodyPath,'t',t));
    end
  
    function posquatdot=derivative(this,t)
      assert(isa(t,'double'));
      if( isempty(this.bodyPathDiff) )
        this.bodyPathDiff=diff(this.bodyPath);
      end
      t(t<this.a)=NaN;
      posquatdot=double(eval(this.bodyPathDiff)); % depends on t
    end
  end
  
end
