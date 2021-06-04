classdef DemoDisplay < DemoConfig & handle
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  
  properties (Constant = true, GetAccess = private)
    gamma = 2; % (2) nonlinearity of trajectory transparency
    bigSteps = 10; % (10) number of body frames per trajectory
    subSteps = 10; % (10) number of line segments between body frames
    colorBackground = [1, 1, 1]; % ([1, 1, 1]) color of figure background
    colorHighlight = [1, 0, 0]; % ([1, 0, 0]) color of objects to emphasize
    colorReference = [0, 1, 0]; % ([0, 1, 0]) color of reference objects 
  end
  
  properties (SetAccess = private, GetAccess = private)
    hfigure
    haxes
    index
    tRef
    pRef
    qRef
    xDefault
  end
  
  methods (Access = public, Static = true)

    function this = DemoDisplay(initialTime, uri)
      if(this.textOnly)
        return;
      end
      
      this.hfigure = figure;
      set(this.hfigure, 'Color', this.colorBackground);
      set(this.hfigure, 'Units', 'pixels');
      set(this.hfigure, 'Position', [0, 0, this.width, this.height]);
      this.haxes = axes('Parent', this.hfigure, 'Clipping', 'off');
      set(this.haxes, 'Box', 'on');
      set(this.haxes, 'Projection', 'Perspective');
      set(this.haxes, 'Units', 'normalized');
      set(this.haxes, 'DataAspectRatio', [1, 1, 1]);
      set(this.haxes, 'Position', [0, 0, 1, 1]);
      set(this.haxes, 'CameraTargetMode', 'manual');
      set(this.haxes, 'CameraPositionMode', 'manual');
      set(this.haxes, 'XLimMode', 'manual');
      set(this.haxes, 'YLimMode', 'manual');
      set(this.haxes, 'ZLimMode', 'manual');
      set(this.haxes, 'Visible', 'on');
      set(this.haxes, 'NextPlot', 'add');
      this.index = uint32(0);
      
      this.xDefault = tom.DynamicModel.create('tom', initialTime, uri);
      
      this.tRef = [];
      this.pRef = [];
      this.qRef = [];

      if(nargin>0)
        if(~strncmp(uri, 'hidi:', 5))
          error('URI scheme not recognized');
        end
        container = hidi.DataContainer.create(uri(6:end), initialTime);
        if(hasReferenceTrajectory(container))
          xRef = getReferenceTrajectory(container);
          this.tRef = this.generateSampleTimes(xRef);
          poseRef = xRef.evaluate(this.tRef);
          this.pRef = cat(2, poseRef.p);
          this.qRef = cat(2, poseRef.q);
        end
      end
    end
  end
  
  methods (Access = public)
    % Visualize a set of trajectories with optional transparency
    %
    % INPUT
    % x  =  trajectory instances,  tom.Trajectory N-by-1
    % c  =  costs,  double N-by-1
    function put(this, x, c)
      this.index = this.index+uint32(1);
      
      % fill missing arguments with defaults
      if(nargin<3)
        c=0;
      end
      if(nargin<2)
        x = this.xDefault;
      end

      % handle case of no trajectories
      K = numel(x);
      if(K<1)
        return;
      end
      
      % compute minimium cost
      costBest = min(c);
      kBest = find(c==costBest, 1, 'first');
      alpha = this.cost2alpha(c);
      
      % text display
      fprintf('\n');
      fprintf('\nindex: %d', this.index);
      fprintf('\ncost(%d): %0.6f', [1:numel(c); c']);
      fprintf('\nbest(%d): %0.6f', kBest, costBest);
      
      if(this.textOnly)
        return;
      end
      
      % generate sample times assuming all trajectories have the same domain
      t = this.generateSampleTimes(x(1));
        
      % clear the figure
      figure(this.hfigure);
      cla(this.haxes);
        
      % evaluate the best trajectory
      k = kBest;
      poseBest = x(k).evaluate(t);
      pBest = cat(2, poseBest.p);
      qBest = cat(2, poseBest.q);

      % compute scene parameters from best trajectory or ground truth if available
      if(isempty(this.pRef))
        [origin, avgSiz, avgPos, cameraPosition] = computeScene(pBest, this.index);
        summaryText = sprintf('cost = %0.6f', costBest);
      else
        [origin, avgSiz, avgPos, cameraPosition] = computeScene(this.pRef, this.index);
        pDif = pBest-this.pRef; % position comparison
        pDif = sqrt(sum(pDif.*pDif, 1));
        qDif = acos(sum(qBest.*this.qRef, 1)); % quaternion comparison
        pTwoNorm = twoNorm(pDif);
        pInfNorm = infNorm(pDif);
        qTwoNorm = twoNorm(qDif);
        qInfNorm = infNorm(qDif);

        summaryText = sprintf(['       costBest = %0.6f\npositionTwoNorm = %0.6f\npositionInfNorm = %0.6f', ...
          '\nrotationTwoNorm = %0.6f\nrotationInfNorm = %0.6f', ...
          '\n        originX = %0.2f\n        originY = %0.2f\n        originZ = %0.2f'], ...
          costBest, pTwoNorm, pInfNorm, qTwoNorm, qInfNorm, origin(1), origin(2), origin(3));
      end
      
      % plot ground truth if available in reference color
      if(~isempty(this.pRef))
        this.plotIndividual(origin, this.pRef, this.qRef, avgSiz, 1, this.colorReference, 'LineWidth', 1);
      end
        
      % plot best trajectory in a highlight color
      this.plotIndividual(origin, pBest, qBest, avgSiz, alpha(k), this.colorHighlight, 'LineWidth', 1);
      
      % plot other trajectories in background contrast color
      if(~this.bestOnly)
        for k = 1:K
          if(k~=kBest)
            posek = x(k).evaluate(t);
            pk = cat(2, posek.p);
            qk = cat(2, posek.q);
            this.plotIndividual(origin, pk, qk, avgSiz, alpha(k), 1-this.colorBackground, 'LineWidth', 1);
          end
        end
      end
      
      % set axes properties being careful with large numbers
      text(avgPos(1), avgPos(2), avgPos(3)+avgSiz, summaryText, 'FontName', 'Courier', 'FontSize', 9);
      set(this.haxes, 'CameraTarget', avgPos');
      set(this.haxes, 'CameraPosition', cameraPosition);
      set(this.haxes, 'XLim', avgPos(1)+avgSiz*[-1, 1]);
      set(this.haxes, 'YLim', avgPos(2)+avgSiz*[-1, 1]);
      set(this.haxes, 'ZLim', avgPos(3)+avgSiz*[-1, 1]);
      drawnow;

      % save snapshot
      if(this.saveFigure)
        imwrite(fbuffer(this.hfigure), sprintf('%06d.png', this.index));
      end
    end
  end
  
  methods (Access = private)
    function alpha = cost2alpha(this, c)
      if(numel(c)==1)
        alpha = 1;
      else
        cMax = max(c);
        fitness = cMax-c;
        alpha = (fitness/max([fitness; eps])).^this.gamma;
      end
    end
    
    function t = generateSampleTimes(this, x)
      assert(numel(x)==1);
      interval = x.domain();
      tmin = interval.first;
      tmax = interval.second;
      if(~isempty(this.tRef))
        tmin = max(tmin, this.tRef(1));
        tmax = min(tmax, this.tRef(end));
      end
      if(tmin==tmax)
        t = repmat(tmin, [1, this.bigSteps*this.subSteps+1]);
      else
        tmax(isinf(tmax)) = tmin+this.infinity; % prevent NaN
        t = tmin:((tmax-tmin)/this.bigSteps/this.subSteps):tmax;
      end
    end
    
    function plotIndividual(this, origin, p, q, scale, alpha, color, varargin)
      p = p-repmat(origin, [1, size(p, 2)]);
      plot3(p(1, :), p(2, :), p(3, :), 'Color', alpha*color+(1-alpha)*ones(1, 3), 'Clipping', 'off', varargin{:});
      this.plotFrame(p(:, 1), q(:, 1), scale, alpha); % plot first frame
      for bs = 1:this.bigSteps
        ksub = (bs-1)*this.subSteps+(1:(this.subSteps+1));
        this.plotFrame(p(:, ksub(end)), q(:, ksub(end)), scale, alpha);
      end
    end

    % Plot a triangle indicating body axes as in "the tail of an airplane"
    function plotFrame(this, p, q, scale, alpha)
      M = (0.05*scale)*tom.Rotation.quatToMatrix(q);
      xp = p(1)+[M(1, 1); 0; -0.5*M(1, 3)];
      yp = p(2)+[M(2, 1); 0; -0.5*M(2, 3)];
      zp = p(3)+[M(3, 1); 0; -0.5*M(3, 3)];
      patch(xp, yp, zp, this.colorHighlight, 'FaceAlpha', alpha, 'LineStyle', 'none', 'Clipping', 'off');
    end
  end
  
end

function [origin, avgSiz, avgPos, cameraPosition] = computeScene(pScene, index)
  origin = pScene(:, 1);
  avgPos = sum(pScene/size(pScene, 2), 2)-origin;
  avgSiz = twoNorm(max(pScene, [], 2)-min(pScene, [], 2));
  if(avgSiz<eps)
    avgSiz = 1;
  end
  cameraPosition = avgPos'+avgSiz*[8*cos(double(index)/30), 8*sin(double(index)/30), 4];
end

function y = twoNorm(x)
  y = sqrt(sum(x.*x)/numel(x));
end

function y = infNorm(x)
  y = max(abs(x));
end

% Captures a figure via an offscreen buffer
%
% INPUT
% hfig = handle to a MATLAB figure
%
% OUTPUT
% cdata = color image in uint8,  M-by-N-by-3
function cdata = fbuffer(hfig)
  pos = get(hfig, 'Position');
  
  %noanimate('save', hfig);
  
  gldata = opengl('data');
  if( strcmp(gldata.Renderer, 'None') )
   mode = get(hfig, 'PaperPositionMode');
   set(hfig, 'PaperPositionMode', 'auto', 'InvertHardcopy', 'off');
   cdata = hardcopy(hfig, '-dzbuffer', '-r0');
   set(hfig, 'PaperPositionMode', mode);
  else
   sppi = get(0, 'ScreenPixelsPerInch');
   ppos = get(hfig, 'PaperPosition');
   pos(1:2) = 0;
   set(hfig, 'PaperPosition', pos./sppi);
   cdata = hardcopy(hfig, '-dopengl', ['-r', num2str(round(sppi))]);
   set(hfig, 'PaperPosition', ppos);
  end

  %noanimate('restore', hfig);

  if( numel(cdata)>(pos(3)*pos(4)*3) )
   cdata = cdata(1:pos(4), 1:pos(3), :);
  end
end
