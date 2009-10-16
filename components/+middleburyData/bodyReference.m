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

    function posquat=evaluate(this,t)
      assert(isa(t,'double'));
      t(t<this.a)=NaN;
      posquat=double(eval(this.bodyPath)); % depends on t
    end

    function posquatdot=derivative(this,t)
      assert(isa(t,'double'));
      t(t<this.a)=NaN;
      posquatdot=double(eval(this.bodyPathDiff)); % depends on t
    end
  end
  
end
