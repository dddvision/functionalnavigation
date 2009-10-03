classdef trajectoryStub < trajectory
  
  properties (GetAccess=private,SetAccess=private)
    pose
    parametersPerSecond
    dynamicParameters
  end
  
  methods (Access=public)
    function this=trajectoryStub
      fprintf('\n');
      fprintf('\ntrajectoryStub::trajectoryStub');
      this.parametersPerSecond=15;
      this.pose=[0;0;0;1;0;0;0];
      this.dynamicParameters=logical(rand(1,30)>0.5);
    end

    function bits=getBits(this,tmin)
      bits=this.dynamicParameters;
    end

    function this=putBits(this,bits,tmin)
      fprintf('\n');
      fprintf('\ntrajectoryStub::putBits');
      fprintf('\ntmin = %f',tmin);
      fprintf('\nbits = ');
      fprintf('%d',bits);
      this.dynamicParameters=bits;
    end
    
    function cost=priorCost(this,bits,tmin)
      cost=zeros(size(bits,1),1);
    end
     
    function a=domain(this)
      a=0;
    end
   
    function posquat=evaluate(this,t)
      N=numel(t);
      posquat=repmat(this.pose,[1,N]);
      posquat(2,:)=t;
      a=domain(this);
      posquat(:,t<a)=NaN;
    end
    
    function posquatdot=derivative(this,t)
      N=numel(t);
      posquatdot=zeros(7,N);
      posquatdot(2,:)=1;
      a=domain(this);
      posquatdot(:,t<a)=NaN;
    end
  end
  
end
