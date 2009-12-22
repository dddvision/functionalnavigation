classdef bodyReference < trajectory
  
  properties (SetAccess=private,GetAccess=private)
    bodyPath
    bodyPathDiff
    a
    b
  end  
  
  methods (Access=public)
    function this=bodyReference
      this.bodyPath='[0*t;0.1*t;0*t;1+0*t;0*t;0*t;0*t]';
      this.bodyPathDiff='[0*t;0.1+0*t;0*t;0*t;0*t;0*t;0*t]';
      this.a=0;
      this.b=60;
    end

    function [a,b]=domain(this)
      a=this.a;
      b=this.b;
    end

    function [position,rotation,positionRate,rotationRate]=evaluate(this,t)
      t((t<this.a)|(t>this.b))=NaN;
      assert(isa(t,'double'));
      posquat=double(eval(this.bodyPath)); % depends on t
      posquatdot=double(eval(this.bodyPathDiff)); % depends on t
      position=posquat(1:3,:);
      rotation=posquat(4:7,:);
      positionRate=posquatdot(1:3,:);
      rotationRate=posquatdot(4:7,:);
    end
  end
  
end
