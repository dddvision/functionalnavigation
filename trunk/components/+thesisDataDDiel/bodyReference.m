classdef bodyReference < trajectory
  
  properties (SetAccess=private,GetAccess=private)
    bodyPath
    bodyPathDiff
    a
    b
  end  
  
  methods (Access=public)
    function this=bodyReference(localCache)
      S=load(fullfile(localCache,'workspace.mat'),'BodyPath','START_TIME','STOP_TIME');
      this.bodyPath=S.BodyPath([5,6,7,1,2,3,4],:);
      this.bodyPathDiff=diff(this.bodyPath);
      this.a=S.START_TIME;
      this.b=S.STOP_TIME;
    end
  
    function [a,b]=domain(this)
      a=this.a;
      b=this.b;
    end
  
    function [ecef,quaternion,ecefRate,quaternionRate]=evaluate(this,t)
      t((t<this.a)|(t>this.b))=NaN;
      assert(isa(t,'double'));
      posquat=double(eval(this.bodyPath)); % depends on t
      posquatdot=double(eval(this.bodyPathDiff)); % depends on t
      ecef=posquat(1:3,:);
      quaternion=posquat(4:7,:);
      ecefRate=posquatdot(1:3,:);
      quaternionRate=posquatdot(4:7,:);
    end
  end
  
end
