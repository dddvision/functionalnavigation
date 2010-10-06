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
          else
            tangentPose(n) = tangent(this, interval.second);
            tangentPose(n).p = tangentPose(n).p+tangentPose(n).r*(t(n)-interval.second);
          end
        end
      end
    end
  end
  
end

% Cardinal Spline interpolation function
%
% INPUT
% t = time index of pts, double 1-by-N
% pts = points in M dimensions to be interpolated, double M-by-N
% test_t = times at which to interpolate, double 1-by-K
% c = (default 0) tension parameter, double scalar
%
% NOTES
% The default tension parameter yields a Catman Hull spline
function [pos, posdot] = cardinalSpline(t, pts, test_t, c)

  if(nargin<4)
    c = 0;
  end
  
  pts = pts';
  D = size(pts, 2);
  Ntest = numel(test_t);
  pos = zeros(D, Ntest);
  posdot = zeros(D, Ntest);
  
  if(Ntest==0)
    return;
  end
  
  Npts = size(pts, 1);
  
  if(Npts<2)
    error('At least two points are required to interpolate');
  end
  
  % compute the slopes at each given point
  wt = (1-c)./2;
  m = zeros(size(pts));
  for dim = 1:size(pts, 2)
    for indx = 2:(Npts-1)
      m(indx, :) = wt*(pts(indx+1, :)-pts(indx-1, :));
    end
  end
  m(1, :) = 2*wt*(pts(2, :)-pts(1, :));
  m(end, :) = 2*wt*(pts(end, :)-pts(end-1, :));
  
  % interpolate
  for indx = 1:Ntest
    t_indx = find(test_t(indx)>=t,1,'last');

    if(isempty(t_indx))
      t_indx = 1;
    end

    if(t_indx==Npts)
      t_indx = Npts-1;
    end

    t_range = t(t_indx+1)-t(t_indx);
    curr_t = (test_t(indx)-t(t_indx))./t_range;

    h00 = 2*curr_t.^3-3*curr_t.^2+1;
    h10 = curr_t.^3-2*curr_t.^2+curr_t;
    h01 = -2*curr_t.^3+3*curr_t.^2;
    h11 = curr_t.^3-curr_t.^2;

    h00dot = 6*curr_t.^2-6*curr_t;
    h10dot = 3*curr_t.^2-4*curr_t+1;
    h01dot = -6*curr_t.^2+6*curr_t;
    h11dot = 3*curr_t.^2-2*curr_t;

    pos(:, indx) = (h00.*pts(t_indx, :) + h10.*m(t_indx, :) + ...
      h01.*pts(t_indx+1, :) + h11.*m(t_indx+1, :))';
    posdot(:, indx) = (h00dot.*pts(t_indx, :) + h10dot.*m(t_indx, :) + ...
      h01dot.*pts(t_indx+1, :) + h11dot.*m(t_indx+1, :))';
  end
end
