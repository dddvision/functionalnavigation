classdef MeasureBridge < tom.Measure

  properties (SetAccess = private, GetAccess = private)
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
        text = feval(mName, 'MeasureDescription', name);
      end
      function obj = componentFactory(initialTime, uri)
        obj = tom.MeasureBridge(name, initialTime, uri);
      end
      if(feval(mName, 'MeasureIsConnected', name))
        tom.Measure.connect(name, @componentDescription, @componentFactory);
      end
    end
    
    function this = MeasureBridge(name, initialTime, uri)
      if(nargin==0)
        initialTime = 0.0;
        uri = '';
      end
      this = this@tom.Measure(initialTime, uri);
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
        this.h = feval(this.m, 'MeasureFactory', name, initialTime, uri);
      end
    end
  end
    
  methods (Access = public)
    function refresh(this, x)
      % implements a workaround that depends on a Trajectory named 'x'
      assert(isa(x, 'tom.Trajectory'));
      feval(this.m, this.h, 'refresh', x);
    end

    function flag = hasData(this)
      flag = feval(this.m, this.h, 'hasData');
    end

    function na = first(this)
      na = feval(this.m, this.h, 'first');
    end
    
    function nb = last(this)
      nb = feval(this.m, this.h, 'last');
    end

    function time = getTime(this, n)
      time = feval(this.m, this.h, 'getTime', n);
    end
    
    function edgeList = findEdges(this, naMin, naMax, nbMin, nbMax)
      edgeList = feval(this.m, this.h, 'findEdges', naMin, naMax, nbMin, nbMax);
    end

    function cost = computeEdgeCost(this, x, graphEdge)
      % implements a workaround that depends on a Trajectory named 'x'
      assert(isa(x, 'tom.Trajectory'));
      cost = feval(this.m, this.h, 'computeEdgeCost', graphEdge);
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
