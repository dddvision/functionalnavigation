% This class represents a dynamic model of a fictitious system
classdef dynamicModelStub < dynamicModel
  
  properties (GetAccess=private,SetAccess=private)
    a
    b
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
      this.b=2;
      this.parametersPerSecond=15;
      this.lonLatAlt=[0;0;0];
      this.quaternion=[1;0;0;0];
      this.dynamicParameters=logical(rand(2,30)>0.5);
    end

    function bits=getBits(this,tmin)
      assert(isa(tmin,'double'));
      bits=this.dynamicParameters;
    end

    function this=putBits(this,bits,tmin)
      fprintf('\n');
      fprintf('\ndynamicModelStub::putBits');
      fprintf('\ntmin = %f',tmin);
      this.dynamicParameters(:)=bits(:);
      fprintf('\nbits = ');
      fprintf('%d',this.dynamicParameters);
    end
     
    function [a,b]=domain(this)
      a=this.a;
      b=this.b;
    end
   
    function [lonLatAlt,quaternion]=evaluate(this,t)
      N=numel(t);
      lonLatAlt=repmat(this.lonLatAlt,[1,N]);
      lonLatAlt(2,:)=t;
      quaternion=repmat(this.quaternion,[1,N]);
      bad=(t<this.a)|(t>this.b);
      lonLatAlt(:,bad)=NaN;
      quaternion(:,bad)=NaN;
    end
    
    function [lonLatAltRate,quaternionRate]=derivative(this,t)
      N=numel(t);
      lonLatAltRate=zeros(3,N);
      lonLatAltRate(2,:)=1;
      quaternionRate=zeros(4,N);
      bad=(t<this.a)|(t>this.b);
      lonLatAltRate(:,bad)=NaN;
      quaternionRate(:,bad)=NaN;
    end
  end
  
%   methods (Static=true)
%     function cost=priorCost(bits,tmin)
%       assert(isa(tmin,'double'));
%       cost=zeros(size(bits,1),1);
%     end
%   end
    
end
