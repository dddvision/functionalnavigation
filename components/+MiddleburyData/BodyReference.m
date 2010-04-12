classdef BodyReference < MiddleburyData.MiddleburyDataConfig & Trajectory
  
  properties (SetAccess=private,GetAccess=private)
    bodyPath
    bodyPathDiff
    a
    b
  end  
  
  methods (Access=public)
    function this=BodyReference
      this.bodyPath='[0*t;t;0*t;1+0*t;0*t;0*t;0*t]';
      this.bodyPathDiff='[0*t;1+0*t;0*t;0*t;0*t;0*t;0*t]';
      this.a=0;
      this.b=(this.numImages-1)/this.fps;
    end

    function [a,b]=domain(this)
      a=this.a;
      b=this.b;
    end

    function [pose,poseRate]=evaluate(this,t)
      t((t<this.a)|(t>this.b))=NaN;
      assert(isa(t,'double'));
      posquat=double(eval(this.bodyPath)); % depends on t
      pose=struct('p',posquat(1:3,:),'q',posquat(4:7,:));
      if(nargout>1)
        posquatdot=double(eval(this.bodyPathDiff)); % depends on t
        poseRate=struct('r',posquatdot(1:3,:),'s',posquatdot(4:7,:));
      end
    end
  end
  
end
