classdef BodyReference < GlobalSatData.GlobalSatDataConfig & tom.Trajectory
  
  properties (Constant = true, GetAccess = private)
    splineTension = 0;
  end
  
  properties (SetAccess = private, GetAccess = private)
    pts
    gpsTime
    zone
  end
  
  methods (Access = public, Static = true)
    function this = BodyReference(initialTime)
      currdir = fileparts(mfilename('fullpath'));
      full_fname = fullfile(currdir, this.referenceTrajectoryFile);
      [this.gpsTime, lon, lat, alt, vDOP, hDOP] = textread(full_fname, '%f %f %f %f %f %f', 'delimiter', ',');
      this.gpsTime = this.gpsTime+initialTime;
      [X, Y, Z] = GlobalSatData.lolah2ecef(lon, lat, alt);
      this.pts = [X'; Y'; Z'];
    end
  end
    
  methods (Access = public, Static = false)
    function interval = domain(this)
      interval = tom.TimeInterval(tom.WorldTime(this.gpsTime(1)), tom.WorldTime(this.gpsTime(end)));
    end
    
    function pose = evaluate(this, t)
      N = numel(t);
      if(N==0)
        pose = repmat(tom.Pose, [1, 0]);
      else
        pose(1, N) = tom.Pose;
        interval = domain(this);
        lowerBound = t>=interval.first;
        upperBound = t<=interval.second;
        p = cardinalSpline(this.gpsTime, this.pts, t(lowerBound&upperBound), this.splineTension); 
        k = 1;
        for n = find(lowerBound)
          if(upperBound(n))
            pose(n).p = p(:, k);
            pose(n).q = [1; 0; 0; 0];
            k = k+1;
          else
            tP = tangent(this, interval.second);
            pose(n).p = tP.p+tP.r*(t(n)-interval.second);
            pose(n).q = [1; 0; 0; 0];
          end
        end
      end
    end
    
    function tangentPose = tangent(this, t)
      N = numel(t);
      if(N==0);
        tangentPose = repmat(tom.TangentPose, [1, 0]);
      else
        tangentPose(1, N) = tom.TangentPose;
        interval = domain(this);
        lowerBound = t>=interval.first;
        upperBound = t<=interval.second;
        [p, r] = cardinalSpline(this.gpsTime, this.pts, t(lowerBound&upperBound), this.splineTension); 
        k = 1;
        for n = find(lowerBound)
          if(upperBound(n))
            tangentPose(n).p = p(:, k);
            tangentPose(n).q = [1; 0; 0; 0];
            tangentPose(n).r = r(:, k);
            tangentPose(n).s = [0; 0; 0; 0];
            k = k+1;
          else
            tangentPose(n) = tangent(this, interval.second);
            tangentPose(n).p = tangentPose(n).p+tangentPose(n).r*(t(n)-interval.second);
          end
        end
      end
    end
  end
  
end

% Cardinal spline interpolation
%
% INPUT
% @param[in]  tRef reference times, double 1-by-N
% @param[in]  pRef reference values, double D-by-N
% @param[in]  t    interpolation times, double 1-by-K
% @param[in]  c    (default 0) tension parameter, double scalar
% @param[out] p    values at interpolation times, double D-by-K
% @param[out] r    derivatives with respect to time at interpolation times, double D-by-K
%
% NOTES
% Returns initial values if queried before tRef(1)
% Returns final values if queried after tRef(N) 
% The default tension parameter yields a Catman Hull spline
function [p, r] = cardinalSpline(tRef, pRef, t, c)

  [D,N] = size(pRef);
  K = numel(t);
  p = zeros(D, K);
  r = zeros(D, K);
  
  if(K==0)
    return;
  end
   
  if(N<2)
    error('At least two points are required to interpolate');
  end

  % transpose reference points for convienience
  pRef = pRef';
  
  % compute the slopes at each given point
  if(nargin<4)
    c = 0;
  end
  wt = (1-c);
  m = zeros(size(pRef));
  m(1, :) = wt*(pRef(2, :)-pRef(1, :))./(tRef(2)-tRef(1));
  for n = 2:(N-1)
    m(n, :) = wt*(pRef(n+1, :)-pRef(n-1, :))./(tRef(n+1)-tRef(n-1));
  end
  m(end, :) = wt*(pRef(end, :)-pRef(end-1, :))/(tRef(end)-tRef(end-1));
 
  % interpolate
  for k = 1:K
    tIndex = find(t(k)>=tRef,1,'last');

    if(isempty(tIndex))
      tIndex = 1;
    end

    if(tIndex==N)
      tIndex = N-1;
    end
    
    tPlus = tIndex+1;
    tRange = tRef(tPlus)-tRef(tIndex);
    tNorm = (t(k)-tRef(tIndex))./tRange;

    h00 = 2*tNorm.^3-3*tNorm.^2+1;
    h10 = tNorm.^3-2*tNorm.^2+tNorm;
    h01 = -2*tNorm.^3+3*tNorm.^2;
    h11 = tNorm.^3-tNorm.^2;

    h00dot = 6*tNorm.^2-6*tNorm;
    h10dot = 3*tNorm.^2-4*tNorm+1;
    h01dot = -6*tNorm.^2+6*tNorm;
    h11dot = 3*tNorm.^2-2*tNorm;

    p(:, k) = (h00.*pRef(tIndex, :)+h10.*(tRange).*m(tIndex, :)+h01.*pRef(tPlus, :)+h11.*(tRange).*m(tPlus, :))';
    r(:, k) = ((h00dot.*pRef(tIndex, :)+h10dot.*(tRange).*m(tIndex, :)+h01dot.*pRef(tPlus, :)+...
      h11dot.*(tRange).*m(tPlus, :))')/(tRange);
  end
end
