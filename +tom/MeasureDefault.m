classdef MeasureDefault < tom.Measure
% Copyright 2011 Scientific Systems Company Inc., New BSD License
 
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'This default measure constructs no graph edges.';
      end
      tom.Measure.connect(name, @componentDescription, @tom.MeasureDefault);
    end
  end
  
  methods (Access = public, Static = true)
    function this = MeasureDefault(initialTime, uri)
      this = this@tom.Measure(initialTime, uri);
    end
  end
  
  methods (Access = public)
    function refresh(this, x)
      assert(isa(this, 'hidi.Sensor'));
      assert(isa(x, 'tom.Trajectory'));
    end
    
    function flag = hasData(this)
      assert(isa(this, 'hidi.Sensor'));
      flag = false;
    end
    
    function n = first(this)
      assert(isa(this, 'hidi.Sensor'));
      n = uint32(0);
      assert(isa(n, 'uint32'));
      error('The default sensor has no data.');
    end
    
    function n = last(this)
      assert(isa(this, 'hidi.Sensor'));
      n = uint32(0);
      assert(isa(n, 'uint32'));
      error('The default sensor has no data.');
    end
    
    function time = getTime(this, n)
      assert(isa(this, 'hidi.Sensor'));
      assert(isa(n, 'uint32'));
      time = 0.0;
      assert(isa(time, 'double'));
      error('The default sensor has no data.');
    end
    
    function edgeList = findEdges(this, naMin, naMax, nbMin, nbMax)
      assert(isa(this, 'tom.Measure'));
      assert(isa(naMin, 'uint32'));
      assert(isa(naMax, 'uint32'));
      assert(isa(nbMin, 'uint32'));
      assert(isa(nbMax, 'uint32'));
      edgeList = repmat(tom.GraphEdge, [0, 1]);
    end
    
    function cost = computeEdgeCost(this, x, graphEdge)
      assert(isa(this, 'tom.Measure'));
      assert(isa(x, 'tom.Trajectory'));
      assert(isa(graphEdge, 'tom.GraphEdge'));
      cost = 0;      
    end
  end
  
end
