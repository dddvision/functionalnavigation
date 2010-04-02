% This class represents the integration of linear Markov motion model with a bounded forcing function
classdef BoundedMarkov < BoundedMarkov.BoundedMarkovConfig & DynamicModel
  
  properties (Constant=true,GetAccess=private)
    halfIntMax=2147483647.5;
    initialBlockCost=0;
    extensionBlockCost=0;
    chunkSize=256;
    numStates=12;
  end
  
  properties (GetAccess=private,SetAccess=private)
    ta
    tb
    numInputs
    initialBlock
    firstNewBlock % one-based indexing
    block % one-based indexing
    state % body state starting at initial time
    Ad % discrete version of state space A matrix
    Bd % discrete version of state space A matrix
    ABZ % intermediate formulation of A and B matrices with zeros appended
  end
  
  methods (Static=true,Access=public)
    function description=initialBlockDescription
      description=struct('numLogical',uint32(0),'numUint32',uint32(0));      
    end
    
    function description=extensionBlockDescription
      description=struct('numLogical',uint32(0),'numUint32',uint32(size(BoundedMarkov.BoundedMarkovConfig.B,2)));
    end
    
    function rate=updateRate
      rate=BoundedMarkov.BoundedMarkovConfig.rate;
    end
  end
  
  methods (Access=public)
    function this=BoundedMarkov(initialTime,initialBlock,uri)
      this=this@DynamicModel(initialTime,initialBlock,uri);
      assert(numel(initialBlock)==1);
      this.initialBlock=initialBlock;
      this.firstNewBlock=1;
      this.ta=initialTime;
      this.tb=initialTime;
      this.block=struct('logical',{},'uint32',{});
      this.numInputs=size(this.B,2);
      this.state=zeros(this.numStates,this.chunkSize);
      this.ABZ=[this.A,this.B;sparse(this.numInputs,this.numStates+this.numInputs)];
      ABd=expmApprox(this.ABZ/this.rate);
      this.Ad=sparse(ABd(1:this.numStates,1:this.numStates));
      this.Bd=sparse(ABd(1:this.numStates,(this.numStates+1):end));
    end

    function cost=computeInitialBlockCost(this,initialBlock)
      assert(isa(initialBlock,'struct'));
      assert(numel(initialBlock)==1);
      cost=this.initialBlockCost;
    end
    
    function setInitialBlock(this,initialBlock)
      assert(isa(initialBlock,'struct'));
      assert(numel(initialBlock)==1);
      this.initialBlock=initialBlock;
    end
    
    function initialBlock=getInitialBlock(this)
      initialBlock=this.initialBlock;
    end
    
    function cost=computeExtensionBlockCost(this,block)
      assert(isa(block,'struct'));
      assert(numel(block)==1);
      cost=this.extensionBlockCost;
    end
    
    function numExtensionBlocks=getNumExtensionBlocks(this)
      numExtensionBlocks=numel(this.block);
    end
    
    function setExtensionBlocks(this,k,blocks)
      assert(isa(k,'uint32'));
      assert(isa(blocks,'struct'));
      assert(numel(k)==numel(blocks));
      if(isempty(blocks))
        return;
      end
      assert((k(end)+1)<=numel(this.block));
      k=k+1; % convert to one-based index
      this.block(k)=blocks;
      this.firstNewBlock=min(this.firstNewBlock,k(1));
    end
    
    function blocks=getExtensionBlocks(this,k)
      assert(isa(k,'uint32'));
      blocks=struct('logical',{},'uint32',{});
      for kk=1:numel(k)
        blocks(kk)=this.block(k(kk)+1);
      end
    end
    
    function appendExtensionBlocks(this,blocks)
      if(isempty(blocks))
        return;
      end
      this.block=cat(2,this.block,blocks);
      N=numel(this.block);
      if((N+1)>size(this.state,2))
        this.state=[this.state,zeros(this.numStates,this.chunkSize)];
      end
      this.tb=this.ta+N/this.rate;
    end
     
    function [ta,tb]=domain(this)
      ta=this.ta;
      tb=this.tb;
    end
   
    function [position,rotation,positionRate,rotationRate]=evaluate(this,t)
      N=numel(t);
      dt=t-this.ta;
      dk=dt*this.rate;
      dkFloor=floor(dk);
      dtFloor=dkFloor/this.rate;
      dtRemain=dt-dtFloor;
      position=NaN(3,N);
      rotation=NaN(4,N);
      positionRate=NaN(3,N);
      rotationRate=NaN(4,N);
      good=logical((t>=this.ta)&(t<=this.tb));
      firstGood=find(good,1,'first');
      lastGood=find(good,1,'last');
      blockIntegrate(this,ceil(dk(lastGood))); % ceil is not floor+1 for integers
      for n=firstGood:lastGood
        substate=subIntegrate(this,dkFloor(n),dtRemain(n));
        position(:,n)=substate(1:3)+this.initialPosition;
        if(nargout>1)
          rotation(:,n)=Quat2Homo(AxisAngle2Quat(substate(4:6)))*this.initialRotation; % verified
          if(nargout>2)
            positionRate(:,n)=substate(7:9)+this.initialPositionRate;
            if(nargout>3)
              rotationRate(:,n)=0.5*Quat2Homo(rotation(:,n))*([0;this.initialOmega+substate(10:12)]);
            end
          end
        end
      end
    end
  end
  
  methods (Access=private)
    function blockIntegrate(this,K)
      for k=this.firstNewBlock:K
        force=block2unitforce(this,this.block(k));
        this.state(:,k+1)=this.Ad*this.state(:,k)+this.Bd*force;
      end
      this.firstNewBlock=K+1;
    end
    
    function substate=subIntegrate(this,kF,dt)
      sF=kF+1;
      if(dt<eps)
        substate=this.state(:,sF);
      else
        ABsub=expmApprox(this.ABZ*dt);
        Asub=ABsub(1:this.numStates,1:this.numStates);
        Bsub=ABsub(1:this.numStates,(this.numStates+1):end);
        force=block2unitforce(this,this.block(sF));
        substate=Asub*this.state(:,sF)+Bsub*force;
      end
    end
    
    function force=block2unitforce(this,block)
      force=double(block.uint32')/this.halfIntMax-1; % transpose
    end
  end
    
end

function expA=expmApprox(A)
  expA=speye(size(A))+A+(A*A)/2;
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
end