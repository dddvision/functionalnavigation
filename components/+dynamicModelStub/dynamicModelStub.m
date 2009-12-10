% This class represents a dynamic model of a fictitious system
classdef dynamicModelStub < dynamicModel
  
  properties (GetAccess=private,SetAccess=private)
    a
    b
    ecef
    quaternion
    parametersPerSecond
    dynamicParameters
  end
  
  methods (Access=public)
    function this=dynamicModelStub
      fprintf('\n');
      fprintf('\ndynamicModelStub::dynamicModelStub');
      this.a=0;
      this.b=3;
      this.parametersPerSecond=15;
      this.ecef=[0;0;0];
      this.quaternion=[1;0;0;0];
      this.dynamicParameters=logical(rand(1,45)>0.5);
    end

    function bits=getBits(this,tmin)
      assert(isa(tmin,'double'));
      bits=this.dynamicParameters;
    end

    function this=putBits(this,bits,tmin)
      fprintf('\n');
      fprintf('\ndynamicModelStub::putBits');
      assert(nargout==1);
      fprintf('\ntmin = %f',tmin);
      this.dynamicParameters(:)=bits(:);
      fprintf('\nbits = ');
      fprintf('%d',this.dynamicParameters);
    end
     
    function [a,b]=domain(this)
      a=this.a;
      b=this.b;
    end
   
    function [ecef,quaternion,ecefRate,quaternionRate]=evaluate(this,t)
      N=numel(t);
      ecef=repmat(this.ecef,[1,N]);
      ecef(2,:)=t;
      quaternion=repmat(this.quaternion,[1,N]);
      ecefRate=zeros(3,N);
      ecefRate(2,:)=1;
      quaternionRate=zeros(4,N);
      bad=(t<this.a)|(t>this.b);
      ecef(:,bad)=NaN;
      quaternion(:,bad)=NaN;
      ecefRate(:,bad)=NaN;
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
