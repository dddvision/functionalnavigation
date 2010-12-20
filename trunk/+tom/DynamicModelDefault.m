classdef DynamicModelDefault < tom.DynamicModel
  
  properties (GetAccess = protected, SetAccess = protected)
    interval
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'This default dynamic model represents a stationary body at the world origin with no input parameters.';
      end
      tom.DynamicModel.connect(name, @componentDescription, @tom.DynamicModelDefault);
    end
  end
  
  methods (Access = public, Static = true)
    function this = DynamicModelDefault(initialTime, uri)
      this = this@tom.DynamicModel(initialTime, uri);
      this.interval = tom.TimeInterval(initialTime, tom.WorldTime(Inf));
    end
  end
  
  methods (Access = public, Static = false)   
    function num = numInitialLogical(this)
      assert(isa(this, 'tom.DynamicModel'));
      num = uint32(0);
    end
    
    function num = numInitialUint32(this)
      assert(isa(this, 'tom.DynamicModel'));
      num = uint32(0);
    end
  
    function num = numExtensionLogical(this)
      assert(isa(this, 'tom.DynamicModel'));
      num = uint32(0);
    end
    
    function num = numExtensionUint32(this)
      assert(isa(this, 'tom.DynamicModel'));
      num = uint32(0);
    end

    function num = numExtensionBlocks(this)
      assert(isa(this, 'tom.DynamicModel'));
      num = uint32(0);
    end
    
    function v = getInitialLogical(this, p)
      assert(isa(this, 'tom.DynamicModel'));
      assert(isa(p, 'uint32'));
      v = false;
      assert(isa(v, 'logical'));
      error('The default dynamic model has no input parameters.');
    end

    function v = getInitialUint32(this, p)
      assert(isa(this, 'tom.DynamicModel'));
      assert(isa(p, 'uint32'));
      v = uint32(0);
      assert(isa(v, 'uint32'));
      error('The default dynamic model has no input parameters.');
    end

    function v = getExtensionLogical(this, b, p)
      assert(isa(this, 'tom.DynamicModel'));
      assert(isa(b, 'uint32'));
      assert(isa(p, 'uint32'));
      v = false;
      assert(isa(v, 'logical'));
      error('The default dynamic model has no input parameters.');
    end

    function v = getExtensionUint32(this, b, p)
      assert(isa(this, 'tom.DynamicModel'));
      assert(isa(b, 'uint32'));
      assert(isa(p, 'uint32'));
      v = uint32(0);
      assert(isa(v, 'uint32'));
      error('The default dynamic model has no input parameters.');
    end

    function setInitialLogical(this, p, v)
      assert(isa(this, 'tom.DynamicModel'));
      assert(isa(p, 'uint32'));
      assert(isa(v, 'logical'));
      error('The default dynamic model has no input parameters.');
    end

    function setInitialUint32(this, p, v)
      assert(isa(this, 'tom.DynamicModel'));
      assert(isa(p, 'uint32'));
      assert(isa(v, 'uint32'));
      error('The default dynamic model has no input parameters.');
    end
    
    function setExtensionLogical(this, b, p, v)
      assert(isa(this, 'tom.DynamicModel'));
      assert(isa(b, 'uint32'));
      assert(isa(p, 'uint32'));
      assert(isa(v, 'logical'));
      error('The default dynamic model has no input parameters.');
    end
    
   function setExtensionUint32(this, b, p, v)
      assert(isa(this, 'tom.DynamicModel'));
      assert(isa(b, 'uint32'));
      assert(isa(p, 'uint32'));
      assert(isa(v, 'uint32'));
      error('The default dynamic model has no input parameters.');
    end
    
    function cost = computeInitialBlockCost(this)
      assert(isa(this, 'tom.DynamicModel'));
      cost = 0;
      assert(isa(cost, 'double'));
    end

    function cost = computeExtensionBlockCost(this, b)
      assert(isa(this, 'tom.DynamicModel'));
      assert(isa(b, 'uint32'));
      cost = 0;
      assert(isa(cost, 'double'));
      error('The default dynamic model has no extension blocks.');
    end
    
    function interval = domain(this)
      interval = this.interval;
    end
  
    function pose = evaluate(this, t)
      pose.p = [6378137.0; 0; 0];
      pose.q = [1; 0; 0; 0];
      pose = tom.Pose(pose);
      pose = repmat(pose, [1, numel(t)]);
      for k = find(t<this.interval.first)
        pose(k) = tom.Pose;
      end
    end

    function tangentPose = tangent(this, t)
      tangentPose.p = [6378137.0; 0; 0];
      tangentPose.q = [1; 0; 0; 0];
      tangentPose.r = [0; 0; 0];
      tangentPose.s = [0; 0; 0];
      tangentPose = tom.TangentPose(tangentPose);
      tangentPose = repmat(tangentPose, [1, numel(t)]);
      for k = find(t<this.interval.first)
        tangentPose(k) = tom.TangentPose;
      end
    end
    
    function extend(this)
      assert(isa(this, 'tom.DynamicModel'));
    end
    
    function obj = copy(this)
      obj = tom.DynamicModelDefault(tom.WorldTime(0),'');
      obj.interval = this.interval;
    end
  end
  
end
