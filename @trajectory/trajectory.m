classdef trajectory < seed
  methods (Access=protected)
    function this=trajectory
    end
  end
  methods (Abstract=true,Access=public)
    
    % Return the endpoints of the closed time domain of a trajectory
    %
    % OUTPUT
    % a = time domain lower bound
    % b = time domain upper bound
    [a,b]=domain(this);
    
    % Evaluate a single trajectory at multiple time instants
    %
    % INPUT
    % t = time in seconds, 1-by-N
    %
    % OUTPUT
    % posquat = position and quaternion at each time, 7-by-N
    %
    % NOTE
    % Axis order is forward-right-down relative to the base reference frame
    % Each time outside of the trajectory domain returns 7-by-1 NaN
    posquat=evaluate(this,t);
    
    % Evaluate time derivative of a single trajectory at multiple time instants
    %
    % INPUT
    % t = time in seconds, 1-by-N
    %
    % OUTPUT
    % posquatdot = position and quaternion derivative at each time, 7-by-N
    %
    % NOTE
    % Axis order is forward-right-down relative to the base reference frame
    % Each time outside of the trajectory domain returns 7-by-1 NaN
    posquatdot=derivative(this,t);
    
  end
  
  methods (Abstract=false,Access=public)
    
    % Visualize a set of trajectories with optional transparency
    %
    % INPUTS
    % this = trajectory objects, 1-by-N or N-by-1
    % varargin = (optional) accepts argument pairs 'alpha', 'scale', 'color'
    %   alpha = transparency per trajectory, scalar, 1-by-N, or N-by-1
    %   scale = scale of lines to draw, scalar, 1-by-N, or N-by-1
    %   color = color of lines to draw, 1-by-3 or N-by-3
    %   tmin = time domain lower bound, scalar, 1-by-N, or N-by-1
    %   tmax = time domain lower bound, scalar, 1-by-N, or N-by-1
    %
    % OUTPUTS
    % h = handles to trajectory plot elements
    %
    % NOTE
    % TODO: make sure inputs can be either row or column vectors
    function h=display(this,varargin)
      hfigure=gcf;
      set(hfigure,'color',[1,1,1]);
      haxes=gca;
      set(haxes,'Units','normalized');
      set(haxes,'Position',[0,0,1,1]);
      set(haxes,'DataAspectRatio',[1,1,1]);
      axis(haxes,'off');

      K=numel(this);

      alpha=trajectory_display_getparam('alpha',1/K,K,varargin{:});
      scale=trajectory_display_getparam('scale',0.002,K,varargin{:});
      color=trajectory_display_getparam('color',[0,0,0],K,varargin{:});
      tmin=trajectory_display_getparam('tmin',-inf,K,varargin{:});
      tmax=trajectory_display_getparam('tmax',inf,K,varargin{:});

      h=[];
      for k=1:K
        [a,b]=domain(this(k));
        tmink=max(tmin(k),a);
        tmaxk=min(tmax(k),b);
        h=[h,trajectory_display_individual(this(k),alpha(k),scale(k),color(k,:),tmink,tmaxk)];
      end
    end
    
  end
end
