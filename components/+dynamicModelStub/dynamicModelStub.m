% This class represents a dynamic model of a fictitious system
classdef dynamicModelStub < dynamicModel
  
  properties (GetAccess=private,SetAccess=private)
    a
    lonLatAlt
    quaternion
    parametersPerSecond
    dynamicParameters
  end
  
  methods (Access=public)
    function this=dynamicModelStub
      fprintf('\n');
      fprintf('\ndynamicModelStub::dynamicModelStub');
      this.a=0;
      this.parametersPerSecond=15;
      this.lonLatAlt=[0;0;0];
      this.quaternion=[1;0;0;0];
      this.dynamicParameters=logical(rand(1,30)>0.5);
    end

    function bits=getBits(this,tmin)
      assert(isa(tmin,'double'));
      bits=this.dynamicParameters;
    end

    function this=putBits(this,bits,tmin)
      fprintf('\n');
      fprintf('\ndynamicModelStub::putBits');
      fprintf('\ntmin = %f',tmin);
      fprintf('\nbits = ');
      fprintf('%d',bits);
      this.dynamicParameters=bits;
    end
     
    function a=domain(this)
      a=this.a;
    end
   
    function [lonLatAlt,quaternion]=evaluate(this,t)
      N=numel(t);
      lonLatAlt=repmat(this.lonLatAlt,[1,N]);
      lonLatAlt(2,:)=t;
      quaternion=repmat(this.quaternion,[1,N]);
      lonLatAlt(:,t<this.a)=NaN;
      quaternion(:,t<this.a)=NaN;
    end
    
    function [lonLatAltRate,quaternionRate]=derivative(this,t)
      N=numel(t);
      lonLatAltRate=zeros(3,N);
      lonLatAltRate(2,:)=1;
      quaternionRate=zeros(4,N);
      lonLatAltRate(:,t<this.a)=NaN;
      quaternionRate(:,t<this.a)=NaN;
    end
  end
  
  methods (Static=true)
    function cost=priorCost(bits,tmin)
      assert(isa(tmin,'double'));
      cost=zeros(size(bits,1),1);
    end
  end
    
end
