classdef DefaultDynamicModel < Default.DefaultTrajectory & tom.DynamicModel
  
  properties (Constant = true, GetAccess = private)
    cost = 0;
    numParameters = uint32(0);
    parameterErrorText = 'This default dynamic model has no input parameters';
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = ['This default dynamic model represents a stationary body at the world origin.', ...
          'It has no input parameters.'];
      end
      tom.DynamicModel.connect(name, @componentDescription, @Default.DefaultDynamicModel);
    end
  end
  
  methods (Access = public, Static = true)
    function this = DefaultDynamicModel(initialTime, uri)
      this = this@Default.DefaultTrajectory(initialTime);
      this = this@tom.DynamicModel(initialTime, uri);
    end
  end
  
  methods (Access = public, Static = false)  
    function num = numInitialLogical(this)
      num = this.numParameters;
    end
    
    function num = numInitialUint32(this)
      num = this.numParameters;      
    end
  
    function num = numExtensionLogical(this)
      num = this.numParameters;
    end
    
    function num = numExtensionUint32(this)
      num = this.numParameters;
    end

    function num = numExtensionBlocks(this)
      num = this.numParameters;
    end
    
    function v = getInitialLogical(this, p)
      assert(isa(p, 'uint32'));
      v = false;
      error(this.parameterErrorText);
    end

    function v = getInitialUint32(this, p)
      assert(isa(p, 'uint32'));
      v = uint32(0);
      error(this.parameterErrorText);
    end

    function v = getExtensionLogical(this, b, p)
      assert(isa(b, 'uint32'));
      assert(isa(p, 'uint32'));
      v = false;
      error(this.parameterErrorText);
    end

    function v = getExtensionUint32(this, b, p)
      assert(isa(b, 'uint32'));
      assert(isa(p, 'uint32'));
      v = uint32(0);
      error(this.parameterErrorText);
    end

    function setInitialLogical(this, p, v)
      assert(isa(p, 'uint32'));
      assert(isa(v, 'logical'));
      error(this.parameterErrorText);
    end

    function setInitialUint32(this, p, v)
      assert(isa(p, 'uint32'));
      assert(isa(v, 'uint32'));
      error(this.parameterErrorText);
    end
    
    function setExtensionLogical(this, b, p, v)
      assert(isa(b, 'uint32'));
      assert(isa(p, 'uint32'));
      assert(isa(v, 'logical'));
      error(this.extensionErrorText);
    end
    
   function setExtensionUint32(this, b, p, v)
      assert(isa(b, 'uint32'));
      assert(isa(p, 'uint32'));
      assert(isa(v, 'uint32'));
      error(this.extensionErrorText);
    end
    
    function cost = computeInitialBlockCost(this)
      cost = this.cost;
    end

    function cost = computeExtensionBlockCost(this, b)
      assert(isa(b, 'uint32'));
      cost = this.cost;
      error(this.parameterErrorText);
    end
    
    function extend(this)
      assert(isa(this, 'tom.DynamicModel'));
    end
  end
  
end
