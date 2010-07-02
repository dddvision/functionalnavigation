% This class represents the integration of linear Markov motion model with a bounded forcing function
classdef BoundedMarkov < BoundedMarkov.BoundedMarkovConfig & DynamicModel
  
  properties (Constant=true,GetAccess=private)
    initialNumLogical=uint32(0);
    initialNumUint32=uint32(0);
    extensionNumLogical=uint32(0);
    initialBlockCost=0;
    extensionBlockCost=0;
    chunkSize=256;
    numStates=12;
  end
  
  properties (GetAccess=private,SetAccess=private)
    interval
    numInputs
    initialBlock
    firstNewBlock % one-based indexing
    block % one-based indexing
    state % body state starting at initial time
    Ad % discrete version of state space A matrix
    Bd % discrete version of state space A matrix
    ABZ % intermediate formulation of A and B matrices with zeros appended
  end
  
  methods (Access=public)
    function this=BoundedMarkov(initialTime,uri)
      this=this@DynamicModel(initialTime,uri);
      this.initialBlock=struct('logical',false(1,this.initialNumLogical),...
        'uint32',zeros(1,this.initialNumUint32,'uint32'));
      this.firstNewBlock=1;
      this.interval=TimeInterval(initialTime,initialTime);
      this.block=struct('logical',{},'uint32',{});
      this.numInputs=size(this.B,2);
      this.state=zeros(this.numStates,this.chunkSize);
      this.ABZ=[this.A,this.B;sparse(this.numInputs,this.numStates+this.numInputs)];
      ABd=expmApprox(this.ABZ/this.rate);
      this.Ad=sparse(ABd(1:this.numStates,1:this.numStates));
      this.Bd=sparse(ABd(1:this.numStates,(this.numStates+1):end));
    end

    function num=numInitialLogical(this)
      num=this.initialNumLogical;
    end
    
    function num=numInitialUint32(this)
      num=this.initialNumUint32;      
    end
    
    function num=numExtensionLogical(this)
      num=this.extensionNumLogical;
    end
    
    function num=numExtensionUint32(this)
      num=uint32(size(this.B,2));
    end
    
    function num=numExtensionBlocks(this)
      num=numel(this.block);
    end
    
    function v=getInitialLogical(this,p)
      v=this.initialBlock.logical(p+1);
    end
    
    function v=getInitialUint32(this,p)
      v=this.initialBlock.uint32(p+1);
    end
    
    function v=getExtensionLogical(this,b,p)
      v=this.block(b+1).logical(p+1);
    end
    
    function v=getExtensionUint32(this,b,p)
      v=this.block(b+1).uint32(p+1);
    end
    
    function setInitialLogical(this,p,v)
      this.initialBlock.logical(p+1)=v;
    end
    
    function setInitialUint32(this,p,v)
      this.initialBlock.uint32(p+1)=v;
    end
    
    function setExtensionLogical(this,b,p,v)
      this.block(b+1).logical(p+1)=v;
      this.firstNewBlock=min(this.firstNewBlock,b+1);
    end
    
    function setExtensionUint32(this,b,p,v)
      this.block(b+1).uint32(p+1)=v;
      this.firstNewBlock=min(this.firstNewBlock,b+1);
    end

    function cost=computeInitialBlockCost(this)
      cost=this.initialBlockCost;
    end

    function cost=computeExtensionBlockCost(this,b)
      assert(isa(b,'uint32'));
      assert(numel(b)==1);
      cost=this.extensionBlockCost;
    end
    
    function extend(this)
      blank=struct('logical',false(0,1),'uint32',zeros(1,numExtensionUint32(this),'uint32'));
      this.block=cat(2,this.block,blank);
      N=numel(this.block);
      if((N+1)>size(this.state,2))
        this.state=[this.state,zeros(this.numStates,this.chunkSize)];
      end
      this.interval.second=this.interval.first+N/this.rate;
    end
     
    function interval=domain(this)
      interval=this.interval;
    end
   
    function pose=evaluate(this,t)
      [goodList,dkFloor,dtRemain]=preEvaluate(this,t);
      pose(1,numel(t))=Pose;
      for n=goodList
        substate=subIntegrate(this,dkFloor(n),dtRemain(n));
        pose(n).p=substate(1:3)+this.initialPosition;
        pose(n).q=Quat2Homo(AxisAngle2Quat(substate(4:6)))*this.initialRotation; % verified
      end
    end
    
    function tangentPose=tangent(this,t)
      [goodList,dkFloor,dtRemain]=preEvaluate(this,t);
      tangentPose(1,numel(t))=TangentPose;
      for n=goodList
        substate=subIntegrate(this,dkFloor(n),dtRemain(n));
        tangentPose(n).p=substate(1:3)+this.initialPosition;
        tangentPose(n).q=Quat2Homo(AxisAngle2Quat(substate(4:6)))*this.initialRotation; % verified
        tangentPose(n).r=substate(7:9)+this.initialPositionRate;
        tangentPose(n).s=0.5*Quat2Homo(pose.q(:,n))*([0;this.initialOmega+substate(10:12)]);
      end
    end
  end
  
  methods (Access=private)
    function [goodList,dkFloor,dtRemain]=preEvaluate(this,t)
      ta=this.interval.first;
      tb=this.interval.second;
      dt=t-ta;
      dk=dt*this.rate;
      dkFloor=floor(dk);
      dtFloor=dkFloor/this.rate;
      dtRemain=dt-dtFloor;
      good=(t>=ta)&(t<=tb);
      dkMax=max(dk(good));
      blockIntegrate(this,ceil(dkMax)); % ceil is not floor+1 for integers
      goodList=find(good);
    end
    
    function blockIntegrate(this,K)
      for k=this.firstNewBlock:K
        force=block2unitforce(this.block(k));
        this.state(:,k+1)=this.Ad*this.state(:,k)+this.Bd*force';
      end
      this.firstNewBlock=K+1;
    end
    
    function substate=subIntegrate(this,kF,dt)
      N=this.numStates;
      sF=kF+1;
      if(dt<eps)
        substate=this.state(:,sF);
      else
        ABsub=expmApprox(this.ABZ*dt);
        force=block2unitforce(this.block(sF));
        substate=ABsub*[this.state(:,sF);force']; % fast
        substate=substate(1:N);
      end
    end
  end
    
end

function force=block2unitforce(block)
  halfIntMax=2147483647.5;
  force=double(block.uint32)/halfIntMax-1;
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