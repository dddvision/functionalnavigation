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
    
    function [ecef,quat,ecefRate,quatRate] = evaluate(this,t)
      [a,b] = domain(this);
      [ecef,ecefRate] = globalSatData.cardinalSpline(this.gpsTime, this.pts, t, this.simConfig.splineTension, 0);
      ecef = ecef';
      ecefRate = ecefRate';
      K=numel(t);
      quat = [ones(1,K);zeros(3,K)];
      quatRate = zeros(4,K);
      bad=(t<a)|(t>b);
      ecef(:,bad)=NaN;
      quat(:,bad)=NaN;
      ecefRate(:,bad)=NaN;
      quatRate(:,bad)=NaN;
    end
  end
  
end
