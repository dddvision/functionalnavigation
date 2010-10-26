classdef Measure < tom.Default.Sensor & tom.Measure

  properties (Access = private)
    edgeList
    cost
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'This default measure constructs no graph edges and always returns zero cost.';
      end
      tom.Measure.connect(name, @componentDescription, @tom.Default.Measure);
    end
  end
  
  methods (Access = public, Static = true)
    function this = Measure(initialTime, uri)
      this = this@tom.Default.Sensor(initialTime);
      this = this@tom.Measure(initialTime, uri);
      this.edgeList = repmat(tom.GraphEdge, [0, 1]);
      this.cost = 0;
    end
  end
  
  methods (Access = public, Static = false)
    function edgeList = findEdges(this, naMin, naMax, nbMin, nbMax)
      assert(isa(naMin, 'uint32'));
      assert(isa(naMax, 'uint32'));
      assert(isa(nbMin, 'uint32'));
      assert(isa(nbMax, 'uint32'));
      edgeList = this.edgeList;
    end
    
    function cost = computeEdgeCost(this, x, graphEdge)
      assert(isa(x, 'tom.Trajectory'));
      assert(isa(graphEdge, 'tom.GraphEdge'));
      cost = this.cost;
    end
  end
  
end
