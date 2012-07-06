classdef DynamicModelBridge < tom.DynamicModel

  properties (SetAccess = protected, GetAccess = protected)
    name
    initialTime
    uri
    m % mex name without extension
    h % handle to instantiated C++ object
  end
  
  methods (Access = public, Static = true)
    function initialize(name)
      assert(isa(name, 'char'));
      compileOnDemand(name);
      className = [name, '.', name(find(['.', name]=='.', 1, 'last'):end)];     
      mName = [className, 'Bridge'];
      function text = componentDescription
        text = feval(mName, 'DynamicModelDescription', name);
      end
      function obj = componentFactory(initialTime, uri)
        obj = tom.DynamicModelBridge(name, initialTime, uri);
      end
      if(feval(mName, 'DynamicModelIsConnected', name))
        tom.DynamicModel.connect(name, @componentDescription, @componentFactory);
      end
    end

    function this = DynamicModelBridge(name, initialTime, uri)
      if(nargin==0)
        initialTime = 0.0;
        uri = '';
      end
      this = this@tom.DynamicModel(initialTime, uri);
      if(nargin>0)
        assert(isa(name, 'char'));
        assert(isa(initialTime, 'double'));
        assert(isa(uri, 'char'));
        compileOnDemand(name);
        className = [name, '.', name(find(['.', name]=='.', 1, 'last'):end)];
        this.name = name;
        this.initialTime = initialTime;
        this.uri = uri;
        this.m = [className, 'Bridge'];
        initialTime = double(initialTime); % workaround avoids array duplication
        this.h = feval(this.m, 'DynamicModelFactory', name, initialTime, uri);
      end
    end
  end
    
  methods (Access = public)
    function interval = domain(this)
      interval = feval(this.m, this.h, 'domain');
    end
   
    function pose = evaluate(this, t)
      assert(isa(t, 'double'));
      N = numel(t);
      if(N==0);
        pose = repmat(tom.Pose, [1, 0]);
      else
        t = double(t); % workaround avoids array duplication
        pose(1, N) = tom.Pose; % workaround creates object externally
      end
      pose = feval(this.m, this.h, 'evaluate', pose, t); % call even if t is empty
    end
    
    function tangentPose = tangent(this, t)
      assert(isa(t, 'double'));
      N = numel(t);
      if(N==0);
        tangentPose = repmat(tom.TangentPose, [1, 0]);
      else
        t = double(t); % workaround avoids array duplication
        tangentPose(1, N) = tom.TangentPose; % workaround creates object externally
      end
      tangentPose = feval(this.m, this.h, 'tangent', tangentPose, t); % call even if t is empty
    end
    
    function num = numInitial(this)
       num = feval(this.m, this.h, 'numInitial');
    end
    
    function num = numExtension(this)
       num = feval(this.m, this.h, 'numExtension');
    end
    
    function num = numBlocks(this)
       num = feval(this.m, this.h, 'numBlocks');
    end
    
    function v = getInitial(this, p)
      v = feval(this.m, this.h, 'getInitialUint32', p);
    end
    
    function v = getExtension(this, b, p)
      v = feval(this.m, this.h, 'getExtension', b, p);
    end
    
    function setInitial(this, p, v)
      feval(this.m, this.h, 'setInitial', p, v);
    end
    
    function setExtension(this, b, p, v)
      feval(this.m, this.h, 'setExtension', b, p, v);
    end

    function cost = computeInitialCost(this)
      cost = feval(this.m, this.h, 'computeInitialCost');
    end

    function cost = computeExtensionCost(this, b)
      cost = feval(this.m, this.h, 'computeExtensionCost', b);
    end
    
    function extend(this)
      feval(this.m, this.h, 'extend');
    end  
    
    function obj = copy(this)
      obj = tom.DynamicModelBridge();
      obj.name = this.name;
      obj.initialTime = this.initialTime;
      obj.uri = this.uri;
      obj.m = this.m;
      obj.h = feval(this.m, this.h, 'copy');
    end
  end
  
end

function compileOnDemand(name)
  persistent tried
  if(~isempty(tried))
    return;
  end
  tried = true;
  bridge = mfilename('fullpath');
  bridgecpp = [bridge, '.cpp'];
  include1 = ['-I"', fileparts(bridge), '"'];
  include2 = ['-I"', fileparts(which('hidi.SensorPackage')), '"'];
  base = fullfile(['+', name], name);
  basecpp = [base, '.cpp'];
  cpp = which(basecpp);
  output = [cpp(1:(end-4)), 'Bridge'];
  if(exist(output, 'file'))
    delete([output, '.', mexext]);
  end
  mex(include1, include2, bridgecpp, cpp, '-output', output);
end
