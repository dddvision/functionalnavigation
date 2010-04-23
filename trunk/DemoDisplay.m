classdef DemoDisplay < DemoConfig & handle
  
  properties (SetAccess=private,GetAccess=private)
    hfigure
    haxes
    tRef
    pRef
    qRef
  end
  
  methods (Access=public)

    function this=DemoDisplay(uri)
      if(this.textOnly)
        return;
      end
      
      this.hfigure=figure;
      set(this.hfigure,'Color',this.colorBackground);
      set(this.hfigure,'Units','pixels');
      set(this.hfigure,'Position',[0,0,this.width,this.height]);
      this.haxes=axes('Parent',this.hfigure,'Clipping','off');
      set(this.haxes,'Box','on');
      set(this.haxes,'Projection','Perspective');
      set(this.haxes,'Units','normalized');
      set(this.haxes,'DataAspectRatio',[1,1,1]);
      set(this.haxes,'Position',[0,0,1,1]);
      set(this.haxes,'CameraTargetMode','manual');
      set(this.haxes,'CameraPositionMode','manual');
      set(this.haxes,'XLimMode','manual');
      set(this.haxes,'YLimMode','manual');
      set(this.haxes,'ZLimMode','manual');
      set(this.haxes,'Visible','on');
      set(this.haxes,'NextPlot','add');
      
      this.tRef=[];
      this.pRef=[];
      this.qRef=[];

      if(nargin>0)
        [scheme,resource]=strtok(uri,':');
        resource=resource(2:end);
        if(strcmp(scheme,'matlab'))
          container=DataContainer.factory(resource);
          if(hasReferenceTrajectory(container))
            xRef=getReferenceTrajectory(container);
            this.tRef=generateSampleTimes(this,xRef);
            poseRef=evaluate(xRef,this.tRef);
            this.pRef=cat(2,poseRef.p);
            this.qRef=cat(2,poseRef.q);
          end
        end
      end
    end
    
    % Visualize a set of trajectories with optional transparency
    %
    % INPUT
    % x = trajectory instances, Trajectory N-by-1
    % c = costs, double N-by-1
    % index = plot index, double scalar
    function put(this,x,c,index)

      % compute minimium cost
      K=numel(x);
      costBest=min(c);
      kBest=find(c==costBest,1,'first');
      alpha=cost2alpha(this,c);
      
      % text display
      fprintf('\n');
      fprintf('\nindex: %d',index);
      fprintf('\ncost(%d): %0.6f',[1:numel(c);c']);
      fprintf('\nbest(%d): %0.6f',kBest,costBest);
      
      if(this.textOnly)
        return;
      end
      
      % generate sample times assuming all trajectories have the same domain
      t=generateSampleTimes(this,x(1));
        
      % clear the figure
      figure(this.hfigure);
      cla(this.haxes);
      
      % compute scene origin
      if(isempty(this.pRef))
        interval=domain(x(kBest));
        pose=evaluate(x(kBest),interval.first);
        origin=pose.p;
      else
        origin=this.pRef(:,1);
      end
        
      % plot trajectories and highlight the best one in a different color
      for k=1:K
        if(k==kBest)
          poseBest=evaluate(x(k),t);
          pBest=cat(2,poseBest.p);
          qBest=cat(2,poseBest.q);
          plotIndividual(this,origin,pBest,qBest,alpha(k),this.colorHighlight,'LineWidth',1.5);
        elseif(~this.bestOnly)
          posek=evaluate(x(k),t);
          pk=cat(2,posek.p);
          qk=cat(2,posek.q);
          plotIndividual(this,origin,pk,qk,alpha(k),1-this.colorBackground);
        end
      end
      
      % compare to ground truth if available
      if(isempty(this.pRef))
        pScene=pBest;
        summaryText=sprintf('cost=%0.6f',costBest);
      else
        pScene=this.pRef;
        plotIndividual(this,origin,this.pRef,this.qRef,1,this.colorReference,'LineWidth',1.5);
        pDif=pBest-this.pRef; % position comparison
        pDif=sqrt(sum(pDif.*pDif,1));
        qDif=acos(sum(qBest.*this.qRef,1)); % quaternion comparison
        pTwoNorm=twoNorm(pDif);
        pInfNorm=infNorm(pDif);
        qTwoNorm=twoNorm(qDif);
        qInfNorm=infNorm(qDif);
        
        summaryText=sprintf(['       costBest = %0.6f\npositionTwoNorm = %0.6f\npositionInfNorm = %0.6f',...
          '\nrotationTwoNorm = %0.6f\nrotationInfNorm = %0.6f',...
          '\n        originX = %0.2f\n        originY = %0.2f\n        originZ = %0.2f'],...
          costBest,pTwoNorm,pInfNorm,qTwoNorm,qInfNorm,origin(1),origin(2),origin(3));
      end
      
      % set axes properties being careful with large numbers
      avgPos=sum(pScene/numel(t),2)-origin;
      avgSiz=twoNorm(max(pScene,[],2)-min(pScene,[],2));
      text(avgPos(1),avgPos(2),avgPos(3)+avgSiz,summaryText,'FontName','Courier','FontSize',9);
      set(this.haxes,'CameraTarget',avgPos');
      cameraPosition=avgPos'+avgSiz*[8*cos(double(index)/30),8*sin(double(index)/30),4];
      set(this.haxes,'CameraPosition',cameraPosition);
      set(this.haxes,'XLim',avgPos(1)+avgSiz*[-1,1]);
      set(this.haxes,'YLim',avgPos(2)+avgSiz*[-1,1]);
      set(this.haxes,'ZLim',avgPos(3)+avgSiz*[-1,1]);
      drawnow;

      % save snapshot
      if(this.saveFigure)
        imwrite(fbuffer(this.hfigure),sprintf('%06d.png',index));
      end
    end
  end
  
  methods (Access=private)
    function alpha=cost2alpha(this,c)
      if(numel(c)==1)
        alpha=1;
      else
        cMax=max(c);
        fitness=cMax-c;
        alpha=(fitness/max([fitness;eps])).^this.gamma;
      end
    end
    
    function t=generateSampleTimes(this,x)
      assert(numel(x)==1);
      interval=domain(x);
      tmin=interval.first;
      tmax=interval.second;
      if(~isempty(this.tRef))
        tmin=max(tmin,this.tRef(1));
        tmax=min(tmax,this.tRef(end));
      end
      if(tmin==tmax)
        t=GPSTime(repmat(tmin,[1,this.bigSteps*this.subSteps+1]));
      else
        tmax(isinf(tmax))=this.infinity; % prevent NaN
        t=GPSTime(tmin:((tmax-tmin)/this.bigSteps/this.subSteps):tmax);
      end
    end
    
    function plotIndividual(this,origin,p,q,alpha,color,varargin)
      p=p-repmat(origin,[1,size(p,2)]);
      plot3(p(1,:),p(2,:),p(3,:),'Color',alpha*color+(1-alpha)*ones(1,3),'Clipping','off',varargin{:});
      plotFrame(this,p(:,1),q(:,1),alpha); % plot first frame
      for bs=1:this.bigSteps
        ksub=(bs-1)*this.subSteps+(1:(this.subSteps+1));
        plotFrame(this,p(:,ksub(end)),q(:,ksub(end)),alpha);
      end
    end

    % Plot a triangle indicating body axes as in "the tail of an airplane"
    function plotFrame(this,p,q,alpha)
      M=this.scale*Quat2Matrix(q);
      xp=p(1)+[M(1,1);0;-0.5*M(1,3)];
      yp=p(2)+[M(2,1);0;-0.5*M(2,3)];
      zp=p(3)+[M(3,1);0;-0.5*M(3,3)];
      patch(xp,yp,zp,this.colorHighlight,'FaceAlpha',alpha,'LineStyle','none','Clipping','off');
    end
  end
  
end

function y=twoNorm(x)
  y=sqrt(sum(x.*x)/numel(x));
end

function y=infNorm(x)
  y=max(abs(x));
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
