classdef mainDisplay < mainDisplayConfig
  
  properties (SetAccess=private,GetAccess=private)
    hfigure
    haxes
    hdata
  end
  
  methods (Access=public)

    function this=mainDisplay
      this.hfigure=figure;
      set(this.hfigure,'Color',[1,1,1]);
      set(this.hfigure,'Position',[0,0,600,600]);
      this.haxes=axes('Parent',this.hfigure);
      xlabel(this.haxes,'ECEF_X');
      ylabel(this.haxes,'ECEF_Y');
      zlabel(this.haxes,'ECEF_Z');
      set(this.haxes,'Units','normalized');
      set(this.haxes,'DataAspectRatio',[1,1,1]);
      set(this.haxes,'Position',[0,0,1,1]);
      set(this.haxes,'CameraTargetMode','manual');
      set(this.haxes,'CameraPositionMode','manual');
      set(this.haxes,'XLimMode','manual');
      set(this.haxes,'YLimMode','manual');
      set(this.haxes,'ZLimMode','manual');
      set(this.haxes,'Visible','off');
      set(this.haxes,'NextPlot','add');
      this.hdata=[];
    end
    
    % Visualize a set of trajectories with optional transparency
    %
    % INPUT
    % x = trajectory instances, 1-by-N or N-by-1
    % c = costs, double 1-by-N or N-by-1
    %
    % OUTPUT
    % h = handles to trajectory plot elements
    function put(this,x,c,index)

      % find the minimum and maximum cost
      cMin=min(c);
      cMax=max(c);
      
      % text display
      fprintf('\n');
      fprintf('\ncost:');
      fprintf('\n%f',c);
      fprintf('\n');
      fprintf('\nminimum: %f',cMin);
      
      K=numel(x);
      fitness=cMax-c;
      if( any(fitness>eps) )
        px=reshape((fitness/max(fitness)).^this.gamma,[K,1]);
      else
        px=zeros(K,1);
      end
      [alpha,color]=mainDisplayGetAllSettings(K,'alpha',px);

      figure(this.hfigure);
      cla(this.haxes);
      avgPos=zeros(3,1);
      avgSiz=0;
      for k=1:K
        % highlight minimum cost trajectories in a different color
        if(c(k)==cMin)
          colork=[1,0,0];
        else
          colork=color(k,:);
        end
        pos=mainDisplayIndividual(x(k),alpha(k),colork);
        
        % calculate statistics, being careful with large numbers
        siz=norm(max(pos,[],2)-min(pos,[],2));
        avgPos=avgPos+sum(pos/(size(pos,2)*K),2);
        avgSiz=avgSiz+siz/K;
      end
      set(this.haxes,'CameraTarget',avgPos');
      set(this.haxes,'CameraPosition',avgPos'+avgSiz*[1,1,-1]);
      set(this.haxes,'XLim',avgPos(1)+avgSiz*[-0.5,0.5]);
      set(this.haxes,'YLim',avgPos(2)+avgSiz*[-0.5,0.5]);
      set(this.haxes,'ZLim',avgPos(3)+avgSiz*[-0.5,0.5]);
      set(this.haxes,'Visible','on');
      drawnow;

      % save snapshot
      if(this.saveFigure)
        imwrite(fbuffer(this.hfigure),sprintf('%06d.png',index));
      end
    end
    
  end
  
end


% varargin = (optional) accepts argument pairs 'alpha', 'scale', 'color'
%   alpha = transparency per trajectory, scalar 1-by-N or N-by-1
%   color = color of lines to draw, 1-by-3 or N-by-3
%   scale = thickness of lines to draw, 1-by-N or N-by-1
function [alpha,color]=mainDisplayGetAllSettings(K,varargin)
  alpha=mainDisplayGetSettings('alpha',1/K,K,varargin{:});
  color=mainDisplayGetSettings('color',[0,0,0],K,varargin{:});
end


function p=mainDisplayIndividual(x,alpha,color)  
  [tmin,tmax]=domain(x);
  tmax=min(tmax,tmin+10);

  bigsteps=10;
  substeps=10;

  t=tmin:((tmax-tmin)/bigsteps/substeps):tmax;

  [p,q]=evaluate(x,t);
  
  scale=0.001*norm(max(p(:,1:substeps:end),[],2)-min(p(:,1:substeps:end),[],2));

  mainDisplayPlotFrame(p(:,1),q(:,1),alpha,scale,color); % plot first frame
  plot3(p(1,:),p(2,:),p(3,:),'Color',alpha*color+(1-alpha)*ones(1,3),'Clipping','off');
  for bs=1:bigsteps
    ksub=(bs-1)*substeps+(1:(substeps+1));
    mainDisplayPlotFrame(p(:,ksub(end)),q(:,ksub(end)),alpha,scale,color); % plot terminating frame
  end
end


% Plot a red triangle indicating body axes as in "the tail of an airplane"
function mainDisplayPlotFrame(p,q,alpha,scale,color)
  M=scale*Quat2Matrix(q);

  xp=p(1)+[10*M(1,1);0;-5*M(1,3)];
  yp=p(2)+[10*M(2,1);0;-5*M(2,3)];
  zp=p(3)+[10*M(3,1);0;-5*M(3,3)];
  patch(xp,yp,zp,[1-color(1),color(2:3)],'FaceAlpha',alpha,'LineStyle','none','Clipping','off');
end

function param=mainDisplayGetSettings(str,default,K,varargin)
  param=repmat(default,[K,1]);
  N=numel(varargin);
  for n=1:N
    if( strcmp(varargin{n},str) )
      if( n==N )
        error('optional inputs must be property/value pairs');
      end
      param=varargin{n+1};
      if( ~isa(param,'double') )
        error('values optional inputs be doubles, 1-by-2 or N-by-2');
      end
      if( size(param,1)~=K )
        param=repmat(param(1,:),[K,1]);
      end
    end
  end
end


% Converts a quaternion to a rotation matrix
%
% Q = body orientation in quaternion <scalar,vector> form, double 4-by-1
% R = matrix that represents the body frame in the world frame, double 3-by-3
function R=Quat2Matrix(Q)
  q1=Q(1);
  q2=Q(2);
  q3=Q(3);
  q4=Q(4);

  q11=q1*q1;
  q22=q2*q2;
  q33=q3*q3;
  q44=q4*q4;

  q12=q1*q2;
  q23=q2*q3;
  q34=q3*q4;
  q14=q1*q4;
  q13=q1*q3;
  q24=q2*q4;

  R=zeros(3,3);

  R(1,1) = q11 + q22 - q33 - q44;
  R(2,1) = 2*(q23 + q14);
  R(3,1) = 2*(q24 - q13);

  R(1,2) = 2*(q23 - q14);
  R(2,2) = q11 - q22 + q33 - q44;
  R(3,2) = 2*(q34 + q12);

  R(1,3) = 2*(q24 + q13);
  R(2,3) = 2*(q34 - q12);
  R(3,3) = q11 - q22 - q33 + q44;
end


% Captures a figure via an offscreen buffer
%
% INPUT
% hfig = handle to a matlab figure
%
% OUTPUT
% cdata = color image in uint8, M-by-N-by-3
function cdata = fbuffer(hfig)
  pos = get(hfig,'Position');
  
  noanimate('save',hfig);
  
  gldata = opengl('data');
  if( strcmp(gldata.Renderer,'None') )
   mode = get(hfig,'PaperPositionMode');
   set(hfig,'PaperPositionMode','auto','InvertHardcopy','off');
   cdata = hardcopy(hfig,'-dzbuffer','-r0');
   set(hfig,'PaperPositionMode',mode);
  else
   sppi = get(0,'ScreenPixelsPerInch');
   ppos = get(hfig,'PaperPosition');
   pos(1:2) = 0;
   set(hfig,'PaperPosition',pos./sppi);
   cdata = hardcopy(hfig,'-dopengl',['-r',num2str(round(sppi))]);
   set(hfig,'PaperPosition',ppos);
  end

  noanimate('restore',hfig);

  if( numel(cdata)>(pos(3)*pos(4)*3) )
   cdata=cdata(1:pos(4),1:pos(3),:);
  end
end
