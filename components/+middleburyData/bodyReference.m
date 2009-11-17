classdef bodyReference < trajectory
  
  properties (SetAccess=private,GetAccess=private)
    bodyPath
    bodyPathDiff
    a
  end  
  
  methods (Access=public)
    function this=bodyReference
      this.bodyPath='[0*t;0.1*t;0*t;1+0*t;0*t;0*t;0*t]';
      this.bodyPathDiff='[0*t;0.1+0*t;0*t;0*t;0*t;0*t;0*t]';
      this.a=0;
    end

    function a=domain(this)
      a=this.a;
    end

    function [lonLatAlt,quaternion]=evaluate(this,t)
      t(t<this.a)=NaN;
      assert(isa(t,'double'));
      posquat=double(eval(this.bodyPath)); % depends on t
      lonLatAlt=posquat(1:3,:);
      quaternion=posquat(4:7,:);
    end

    function [lonLatAltRate,quaternionRate]=derivative(this,t)
      t(t<this.a)=NaN;
      assert(isa(t,'double'));
      posquatdot=double(eval(this.bodyPathDiff)); % depends on t
      lonLatAltRate=posquatdot(1:3,:);
      quaternionRate=posquatdot(4:7,:);
    end
  end
  
end
