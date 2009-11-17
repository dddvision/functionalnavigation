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
  
    function [lonLatAlt,quaternion]=evaluate(this,t)
      assert(isa(t,'double'));
      t(t<this.a)=NaN;
      posquat=double(subs(this.bodyPath,'t',t));
      lonLatAlt=posquat(1:3,:);
      quaternion=posquat(4:7,:);
    end
  
    function [lonLatAltRate,quaternionRate]=derivative(this,t)
      if( isempty(this.bodyPathDiff) )
        this.bodyPathDiff=diff(this.bodyPath);
      end
      t(t<this.a)=NaN;
      assert(isa(t,'double'));
      posquatdot=double(eval(this.bodyPathDiff)); % depends on t
      lonLatAltRate=posquatdot(1:3,:);
      quaternionRate=posquatdot(4:7,:);
    end
  end
  
end
