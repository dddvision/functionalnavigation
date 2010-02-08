classdef mainDisplay < mainDisplayConfig
  
  properties (SetAccess=private,GetAccess=private)
    hfigure
    haxes
    referenceTrajectory
  end
  
  methods (Access=public)

    function this=mainDisplay(uri)
      this.hfigure=figure;
      set(this.hfigure,'Color',this.colorBackground);
      set(this.hfigure,'Position',[0,0,this.width,this.height]);
      this.haxes=axes('Parent',this.hfigure,'Clipping','off');
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
      this.referenceTrajectory=[];
      if(nargin>0)
        [scheme,resource]=strtok(uri,':');
        if(strcmp(scheme,'matlab'))
          container=eval(resource(2:end));
          if(hasReferenceTrajectory(container))
            this.referenceTrajectory=getReferenceTrajectory(container);
          end
        end
      end
    end
    
    % Visualize a set of trajectories with optional transparency
    %
    % INPUT
    % x = trajectory instances, N-by-1
    % c = costs, double N-by-1
    %
    % OUTPUT
    % h = handles to trajectory plot elements
    function put(this,x,c,index)

      % find the minimum and maximum cost
      cMin=min(c);
      
      % text display
      fprintf('\n');
      fprintf('\ncost:');
      fprintf('\n%f',c);
      fprintf('\n');
      fprintf('\nminimum: %f',cMin);

      % clear the figure
      figure(this.hfigure);
      cla(this.haxes);
      
      % add ground truth if available
      if(~isempty(this.referenceTrajectory))
        mainDisplayIndividual(this,this.referenceTrajectory,1,this.colorReference);
      end
      
      alpha=cost2alpha(this,c);
      
      K=numel(x);
      avgPos=zeros(3,1);
      avgSiz=0;
      for k=1:K
        % highlight minimum cost trajectories in a different color
        if(c(k)==cMin)
          pos=mainDisplayIndividual(this,x(k),alpha(k),this.colorHighlight);
        else
          pos=mainDisplayIndividual(this,x(k),alpha(k),1-this.colorBackground);
        end
        
        % calculate statistics, being careful with large numbers
        siz=norm(max(pos,[],2)-min(pos,[],2));
        avgPos=avgPos+sum(pos/(size(pos,2)*K),2);
        avgSiz=avgSiz+siz/K;
      end
      
      % HACK
      avgPos=[0;1;0];
      avgSiz=2;
      
      set(this.haxes,'CameraTarget',avgPos');
      set(this.haxes,'CameraPosition',avgPos'+avgSiz*[cos(index/20),sin(index/20),0.5]);
      set(this.haxes,'XLim',avgPos(1)+avgSiz*[-0.6,0.6]);
      set(this.haxes,'YLim',avgPos(2)+avgSiz*[-0.6,0.6]);
      set(this.haxes,'ZLim',avgPos(3)+avgSiz*[-0.6,0.6]);
      
      drawnow;

      % save snapshot
      if(this.saveFigure)
        imwrite(fbuffer(this.hfigure),sprintf('%06d.png',index));
      end
    end
  end
  
  methods (Access=private)
    function alpha=cost2alpha(this,c)
      cMax=max(c);
      fitness=cMax-c;
      alpha=(fitness/max([fitness;eps])).^this.gamma;
    end
    
    function p=mainDisplayIndividual(this,x,alpha,color)  
      [tmin,tmax]=domain(x);

      assert(~isinf(tmax)); % prevent memory overflow on the following line
      t=tmin:((tmax-tmin)/this.bigSteps/this.subSteps):tmax;

      [p,q]=evaluate(x,t);

      mainDisplayPlotFrame(this,p(:,1),q(:,1),alpha); % plot first frame
      plot3(p(1,:),p(2,:),p(3,:),'Color',alpha*color+(1-alpha)*ones(1,3),'Clipping','off');
      for bs=1:this.bigSteps
        ksub=(bs-1)*this.subSteps+(1:(this.subSteps+1));
        mainDisplayPlotFrame(this,p(:,ksub(end)),q(:,ksub(end)),alpha); % plot terminating frame
      end
    end

    % Plot a triangle indicating body axes as in "the tail of an airplane"
    function mainDisplayPlotFrame(this,p,q,alpha)
      M=this.scale*Quat2Matrix(q);
      xp=p(1)+[M(1,1);0;-0.5*M(1,3)];
      yp=p(2)+[M(2,1);0;-0.5*M(2,3)];
      zp=p(3)+[M(3,1);0;-0.5*M(3,3)];
      patch(xp,yp,zp,this.colorHighlight,'FaceAlpha',alpha,'LineStyle','none','Clipping','off');
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
% hfig = handle to a MATLAB figure
%
% OUTPUT
% cdata = color image in uint8, M-by-N-by-3
function cdata = fbuffer(hfig)
  pos = get(hfig,'Position');
  
  %noanimate('save',hfig);
  
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

  %noanimate('restore',hfig);

  if( numel(cdata)>(pos(3)*pos(4)*3) )
   cdata=cdata(1:pos(4),1:pos(3),:);
  end
end
