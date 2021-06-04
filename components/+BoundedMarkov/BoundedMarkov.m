classdef BoundedMarkov < BoundedMarkov.BoundedMarkovConfig & tom.DynamicModel
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  
  properties (Constant = true, GetAccess = private)
    initialNumLogical = uint32(0);
    initialNumUint32 = uint32(0);
    extensionNumLogical = uint32(0);
    initialBlockCost = 0;
    extensionBlockCost = 0;
    chunkSize = 256;
    numStates = 12;
  end
  
  properties (Access = protected)
    interval
    uri
    numInputs
    initialBlock
    firstNewBlock % one-based indexing
    block % one-based indexing
    state % body state starting at initial time
    Ad % discrete version of state space A matrix
    Bd % discrete version of state space A matrix
    ABZ % intermediate formulation of A and B matrices with zeros appended
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'Represents the integration of linear Markov motion model with a bounded forcing function.';
      end
      tom.DynamicModel.connect(name, @componentDescription, @BoundedMarkov.BoundedMarkov);
    end
  end
  
  methods (Access = public)
    function this = BoundedMarkov(initialTime, uri)
      this = this@tom.DynamicModel(initialTime, uri);
      this.initialBlock = struct('logical', false(1, this.initialNumLogical), ...
        'uint32', zeros(1, this.initialNumUint32, 'uint32'));
      this.firstNewBlock = 1;
      this.interval.first = initialTime;
      this.interval.second = initialTime;
      this.uri = uri;
      this.block = struct('logical', {}, 'uint32', {});
      this.numInputs = size(this.B, 2);
      this.state = zeros(this.numStates, this.chunkSize);
      this.ABZ = [this.A, this.B;sparse(this.numInputs, this.numStates+this.numInputs)];
      ABd = expmApprox(this.ABZ/this.rate);
      this.Ad = sparse(ABd(1:this.numStates, 1:this.numStates));
      this.Bd = sparse(ABd(1:this.numStates, (this.numStates+1):end));
    end

    function interval = domain(this)
      interval = this.interval;
    end
   
    function pose = evaluate(this, t)
      N = numel(t);
      if(N==0)
        pose = repmat(tom.Pose, [1, 0]);
      else
        [lowerBound, upperBound, dkFloor, dtRemain] = this.preEvaluate(t);
        pose(1, N) = tom.Pose;
        for n = find(lowerBound)
          if(upperBound(n))
            substate = this.subIntegrate(dkFloor(n), dtRemain(n));
            pose(n).p = substate(1:3)+this.initialPosition;
            pose(n).q = tom.Rotation.quatToHomo(tom.Rotation.axisToQuat(substate(4:6)))*this.initialRotation;
          else
            finalTangentPose = this.tangent(this.interval.second);
            pose(n) = predictPose(finalTangentPose, t(n)-this.interval.second);
          end
        end
      end
    end
    
    function tangentPose = tangent(this, t)
      N = numel(t);
      if(N==0)
        tangentPose = repmat(tom.TangentPose, [1, 0]);
      else
        [lowerBound, upperBound, dkFloor, dtRemain] = this.preEvaluate(t);
        tangentPose(1, N) = tom.TangentPose;
        for n = find(lowerBound)
          if(upperBound(n))
            substate = this.subIntegrate(dkFloor(n), dtRemain(n));
            tangentPose(n).p = substate(1:3)+this.initialPosition;
            tangentPose(n).q = tom.Rotation.quatToHomo(tom.Rotation.axisToQuat(substate(4:6)))*this.initialRotation;
            tangentPose(n).r = substate(7:9)+this.initialPositionRate;
            tangentPose(n).s = this.initialOmega+substate(10:12);
          else
            finalTangentPose = this.tangent(this.interval.second);
            tangentPose(n) = predictTangentPose(finalTangentPose, t(n)-this.interval.second);
          end
        end
      end
    end
    
    function num = numInitial(this)
      num = this.initialNumUint32;      
    end
    
    function num = numExtension(this)
      num = uint32(size(this.B, 2));
    end
    
    function num = numBlocks(this)
      num = uint32(numel(this.block));
    end
    
    function v = getInitial(this, p)
      v = this.initialBlock.uint32(p+1);
    end
    
    function v = getExtension(this, b, p)
      v = this.block(b+1).uint32(p+1);
    end
    
    function setInitial(this, p, v)
      this.initialBlock.uint32(p+1) = v;
    end
    
    function setExtension(this, b, p, v)
      this.block(b+1).uint32(p+1) = v;
      this.firstNewBlock = min(this.firstNewBlock, b+1);
    end

    function cost = computeInitialCost(this)
      cost = this.initialBlockCost;
    end

    function cost = computeExtensionCost(this, b)
      assert(isa(b, 'uint32'));
      assert(numel(b)==1);
      cost = this.extensionBlockCost;
    end
    
    function extend(this)
      blank = struct('logical', false(0, 1), 'uint32', zeros(1, this.numExtension(), 'uint32'));
      this.block = cat(2, this.block, blank);
      N = numel(this.block);
      if((N+1)>size(this.state, 2))
        this.state = [this.state, zeros(this.numStates, this.chunkSize)];
      end
      this.interval.second = this.interval.first+N/this.rate;
    end
     
    function obj = copy(this)
      obj = BoundedMarkov.BoundedMarkov(this.interval.first, this.uri);
      mc = metaclass(this);
      prop = mc.Properties;
      for p = 1:numel(prop)
        if(~prop{p}.Constant)
          obj.(prop{p}.Name) = this.(prop{p}.Name);
        end
      end
    end
  end
  
  methods (Access = private)
    function [lowerBound, upperBound, dkFloor, dtRemain] = preEvaluate(this, t)
      ta = this.interval.first;
      tb = this.interval.second;
      dt = t-ta;
      dk = dt*this.rate;
      dkFloor = floor(dk);
      dtFloor = dkFloor/this.rate;
      dtRemain = dt-dtFloor;
      lowerBound = (t>=ta);
      upperBound = (t<=tb);
      dkMax = max(dk(upperBound));
      this.blockIntegrate(ceil(dkMax)); % ceil is not floor+1 for integers
    end
    
    function blockIntegrate(this, K)
      for k = this.firstNewBlock:K
        force = block2unitforce(this.block(k));
        this.state(:, k+1) = this.Ad*this.state(:, k)+this.Bd*force';
      end
      this.firstNewBlock = K+1;
    end
    
    function substate = subIntegrate(this, kF, dt)
      N = this.numStates;
      sF = kF+1;
      if(dt<eps)
        substate = this.state(:, sF);
      else
        ABsub = expmApprox(this.ABZ*dt);
        force = block2unitforce(this.block(sF));
        substate = ABsub*[this.state(:, sF);force']; % fast
        substate = substate(1:N);
      end
    end
  end
    
end

function force = block2unitforce(block)
  halfIntMax = 2147483647.5;
  force = double(block.uint32)/halfIntMax-1;
end

function expA = expmApprox(A)
  expA = speye(size(A))+A+(A*A)/2;
end

function pose = predictPose(tP, dt)
  N = numel(dt);
  if(N==0)
    pose = repmat(tom.Pose, [1, 0]);
    return;
  end

  p = tP.p*ones(1, N)+tP.r*dt;
  dq = tom.Rotation.axisToQuat(tP.s*dt);
  q = tom.Rotation.quatMult(dq, tP.q);
  
  pose(1, N) = tom.Pose;
  for n = 1:N
    pose(n).p = p(:, n);
    pose(n).q = q(:, n);
  end
end

function tangentPose = predictTangentPose(tP, dt)
  N = numel(dt);
  if(N==0)
    tangentPose = repmat(tom.TangentPose, [1, 0]);
    return;
  end

  p = tP.p*ones(1, N)+tP.r*dt;
  dq = tom.Rotation.axisToQuat(tP.s*dt); 
  q = tom.Rotation.quatMult(dq, tP.q);

  tangentPose(1, N) = tP;
  for n = 1:N
    tangentPose(n).p = p(:, n);
    tangentPose(n).q = q(:, n);
    tangentPose(n).r = tP.r;
    tangentPose(n).s = tP.s;
  end
end
