classdef MeasureDefault < tom.SensorDefault & tom.Measure
 
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
      this = this@tom.SensorDefault(initialTime);
      this = this@tom.Measure(initialTime, uri);
    end
  end
  
  methods (Access = public, Static = false)
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
