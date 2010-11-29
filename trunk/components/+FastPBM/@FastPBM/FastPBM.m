classdef FastPBM < FastPBM.FastPBMConfig & tom.Measure
  
  properties (SetAccess = private, GetAccess = private)
    sensor
    tracker
    container
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
      try
        [scheme, resource] = strtok(uri, ':');
        resource = resource(2:end);
        switch(scheme)
          case 'antbed'
            this.container = antbed.DataContainer.create(resource, initialTime);
            list = this.container.listSensors('antbed.Camera');
            this.sensor = this.container.getSensor(list(1));
          otherwise
            error('Unrecognized resource identifier in URI');
        end
      catch err
        error('Failed to open data resource: %s', err.message);
      end
      
      % instantiate the tracker by name
      switch(this.trackerName)
      case 'SparseTrackerKLT'
        this.tracker = FastPBM.SparseTrackerKLT(initialTime, this.sensor);
      otherwise
        error('unrecognized tracker');
      end
      
      if(this.calibrate)
        this.generateModel();
      end
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
      
      translation = [poseB.p(1)-poseA.p(1);
        poseB.p(2)-poseA.p(2);
        poseB.p(3)-poseA.p(3)];
      
      residual = computeResidual(translation, data.rayA, data.rayB);
      cost = computeCost2(residual, 0, this.angularDeviation);
    end
  end
    
  methods (Access = private)
    function generateModel(this)      
      if(hasReferenceTrajectory(this.container))
        groundTraj = getReferenceTrajectory(this.container);
        
        for k = 1:100
          this.tracker.refresh(groundTraj);
        end
        
        nFirst = this.tracker.first();
        nLast = this.tracker.last();
        edgeList = findEdges(this, nFirst, nLast, nFirst, nLast);
        
        for i = 1:numel(edgeList)
          nA = edgeList(i).first;
          nB = edgeList(i).second;
          
          % return 0 if the specified edge is not found in the graph
          isAdjacent = (nA<nB) && ...
            hasData(this.tracker) && ...
            (nA>=first(this.tracker)) && ...
            (nB<=last(this.tracker));
          if(~isAdjacent)
            return;
          end
          
          % return NaN if the graph edge extends outside of the trajectory domain
          tA = getTime(this.tracker, nA);
          tB = getTime(this.tracker, nB);
          interval = domain(groundTraj);
          if(tA<interval.first)
            return;
          end
          
          poseA = evaluate(groundTraj, tA);
          poseB = evaluate(groundTraj, tB);
          
          numA = this.tracker.numFeatures(nA);
          numB = this.tracker.numFeatures(nB);
          kA = (uint32(1):numA)-uint32(1);
          kB = (uint32(1):numB)-uint32(1);
          idA = this.tracker.getFeatureID(nA, kA);
          idB = this.tracker.getFeatureID(nB, kB);
          
          % find features common to both images
          [idAB, indexA, indexB] = intersect(double(idA), double(idB)); % only supports double
          kA = kA(indexA);
          kB = kB(indexB);
          
          % get corresponding rays
          rayA = this.tracker.getFeatureRay(nA, kA);
          rayB = this.tracker.getFeatureRay(nB, kB);
          
          %translate to rotation matrix
          ARot = Quat2Matrix(poseA.q);
          BRot = Quat2Matrix(poseB.q);
          
          %correct for rotation
          rayACorr = ARot*rayA;
          rayBCorr = BRot*rayB;
          
          modelErrors(poseB.p-poseA.p, rayACorr, rayBCorr);
        end        
      else
        error('DataContainer needs a refrence trajectory');
      end
    end
  end
  
end
