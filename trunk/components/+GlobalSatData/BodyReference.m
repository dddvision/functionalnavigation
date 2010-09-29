classdef BodyReference < GlobalSatData.GlobalSatDataConfig & tom.Trajectory
    
  properties (SetAccess=private, GetAccess=private)
    pts
    gpsTime
    zone
  end
  
  methods (Access=public)
    function this=BodyReference(initialTime)
      currdir = fileparts(mfilename('fullpath'));
      full_fname = fullfile(currdir,this.referenceTrajectoryFile);
      [this.gpsTime,lon,lat,alt,vDOP,hDOP] = textread(full_fname,'%f %f %f %f %f %f','delimiter',',');
      this.gpsTime = this.gpsTime + initialTime;
      [X,Y,Z] = GlobalSatData.lolah2ecef(lon,lat,alt);
      this.pts = [X,Y,Z];
    end
    
    function interval=domain(this)
      interval=tom.TimeInterval(tom.WorldTime(this.gpsTime(1)),tom.WorldTime(this.gpsTime(end)));
    end
    
    function pose=evaluate(this,t)
      pose(1,numel(t))=tom.Pose;
      p=cardinalSpline(this.gpsTime,this.pts,t,this.splineTension,0); 
      interval=domain(this);
      for k=find((t>=interval.first)&(t<=interval.second))
        pose(k).p=p(:,k);
        pose(k).q=[1;0;0;0];
      end
    end
    
    function tangentPose=tangent(this,t)
      tangentPose(1,numel(t))=tom.TangentPose;
      [p,r]=cardinalSpline(this.gpsTime,this.pts,t,this.splineTension,0); 
      interval=domain(this);
      for k=find((t>=interval.first)&(t<=interval.second))
        tangentPose(k).p=p(:,k);
        tangentPose(k).q=[1;0;0;0];
        tangentPose(k).r=r(:,k);
        tangentPose(k).s=[0;0;0;0];
      end
    end
  end
  
end

% Cardinal Spline interpolation function
% pts is a M x N matrix of M points
% of dimensionality N which are to be
% interpolated

% c is the tension parameter
%    c = 0 <-- Catman Hull spline
% First compute the slopes at each point
function [pos, posdot] = cardinalSpline(t, pts, test_t, c, testFlag)

Npts = size(pts,1);

if Npts < 2
  error('At least two points required in input file to define trajectory');
end

wt = (1-c)./2;
m = zeros(size(pts));
for dim = 1:size(pts,2)
  for indx = 2:(Npts-1)
    m(indx,:) = wt*(pts(indx+1,:)-pts(indx-1,:));
  end
end

m(1,:) = 2*wt*(pts(2,:)-pts(1,:));
m(end,:) = 2*wt*(pts(end,:)-pts(end-1,:));


if( ~isempty(test_t) )
  for indx = 1:length(test_t)
    % Find the t indices between which the current test_t
    % lies
    t_indx = find(test_t(indx) >= t);
    t_indx = t_indx(end);
    
    if( (isempty(t_indx)) || (t_indx==1) )
      t_indx = 1;
    end
    
    if t_indx == Npts
      t_indx = Npts-1;
    end
    
    t_range = t(t_indx+1)-t(t_indx);
    curr_t = (test_t(indx)-t(t_indx))./t_range;
    h00 = 2*curr_t.^3-3*curr_t.^2+1;
    h10 = curr_t.^3-2*curr_t^2+curr_t;
    h01 = -2*curr_t.^3+3*curr_t.^2;
    h11 = curr_t.^3-curr_t.^2;
    
    h00dot = 6*curr_t.^2-6*curr_t;
    h10dot = 3*curr_t.^2-4*curr_t;
    h01dot = -6*curr_t.^2-6*curr_t;
    h11dot = 3*curr_t.^2-2*curr_t;
    
    % TODO: preallocate pos, posdot
    pos(indx,:) = h00.*pts(t_indx,:) + h10.*m(t_indx,:) + ...
      h01.*pts(t_indx+1,:) + h11.*m(t_indx+1,:);
    posdot(indx,:) = h00dot.*pts(t_indx,:) + h10dot.*m(t_indx,:) + ...
      h01dot.*pts(t_indx+1,:) + h11dot.*m(t_indx+1,:);
    
  end
end

if testFlag == 1
  interp_pts = [ ];
  numTestPts = 100;
  % Find 100 interpolated points between pairs of points
  for count = 1:Npts-1
    t_range = t(count+1)-t(count);
    delta_t = t_range./100;
    for indx = 1:numTestPts
      curr_t = indx*delta_t./t_range;
      % basis function
      h00 = 2*curr_t.^3-3*curr_t.^2+1;
      h10 = curr_t.^3-2*curr_t^2+curr_t;
      h01 = -2*curr_t.^3+3*curr_t.^2;
      h11 = curr_t.^3-curr_t.^2;
      
      tmp_pts = h00.*pts(count,:) + h10.*m(count,:) + ...
        h01.*pts(count+1,:) + h11.*m(count+1,:);
      
      % TODO: preallocate interp_pts
      interp_pts = [interp_pts; tmp_pts];
    end
  end
  hold off
  plot(interp_pts(:,1), interp_pts(:,2),'b','linewidth',2);
  hold on;
  plot(pts(:,1), pts(:,2), 'ro','linewidth',2);
  set(gca,'ydir','reverse')
  if ~isempty(test_t)
    % TODO: check whether out_pts is defined in all cases
    plot(out_pts(:,1), out_pts(:,2), 'gp')
  end
end
end
