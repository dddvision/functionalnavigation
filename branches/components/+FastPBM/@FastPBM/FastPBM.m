classdef FastPBM < FastPBM.FastPBMConfig & tom.Measure
  
  properties (SetAccess = private, GetAccess = private)
    sensor
    tracker
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'Implements a fast visual feature tracker and associated trajectory measure.';
      end
      tom.Measure.connect(name, @componentDescription, @FastPBM.FastPBM);
    end
  end
  
  methods (Access = public)
    function this = FastPBM(initialTime, uri)
      this = this@tom.Measure(initialTime, uri);

      container = antbed.DataContainer.create('MiddleburyData', initialTime);
      list = container.listSensors('antbed.Camera');
      this.sensor = container.getSensor(list(1));
      this.tracker = FastPBM.SparseTrackerKLT(initialTime, this.sensor);
      eList = findEdges(this,0,7,0,7);
      
      for i=1:size(eList)
          nA = eList(i).first;
          nA = eList(i).second;
          kA = (uint32(1):numA)-uint32(1);
          kB = (uint32(1):numB)-uint32(1);
          idA = this.tracker.getFeatureID(nA, kA);
          idB = this.tracker.getFeatureID(nB, kB);
          [idAB, indexA, indexB] = intersect(double(idA), double(idB)); % only supports double
          kA = kA(indexA);
          kB = kB(indexB);
          %add gausian stuff here
          
      end
      try
        [scheme, resource] = strtok(uri, ':');
        resource = resource(2:end);
        switch(scheme)
          case 'antbed'
            container = antbed.DataContainer.create(resource, initialTime);
            list = container.listSensors('antbed.Camera');
            this.sensor = container.getSensor(list(1));
          otherwise
            error('Unrecognized resource identifier in URI');
        end
      catch err
        error('Failed to open data resource: %s', err.message);
      end                  
      
      this.tracker = FastPBM.SparseTrackerKLT(initialTime, this.sensor);
    end
    
    function refresh(this, x)
      this.tracker.refresh(x);
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
    
    function edgeList = findEdges(this, naMin, naMax, nbMin, nbMax)
      edgeList = repmat(tom.GraphEdge, [0, 1]);
      if(hasData(this.tracker))
        nMin = max([naMin, this.tracker.first(), nbMin-uint32(1)]);
        nMax = min([naMax+uint32(1), this.tracker.last(), nbMax]);
        nList = nMin:nMax;
        [nb, na] = ndgrid(nList, nList);
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
      isAdjacent = (nA<nB) && ...
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
      if(tA<interval.first)
        cost = NaN;
        return;
      end
      
      poseA = evaluate(x, tA);
      poseB = evaluate(x, tB);
        
      data = computeIntermediateDataCache(this, graphEdge.first, graphEdge.second);

      u = transpose(data.pixB(:, 1)-data.pixA(:, 1));
      v = transpose(data.pixB(:, 2)-data.pixA(:, 2));

      Ea = Quat2Euler(poseA.q);
      Eb = Quat2Euler(poseB.q);

      translation = [poseB.p(1)-poseA.p(1);
                     poseB.p(2)-poseA.p(2);
                     poseB.p(3)-poseA.p(3)];
      rotation = [Eb(1)-Ea(1);
                  Eb(2)-Ea(2);
                  Eb(3)-Ea(3)];
      [uvr, uvt] = generateFlowSparse(this, translation, rotation, transpose(data.pixA), nA);

      cost = computeCost(this, u, v, uvr, uvt);
    end
  end
  
end