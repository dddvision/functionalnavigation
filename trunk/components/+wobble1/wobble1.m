% This class represents a dynamic model of a fictitious system
classdef wobble1 < wobble1.wobble1Config & dynamicModel
  
  properties (GetAccess=private,SetAccess=private)
    data
    parametersPerSecond
  end
  
  methods (Access=public)
    function this=wobble1
      fprintf('\n');
      fprintf('\nwobble1::wobble1');
      this.parametersPerSecond=15;
      this.data=logical(rand(1,30)>0.5);
    end

    function bits=getBits(this,tmin)
      assert(isa(tmin,'double'));
      bits=this.data;
    end

    function this=putBits(this,bits,tmin)
      fprintf('\n');
      fprintf('\nwobble1::putBits');
      fprintf('\ntmin = %f',tmin);
      this.data(:)=bits(:);
      fprintf('\nbits = ');
      fprintf('%d',this.data);
    end
    
    function [a,b]=domain(this)
      a=0;
      b=numel(this.data)/this.parametersPerSecond;
    end
    
    function [ecef,quaternion,ecefRate,quaternionRate]=evaluate(this,t)
      ta=domain(this);
      t(t<ta)=NaN;
      vaxis=this.data((this.omegabits+1):(end-mod(numel(this.data),this.dim)));
      bpa=numel(vaxis)/this.dim;
      rate_bias=zeros(this.dim,1);
      for d=1:this.dim
        bits=vaxis((d-1)*bpa+(1:bpa))';
        rate_bias(d)=(1-2*bitsplit(bits));
      end
      bits=this.data(1:this.omegabits)';
      omega=this.scaleomega*(1-2*bitsplit(bits));
      
      sint=sin(omega*t);

      pnoise=this.scalep*[rate_bias(1)*sint;rate_bias(2)*sint;rate_bias(3)*sint];
      ecef=[0*t;t;0.*t]+pnoise;
      
      if( nargout>1 )
        qnoise=this.scaleq*[rate_bias(4)*sint;rate_bias(5)*sint;rate_bias(6)*sint];
        quaternion=AxisAngle2Quat(qnoise);
        if( nargout>2 )
          omegacos=omega*cos(omega*t);
          pdnoise=this.scalep*[rate_bias(1)*omegacos;rate_bias(2)*omegacos;rate_bias(3)*omegacos];
          ecefRate=[0*t;1+0*t;0.*t]+pdnoise;
          if( nargout>3 )      
            qdnoise=this.scaleq*[rate_bias(4)*omegacos;rate_bias(5)*omegacos;rate_bias(6)*omegacos];
            quaternionRate=[0*t;qdnoise/2]; % small angle approximation
          end
        end
      end
    end
  end
  
%   methods (Static=true)
%     function cost=priorCost(bits,tmin)
%       assert(isa(tmin,'double'));
%       cost=zeros(size(bits,1),1);
%     end
%   end
  
end

% Converts orientation representation from Axis-Angle to Quaternion
%
% INPUT
% v = axis angle vectors, 3-by-N
%
% OUTPUT
% q = quaternion vectors, 4-by-N
%
% NOTES
% Does not preserve wrap-around
function q=AxisAngle2Quat(v)
  v1=v(1,:);
  v2=v(2,:);
  v3=v(3,:);
  n=sqrt(v1.*v1+v2.*v2+v3.*v3);
  if isnumeric(v)
    ep=1E-12;
    n(n<ep)=ep;
  end
  a=v1./n;
  b=v2./n;
  c=v3./n;
  if isnumeric(v)
    zn=[zeros(size(n));n];
    zn=unwrap(zn);
    n=zn(2,:);
  end
  th2=n/2;
  s=sin(th2);
  q1=cos(th2);
  q2=s.*a;
  q3=s.*b;
  q4=s.*c;
  q=[q1;q2;q3;q4];
  q=QuatNorm(q);
end

% Normalize each quaternion to have unit magnitude and positive first element
%
% INPUT/OUTPUT
% Q = quaternions (4-by-n)
function Q=QuatNorm(Q)
  % input checking
  if(size(Q,1)~=4)
    error('argument must be 4-by-n');
  end

  % extract elements
  q1=Q(1,:);
  q2=Q(2,:);
  q3=Q(3,:);
  q4=Q(4,:);

  % normalization factor
  n=sqrt(q1.*q1+q2.*q2+q3.*q3+q4.*q4);

  % handle negative first element and zero denominator
  s=sign(q1);
  ns=n.*s;
  ns(ns==0)=1;
  
  % normalize
  Q(1,:)=q1./ns;
  Q(2,:)=q2./ns;
  Q(3,:)=q3./ns;
  Q(4,:)=q4./ns;
end

% Returns a partition of a unit interval given a bit string
%
% INPUT
% b = bits, logical 1-by-N or N-by-1
%
% OUTPUT
% z = number in the range [0,1]
function z=bitsplit(b)
  N=numel(b);
  z=0.5;
  dz=0.25;
  for n=1:N
    if(b(n))
      z=z+dz;
    else
      z=z-dz;
    end
    dz=dz/2;
  end
end
