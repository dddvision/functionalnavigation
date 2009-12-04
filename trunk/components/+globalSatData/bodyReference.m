classdef bodyReference < trajectory
    
  properties (SetAccess=private, GetAccess=private)
    pts
    gpsTime
    zone
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
    
    function [a,b] = domain(this)
      a = this.gpsTime(1);
      b = this.gpsTime(end);
    end
    
    function [ecef,quat] = evaluate(this,t)
      [a,b] = domain(this);
      ecef = globalSatData.cardinalSpline(this.gpsTime, this.pts, t, this.simConfig.splineTension, 0);
      ecef = ecef';
      K=numel(t);
      quat = [ones(1,K);zeros(3,K)];
      ecef(:,(t<a)|(t>b))=NaN;
      quat(:,(t<a)|(t>b))=NaN;
    end
    
    function [ecefRate,quatRate] = derivative(this,t)
      [a,b] = domain(this);
      [tmp, ecefRate] = globalSatData.cardinalSpline(this.gpsTime, this.pts, t, c, 0);
      ecefRate = ecefRate';
      quatRate = zeros(4,numel(t));
      ecefRate(:,(t<a)|(t>b))=NaN;
      quatRate(:,(t<a)|(t>b))=NaN;
    end
  end
  
end
