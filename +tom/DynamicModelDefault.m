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
  
  methods (Access = public)   
    function num = numInitial(this)
      assert(isa(this, 'tom.DynamicModel'));
      num = uint32(0);
    end
    
    function num = numExtension(this)
      assert(isa(this, 'tom.DynamicModel'));
      num = uint32(0);
    end

    function num = numBlocks(this)
      assert(isa(this, 'tom.DynamicModel'));
      num = uint32(0);
    end

    function v = getInitial(this, p)
      assert(isa(this, 'tom.DynamicModel'));
      assert(isa(p, 'uint32'));
      v = uint32(0);
      assert(isa(v, 'uint32'));
      error('The default dynamic model has no input parameters.');
    end

    function v = getExtension(this, b, p)
      assert(isa(this, 'tom.DynamicModel'));
      assert(isa(b, 'uint32'));
      assert(isa(p, 'uint32'));
      v = uint32(0);
      assert(isa(v, 'uint32'));
      error('The default dynamic model has no input parameters.');
    end

    function setInitial(this, p, v)
      assert(isa(this, 'tom.DynamicModel'));
      assert(isa(p, 'uint32'));
      assert(isa(v, 'uint32'));
      error('The default dynamic model has no input parameters.');
    end

    function setExtension(this, b, p, v)
      assert(isa(this, 'tom.DynamicModel'));
      assert(isa(b, 'uint32'));
      assert(isa(p, 'uint32'));
      assert(isa(v, 'uint32'));
      error('The default dynamic model has no input parameters.');
    end
    
    function cost = computeInitialCost(this)
      assert(isa(this, 'tom.DynamicModel'));
      cost = 0;
      assert(isa(cost, 'double'));
    end

    function cost = computeExtensionCost(this, b)
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
