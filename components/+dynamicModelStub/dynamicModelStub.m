% This class represents a dynamic model of a fictitious system
classdef dynamicModelStub < dynamicModelStub.dynamicModelStubConfig & dynamicModel
  
  properties (GetAccess=private,SetAccess=private)
    numStates
    firstNewBlock % one-based indexing
    chunkSize
    initialTime
    block % one-based indexing
    numInputs
    state % body state starting at initial time
    Ad % discrete version of state space A matrix
    Bd % discrete version of state space A matrix
  end
  
  methods (Static=true,Access=public)
    function description=getBlockDescription
      description=struct('numLogical',0,'numUint32',size(dynamicModelStub.dynamicModelStubConfig.B,2));
    end
    
    function blocksPerSecond=getUpdateRate
      blocksPerSecond=dynamicModelStub.dynamicModelStubConfig.blocksPerSecond;
    end
  end
  
  methods (Access=public)
    function this=dynamicModelStub(initialTime)
      this=this@dynamicModel(initialTime);
      fprintf('\n');
      fprintf('\ndynamicModelStub::dynamicModelStub');
      this.numStates = 12;
      this.firstNewBlock = 1;
      this.chunkSize = 256;
      this.initialTime = initialTime;
      this.block = struct('logical',{},'uint32',{});
      this.numInputs = size(this.B,2);
      this.state = zeros(this.numStates,this.chunkSize);
      ABd = expm([this.A,this.B;zeros(this.numInputs,this.numStates+this.numInputs)]/this.blocksPerSecond);
      this.Ad = sparse(ABd(1:this.numStates,1:this.numStates));
      this.Bd = sparse(ABd(1:this.numStates,(this.numStates+1):end));
    end

    function numBlocks=getNumBlocks(this)
      numBlocks=numel(this.block);
    end
    
    function setInitialState(this,position,rotation,positionRate,rotationRate)
      fprintf('\n');
      fprintf('\ndynamicModelStub::setInitialState');
      omega=2*Quat2Homo(rotation)'*rotationRate;
      this.state(:,1) = [position;Quat2AxisAngle(rotation);positionRate;omega(1:3)];
      this.firstNewBlock = 1;
    end
    
    function replaceBlocks(this,k,block)
      fprintf('\n');
      fprintf('\ndynamicModelStub::replaceBlocks');
      if(isempty(k))
        return;
      end
      k=k+1; % convert to one-based index
      assert(k(end)<=getNumBlocks(this));
      this.block(k)=block;
      this.firstNewBlock=min(this.firstNewBlock,k(1));
    end
    
    function appendBlocks(this,blocks)
      fprintf('\n');
      fprintf('\ndynamicModelStub::appendBlocks');
      this.block=cat(2,this.block,blocks);
      if((numel(this.block)+1)>size(this.state,2))
        this.state=[this.state,zeros(this.numStates,this.chunkSize)];
      end
    end
     
    function [ta,tb]=domain(this)
      ta=this.initialTime;
      tb=max(ta+getNumBlocks(this)/this.blocksPerSecond,ta);
    end
   
    function [position,rotation,positionRate,rotationRate]=evaluate(this,t)
      fprintf('\n');
      fprintf('\ndynamicModelStub::evaluate');
      N=numel(t);
      [ta,tb]=domain(this);
      dt=t-ta;
      dk=dt*this.blocksPerSecond;
      dkFloor=floor(dk);
      dtFloor=dkFloor/this.blocksPerSecond;
      dtRemain=dt-dtFloor;
      blockIntegrate(this,dkFloor(end));
      position=NaN(3,N);
      rotation=NaN(4,N);
      positionRate=NaN(3,N);
      rotationRate=NaN(4,N);
      good=logical((t>=ta)&(t<=tb));
      for n=find(good)
        substate=subIntegrate(this,dkFloor(n),dtRemain(n));
        position(:,n)=substate(1:3);
        rotation(:,n)=AxisAngle2Quat(substate(4:6));
        positionRate(:,n)=substate(7:9);
        rotationRate(:,n)=0.5*Quat2Homo(rotation(:,n))*[0;substate(10:12)];
      end
    end
  end
  
  methods (Access=private)
    function blockIntegrate(this,K)
      for k=this.firstNewBlock:K
        force=block2unitforce(this.block(k));
        this.state(:,k+1)=this.Ad*this.state(:,k)+this.Bd*force;
      end
      this.firstNewBlock = K+1;
    end
    
    function substate=subIntegrate(this,k,dt)
      if(dt<eps)
        substate = this.state(:,k+1);
      else
        ABsub = expm([this.A,this.B;zeros(this.numInputs,this.numStates+this.numInputs)]*dt);
        Asub = ABsub(1:this.numStates,1:this.numStates);
        Bsub = ABsub(1:this.numStates,(this.numStates+1):end);
        force = block2unitforce(this.block(k+1));
        substate = Asub*this.state(:,k+1)+Bsub*force;
      end
    end
  end
    
end

function force=block2unitforce(block)
  force=2*(double(reshape(block.uint32,[6,1]))/double(intmax('uint32')))-1;
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

function V=Quat2AxisAngle(Q)
  q1=Q(1,:);
  q2=Q(2,:);
  q3=Q(3,:);
  q4=Q(4,:);
  theta=2*acos(q1);
  n=sqrt(q2.*q2+q3.*q3+q4.*q4);
  n(n<eps)=eps;
  a=q2./n;
  b=q3./n;
  c=q4./n;
  v1=theta.*a;
  v2=theta.*b;
  v3=theta.*c;
  V=[v1;v2;v3];
end

function q=AxisAngle2Quat(v)
  v1=v(1,:);
  v2=v(2,:);
  v3=v(3,:);
  n=sqrt(v1.*v1+v2.*v2+v3.*v3);
  n(n<eps)=eps;
  a=v1./n;
  b=v2./n;
  c=v3./n;
  zn=[zeros(size(n));n];
  zn=unwrap(zn);
  n=zn(2,:);
  th2=n/2;
  s=sin(th2);
  q1=cos(th2);
  q2=s.*a;
  q3=s.*b;
  q4=s.*c;
  q=[q1;q2;q3;q4];
end
