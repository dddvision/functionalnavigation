classdef GlobalSatData < GlobalSatData.GlobalSatDataConfig & tom.Measure

  properties (GetAccess = private, SetAccess = private)
    sensor
  end

  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'GPS based measure that simulates the GlobalSat BU-xxx GPS sensor.';
      end
      tom.Measure.connect(name, @componentDescription, @GlobalSatData.GlobalSatData);
    end
  end
  
  methods (Access = public, Static = true)
    function this = GlobalSatData(initialTime, uri)
      this = this@tom.Measure(initialTime, uri);
      this.sensor = GlobalSatData.GpsSim(initialTime, uri);     
    end
  end

  methods (Access = public, Static = false)
    function refresh(this, x)
      this.sensor.refresh(x);
    end
    
    function flag = hasData(this)
      flag = this.sensor.hasData();
    end
    
    function n = first(this)
      n = this.sensor.first();
    end
    
    function n = last(this)
      n = this.sensor.last();
    end
    
    function time = getTime(this, n)
      time = this.sensor.getTime(n);
    end
      
    function edgeList = findEdges(this, naMin, naMax, nbMin, nbMax)
      edgeList = repmat(tom.GraphEdge, [0, 1]);
      if(this.sensor.hasData())
        naMin = max([naMin, nbMin, this.sensor.first()]);
        naMax = min([naMax, nbMax, this.sensor.last()]);
        a = naMin:naMax;
        if(naMax>=naMin)
          edgeList = tom.GraphEdge(a, a);
        end
      end
    end
    
    function cost = computeEdgeCost(this, x, graphEdge)
      n = graphEdge.first;
      % TODO: incorporate offset
      % offset = this.sensor.getAntennaOffset();
      if(this.sensor.hasPrecision())
        [hDOP, vDOP, sigmaR] = this.sensor.getPrecision(n);
      else
        % hDOP = 10;
        % vDOP = 10;
        sigmaR = 10;
      end
      [lon, lat, alt] = this.sensor.getGlobalPosition(n);
      time = this.sensor.getTime(n);
      pMeasured = GlobalSatData.lolah2ecef([lon; lat; alt]);
      pose = x.evaluate(time);
      pHypothesis = pose.p;
      dnorm = norm(pMeasured-pHypothesis);
      cost = 0.5*dnorm*dnorm/(sigmaR*sigmaR);
    end
  end
  
end
