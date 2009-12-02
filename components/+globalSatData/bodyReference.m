classdef bodyReference < trajectory
  properties (SetAccess=private, GetAccess=private)
    pts
    gpsTime
    zone
    a
    simConfig
  end
  
  methods (Access=public)
    function this = bodyReference
      this.simConfig = globalSatData.configGPSsimulator;
      maindir = pwd;
      currdir = [maindir '/components/+globalSatData'];
      full_fname = fullfile(currdir, this.simConfig.TLoLaAltFile);
      [this.gpsTime, lon, lat, alt, vDOP, hDOP]= textread(full_fname,'%f %f %f %f %f %f', 'delimiter',',');
      [X, Y, Z] = globalSatData.lolah2ecef(lon, lat, alt);
      this.pts = [X Y Z];
    end
    
    function a = domain(this)
      a = [this.gpsTime(1) this.gpsTime(end)];
    end
    
    function posquat = evaluate(this,t)
      
      tmppos = globalSatData.cardinalSpline(this.gpsTime, this.pts, t, this.simConfig.splineTension, 0);
      
      [lat, lon, alt] = globalSatData.ecef2lolah(tmppos(:,1), tmppos(:,2), tmppos(:,3));
      posquat = [lon lat alt 0 0 0 0];
    end
    
    function posquatdot = derivative(this,t)
      [tmp, posquatdot] = globalSatData.cardinalSpline(this.gpsTime, this.pts, t, c, 0);
      posdot = [posdot 0 0 0 0];
      
    end
  end
end
