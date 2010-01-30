% This class represents a dynamic model of a fictitious system
classdef wobble1 < wobble1.wobble1Config & dynamicModel
  
  properties (GetAccess=private,SetAccess=private)
    ta
    data
    initialPosition
    initialRotation
    initialPositionRate
    initialRotationRate
  end
  
  methods (Static=true,Access=public)
    function description=getBlockDescription
      description=struct('numLogical',30,'numUint32',0);
    end
    
    function blocksPerSecond=getUpdateRate
      blocksPerSecond=0;
    end
  end
  
  methods (Access=public)
    function this=wobble1(uri,initialTime)
      this=this@dynamicModel(uri,initialTime);
      fprintf('\n');
      fprintf('\nwobble1::wobble1');
      this.ta=initialTime;
      this.initialPosition = [0;0;0];
      this.initialRotation = [1;0;0;0];
      this.initialPositionRate = [0;0;0];
      this.initialRotationRate = [0;0;0;0];
    end
    
    function numBlocks=getNumBlocks(this)
      numBlocks=double(~isempty(this.data));
    end
    
    function setInitialState(this,position,rotation,positionRate,rotationRate)
      fprintf('\n');
      fprintf('\nwobble1::setInitialState');
      this.initialPosition = position;
      this.initialRotation = rotation;
      this.initialpositionRate = positionRate;
      this.initialRotationRate = rotationRate;
    end
    
    function replaceBlocks(this,k,block)
      fprintf('\n');
      fprintf('\nwobble1::replaceBlocks');
      if(k==0)
        bits=block(1).logical;
        this.data=reshape(bits,[1,numel(bits)]);
      end
    end
    
    function appendBlocks(this,blocks)
      fprintf('\n');
      fprintf('\nwobble1::appendBlocks');
      bits=blocks(1).logical;
      this.data=reshape(bits,[1,numel(bits)]);
    end
    
    function [ta,tb]=domain(this)
      ta=this.ta;
      if(getNumBlocks(this)>0)
        tb=inf;
      else
        tb=ta;
      end
    end
    
    function [position,rotation,positionRate,rotationRate]=evaluate(this,t)
      t(t<this.ta)=NaN;
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

      N=numel(t);
      pnoise=this.scalep*[rate_bias(1)*sint;rate_bias(2)*sint;rate_bias(3)*sint];
      position=repmat(this.initialPosition,[1,N])+[pnoise(1,:);t+pnoise(2,:);pnoise(3,:)];
      
      if( nargout>1 )
        qnoise=this.scaleq*[rate_bias(4)*sint;rate_bias(5)*sint;rate_bias(6)*sint];
        rotation=Quat2Homo(this.initialRotation)'*AxisAngle2Quat(qnoise);
        if( nargout>2 )
          omegacos=omega*cos(omega*t);
          pdnoise=this.scalep*[rate_bias(1)*omegacos;rate_bias(2)*omegacos;rate_bias(3)*omegacos];
          positionRate=repmat(this.initialPositionRate+[0;1;0],[1,N])+pdnoise;
          if( nargout>3 )      
            qdnoise=this.scaleq*[rate_bias(4)*omegacos;rate_bias(5)*omegacos;rate_bias(6)*omegacos];
            rotationRate=zeros(4,N);
            for n=1:N
              rotationRate(:,n)=0.5*Quat2Homo(rotation(:,n))*[0;qdnoise(:,n)]; % small angle approximation
            end
          end
        end
      end
    end
  end
  
end

function h=Quat2Homo(q)
  q1=q(1);
  q2=q(2);
  q3=q(3);
  q4=q(4);
  h=[[q1,-q2,-q3,-q4]
     [q2, q1,-q4, q3]
     [q3, q4, q1,-q2]
     [q4,-q3, q2, q1]];
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
  n(n<eps)=eps;
  a=v1./n;
  b=v2./n;
  c=v3./n;
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