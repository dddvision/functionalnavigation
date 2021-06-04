classdef XDynamics < XDynamics.XDynamicsConfig & tom.DynamicModel
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  
  properties (Constant = true, GetAccess = private)
    initialNum = uint32(2);
    extensionNum = uint32(0);
    extensionBlockCost = 0;
    blockNum = uint32(0);
    extensionErrorText = 'This dynamic model has no extension blocks';
  end
  
  properties (GetAccess = private, SetAccess = private)
    initialTime
    uri
    initial
    xRef
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = ['Evaluates a reference trajectory and adds perturbation to initial ECEF X positon and velocity. ', ...
          'Perturbation is simulated by sampling from a normal distribution.'];
      end
      tom.DynamicModel.connect(name, @componentDescription, @XDynamics.XDynamics);
    end
  end
  
  methods (Access = public)
    function this = XDynamics(initialTime, uri)
      this = this@tom.DynamicModel(initialTime, uri);
      this.initialTime = initialTime;
      this.uri = uri;
      this.initial = zeros(1, this.initialNum, 'uint32');
      if(~strncmp(uri, 'hidi:', 5))
        error('URI scheme not recognized');
      end
      container = hidi.DataContainer.create(uri(6:end), initialTime);
      if(hasReferenceTrajectory(container))
        this.xRef = getReferenceTrajectory(container);
      else
        this.xRef = tom.DynamicModelDefault(initialTime, uri);
      end
    end
    
    function interval = domain(this)
      interval = this.xRef.domain();
    end
    
    function pose = evaluate(this, t)
      N = numel(t);
      if(N==0)
        pose = repmat(tom.Pose, [1, 0]);
      else
        pose = this.xRef.evaluate(t);
        z = block2deviation(this.initial);
        t = double(t);
        t0 = double(this.initialTime);
        c1 = this.positionOffset-this.positionDeviation*z(1);
        c2 = this.positionRateOffset-this.positionRateDeviation*z(2);
        for n = 1:N
          pose(n).p(1) = pose(n).p(1)+c1+c2*(t(n)-t0);
        end
      end
    end
   
    function tangentPose = tangent(this, t)
      N = numel(t);
      if(N==0);
        tangentPose = repmat(tom.TangentPose, [1, 0]);
      else
        tangentPose = this.xRef.tangent(t);
        z = block2deviation(this.initial);
        t = double(t);
        t0 = double(this.initialTime);
        c1 = this.positionOffset-this.positionDeviation*z(1);
        c2 = this.positionRateOffset-this.positionRateDeviation*z(2);
        for n = 1:N
          tangentPose(n).p(1) = tangentPose(n).p(1)+c1+c2*(t(n)-t0);
          tangentPose(n).r(1) = tangentPose(n).r(1)+c2;
        end
      end
    end
    
    function num = numInitial(this)
      num = this.initialNum;      
    end
    
    function num = numExtension(this)
      num = this.extensionNum;
    end

    function num = numBlocks(this)
      num = this.blockNum;
    end

    function v = getInitial(this, p)
      assert(isa(p, 'uint32'));
      assert(numel(p)==1);
      v = this.initial(p+1);
    end

    function v = getExtension(this, b, p)
      assert(isa(b, 'uint32'));
      assert(numel(b)==1);
      assert(isa(p, 'uint32'));
      assert(numel(p)==1);
      v = uint32(0);
      error(this.extensionErrorText);
    end

    function setInitial(this, p, v)
      assert(isa(p, 'uint32'));
      assert(numel(p)==1);
      assert(isa(v, 'uint32'));
      assert(numel(v)==1);
      % assert(p<this.initialNum); % removed for speed
      this.initial(p+1) = v;
    end
    
    function setExtension(this, b, p, v)
      assert(isa(b, 'uint32'));
      assert(numel(b)==1);
      assert(isa(p, 'uint32'));
      assert(numel(p)==1);
      assert(isa(v, 'uint32'));
      assert(numel(v)==1);
      error(this.extensionErrorText);
    end
    
    function cost = computeInitialCost(this)
      z = block2deviation(this.initial);
      cost = 0.5*(z*z');
    end

    function cost = computeExtensionCost(this, b)
      assert(isa(b, 'uint32'));
      assert(numel(b)==1);
      cost = this.extensionBlockCost;
    end
    
    function extend(this)
      assert(isa(this, 'tom.DynamicModel'));
    end
    
    function obj = copy(this)
      obj = XDynamics.XDynamics(this.initialTime, this.uri);
      mc = metaclass(this);
      prop = mc.Properties;
      for p = 1:numel(prop)
        if(~prop{p}.Constant)
          obj.(prop{p}.Name) = this.(prop{p}.Name);
        end
      end
    end    
  end
  
end

function z = block2deviation(block)
  sixthIntMax = 715827882.5;
  z = double(block)/sixthIntMax-3;
end
