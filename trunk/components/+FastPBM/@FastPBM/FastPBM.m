classdef FastPBM < FastPBM.FastPBMConfig & tom.Measure
  
  properties (SetAccess=private, GetAccess=private)
    sensor
    tracker
  end
  
  methods (Static=true, Access=public)
    function initialize(name)
      function text = componentDescription
        text = 'Implements a fast visual feature tracker and associated trajectory measure.';
      end
      tom.Measure.connect(name, @componentDescription, @FastPBM.FastPBM);
    end
  end
  
  methods (Access=public)
    function this = FastPBM(initialTime, uri)
      this = this@tom.Measure(initialTime, uri);

      try
        [scheme, resource] = strtok(uri, ':');
        resource = resource(2:end);
        switch(scheme)
          case 'matlab'
            container = tom.DataContainer.create(resource, initialTime);
            list = container.listSensors('Camera');
            this.sensor = container.getSensor(list(1));
          otherwise
            error('Unrecognized resource identifier in URI');
        end
      catch err
        error('Failed to open data resource: %s', err.message);
      end                  

      this.tracker = FastPBM.SparseTrackerKLT(initialTime, this.sensor);
    end
    
    function refresh(this)
      this.tracker.refresh();
    end
    
    function flag = hasData(this)
      flag = this.tracker.hasData();
    end
    
    function n = first(this)
      n = this.tracker.first();
    end
    
    function n = last(this)
      n = this.tracker.last();
    end
    
    function time = getTime(this, n)
      time = this.tracker.getTime(n);
    end
    
    function edgeList = findEdges(this, x, naMin, naMax, nbMin, nbMax)
      assert(isa(x, 'tom.Trajectory'));
      edgeList = repmat(tom.GraphEdge, [0, 1]);
      if(hasData(this.tracker))
        nMin = max([naMin, this.tracker.first(), nbMin-uint32(1)]);
        nMax = min([naMax+uint32(1), this.tracker.last(), nbMax]);
        nList = nMin:nMax;
        [na, nb] = ndgrid(nList, nList);
        keep = nb(:)>na(:);
        na = na(keep);
        nb = nb(keep);
        if(~isempty(na))
          edgeList = tom.GraphEdge(na, nb);
        end
      end
    end
    
    function cost = computeEdgeCost(this, x, graphEdge)
      nA = graphEdge.first;
      nB = graphEdge.second;
      
      % return 0 if the specified edge is not found in the graph
      isAdjacent = ((nA+uint32(1))==nB) && ...
        hasData(this.tracker) && ...
        (nA>=first(this.tracker)) && ...
        (nB<=last(this.tracker));
      if(~isAdjacent)
        cost = 0;
        return;
      end

      % return NaN if the graph edge extends outside of the trajectory domain
      tA = getTime(this.tracker, nA);
      tB = getTime(this.tracker, nB);
      interval = domain(x);
      if((tA<interval.first)||(tB>interval.second))
        cost = NaN;
        return;
      end

      % get data from the tracker
      % numA = this.tracker.numFeatures(nA);
      % k = uint32(1):numA;
      % rayA = this.tracker.getFeatureRay(nA,k-uint32(1));
      % idA = this.tracker.getFeatureID(nA,k-uint32(1));
      
      %poseA = evaluate(x,tA);
      %poseB = evaluate(x,tB);
      
      cost=0;
    end
  end
  
end
