% NOTE: this represents a dynamic model of a fictitious system
classdef lineWobble1 < trajectory
  
  properties
    data
    parametersPerSecond
  end
  
  methods
    function this=lineWobble1
      fprintf('\n');
      fprintf('\nlineWobble1::lineWobble1');
      this.parametersPerSecond=15;
      this.data=logical(rand(1,30)>0.5);
    end

    function bits=getBits(this,tmin)
      bits=this.data;
    end

    function this=putBits(this,bits,tmin)
      fprintf('\n');
      fprintf('\n%s::putBits',class(this));
      fprintf('\ntmin = %f',tmin);
      fprintf('\nbits = ');
      fprintf('%d',bits);
      this.data=bits;
    end
    
    function cost=priorCost(this,bits,tmin)
      cost=zeros(size(bits,1),1);
    end
    
    function [a,b]=domain(this)
      a=0;
      b=numel(this.data)/this.parametersPerSecond;
    end
    
    function posquat=evaluate(this,t)
      ta=domain(this);

      t(t<ta)=NaN;

      dim=6;
      scalep=0.02;
      scaleq=0.1;

      omegabits=6;
      scaleomega=10;

      vaxis=this.data((omegabits+1):(end-mod(numel(this.data),dim)));
      bpa=numel(vaxis)/dim;
      rate_bias=zeros(dim,1);
      for d=1:dim
        bits=vaxis((d-1)*bpa+(1:bpa))';
        rate_bias(d)=(1-2*bitsplit(bits));
      end

      bits=this.data(1:omegabits)';
      omega=scaleomega*(1-2*bitsplit(bits));
      sint=sin(omega*t);

      pnoise=scalep*[rate_bias(1)*sint;rate_bias(2)*sint;rate_bias(3)*sint];
      qnoise=scaleq*[rate_bias(4)*sint;rate_bias(5)*sint;rate_bias(6)*sint];

      posquat=[[0*t;t;0.*t]+pnoise;
      AxisAngle2Quat(qnoise)];
    end
    
    % TODO: implement this function properly
    function posquatdot=derivative(this,t)
      warning('derivative of this trajectory type is not yet supported');
      N=numel(t);
      [ta,tb]=domain(this);
      posquatdot=zeros(7,N);
      posquatdot(:,t<ta|t>tb)=NaN;
    end
  end
  
end
