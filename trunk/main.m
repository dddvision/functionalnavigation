% Example application that uses the TOMMAS framework
function main
  % clear the workspace and the screen
  evalin('base','clear(''classes'')');
  close('all');
  drawnow;
  
  % options
  displayIncremental=false; % option to display incremental results
  numIterations=10;
  
  % check matlab version before instantiating any objects
  matlab_version=version('-release');
  if(str2double(matlab_version(1:4))<2008)
    error('requires Matlab version 2008a or greater');
  end
  
  % add component repository to the path
  componentPath=fullfile(fileparts(mfilename('fullpath')),'components');
  addpath(componentPath);
  fprintf('\npath added: %s',componentPath);

  % create an instance of the trajectory optimization manager
  tom=tommas;

  % optional iterations
  for k=1:numIterations
    
    % optional display
    if(displayIncremental)
      [xEst,cEst]=getResults(tom);
      mainDisplay(xEst,cEst);
    end

    % take an optimization step
    step(tom);
  end
      
  % get trajectory and cost estimates
  [xEst,cEst]=getResults(tom);

  % display trajectory and cost estimates
  mainDisplay(xEst,cEst);

  % done
  fprintf('\n');
  fprintf('\nDone');
  fprintf('\n');
end

% Visualize a set of trajectories with optional transparency
%
% INPUT
% x = trajectory instances, 1-by-N or N-by-1
% c = costs, double 1-by-N or N-by-1
%
% OUTPUT
% h = handles to trajectory plot elements
function h=mainDisplay(x,c)

  % text display
  fprintf('\n');
  fprintf('\ncost:');
  fprintf('\n%f',c);

  % nonlinearity of transparency display
  gamma=2;
  
  K=numel(x);
  fitness=max(c)-c;
  if( any(fitness>eps) )
    px=reshape((fitness/max(fitness)).^gamma,[K,1]);
  else
    px=zeros(K,1);
  end
  [alpha,color]=mainDisplayGetAllSettings(K,'alpha',px);
  
  % graphical display
  hfigure=figure;
  set(hfigure,'color',[1,1,1]);
  haxes=gca;
  axis('on');
  hold('on');
  xlabel('ECEF_X');
  ylabel('ECEF_Y');
  zlabel('ECEF_Z');
  set(haxes,'Units','normalized');
  set(haxes,'Position',[0,0,1,1]);
  set(haxes,'DataAspectRatio',[1,1,1]);
  %axis(haxes,'off');

  h=[];
  for k=1:K
    % grows in loop because number of handles is hard to determine
    h=[h,mainDisplayIndividual(x(k),alpha(k),color(k,:))];
  end
  drawnow;  
end

% varargin = (optional) accepts argument pairs 'alpha', 'scale', 'color'
%   alpha = transparency per trajectory, scalar 1-by-N or N-by-1
%   color = color of lines to draw, 1-by-3 or N-by-3
%   scale = thickness of lines to draw, 1-by-N or N-by-1
function [alpha,color]=mainDisplayGetAllSettings(K,varargin)
  alpha=mainDisplayGetSettings('alpha',1/K,K,varargin{:});
  color=mainDisplayGetSettings('color',[0,0,0],K,varargin{:});
end

function h=mainDisplayIndividual(x,alpha,color)
  h=[];
  
  [tmin,tmax]=domain(x);
  tmax=min(tmax,tmin+10);

  bigsteps=10;
  substeps=10;

  t=tmin:((tmax-tmin)/bigsteps/substeps):tmax;

  [p,q]=evaluate(x,t);
  
  scale=0.001*norm(max(p(:,1:substeps:end),[],2)-min(p(:,1:substeps:end),[],2));

  h=[h,mainDisplayPlotFrame(p(:,1),q(:,1),alpha,scale,color)]; % plot first frame
  h=[h,plot3(p(1,:),p(2,:),p(3,:),'Color',alpha*color+(1-alpha)*ones(1,3))];
  for bs=1:bigsteps
    ksub=(bs-1)*substeps+(1:(substeps+1));
    % grows in loop because number of handles is hard to determine
    h=[h,mainDisplayPlotFrame(p(:,ksub(end)),q(:,ksub(end)),alpha,scale,color)]; % plot terminating frame
  end
end

% function h=mainDisplayPlotLine(x,y,z,alpha,scale,color)
% persistent xo yo zo
%   if(isempty(xo))
%   %   xo=[0,0,0;1,1,1;1,1,1;0,0,0];
%   %   yo=[-1, 1, 0;-1, 1, 0; 1, 0,-1; 1, 0,-1]*sqrt(3)/2;
%   %   zo=[-1,-1, 2;-1,-1, 2;-1, 2,-1;-1, 2,-1]/2;
%     xo=[0,0,0,0;1,1,1,1;1,1,1,1;0,0,0,0];
%     yo=[-1, 1, 1,-1;-1, 1, 1,-1; 1, 1,-1,-1; 1, 1,-1,-1]/sqrt(2);
%     zo=[-1,-1, 1, 1;-1,-1, 1, 1;-1, 1, 1,-1;-1, 1, 1,-1]/sqrt(2);
%   end
%   ys=scale*yo;
%   zs=scale*zo;
%   
%   % halve alpha because two faces will be plotted to create each line
%   alpha=alpha/2;
%   
%   N=numel(x);
%   h=[];
%   if( N>1 )
%     a=[x(1);y(1);z(1)];
%     for n=2:N
%       b=[x(n);y(n);z(n)];
%       ab=b-a;
%       d=sqrt(dot(ab,ab));
%       if(d>eps)
%         ab=ab/d;
%         %M=Euler2Matrix([0;asin(-ab(3));atan2(ab(2),ab(1))]);
%         c1=sqrt(1-ab(3)*ab(3));
%         c2=sqrt(dot(ab(1:2),ab(1:2)));
%         if(c2<eps)
%           M=eye(3);
%         else
%           M=[[ab(1)*c1/c2,-ab(2)/c2,-ab(1)*ab(3)/c2]
%              [ab(2)*c1/c2, ab(1)/c2,-ab(2)*ab(3)/c2]
%              [      ab(3),        0,             c1]];
%         end
%         xs=d*xo;
%         xp=a(1)+M(1,1)*xs+M(1,2)*ys+M(1,3)*zs;
%         yp=a(2)+M(2,1)*xs+M(2,2)*ys+M(2,3)*zs;
%         zp=a(3)+M(3,1)*xs+M(3,3)*zs;
%         h=[h,patch(xp,yp,zp,color,'FaceAlpha',alpha,'LineStyle','none','Clipping','off')];
%       end
%       a=b;
%     end
%   end
% end

% Plot a red triangle indicating the forward and up directions
function h=mainDisplayPlotFrame(p,q,alpha,scale,color)
  h=[];
  M=scale*Quat2Matrix(q);

  % xp=p(1)+[0;5*M(1,2)];
  % yp=p(2)+[0;5*M(2,2)];
  % zp=p(3)+[0;5*M(3,2)];
  % rc=[1-color(1),color(2),color(3)];
  % h=[h,mainDisplayPlotLine(xp,yp,zp,alpha,scale,rc)];
  % 
  % xp=p(1)+[0;5*M(1,3)];
  % yp=p(2)+[0;5*M(2,3)];
  % zp=p(3)+[0;5*M(3,3)];
  % gc=[color(1),1-color(2),color(3)];
  % h=[h,mainDisplayPlotLine(xp,yp,zp,alpha,scale,gc)];

  xp=p(1)+[10*M(1,1);0;-5*M(1,3)];
  yp=p(2)+[10*M(2,1);0;-5*M(2,3)];
  zp=p(3)+[10*M(3,1);0;-5*M(3,3)];
  h=[h,patch(xp,yp,zp,[1-color(1),color(2:3)],'FaceAlpha',alpha,'LineStyle','none','Clipping','off')];
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

% Converts a set of quaternions to a set of rotation matrices.
%
% Q = body orientation states in quaternion <scalar,vector> form (4-by-n)
% R = matrices that rotate a point from the body frame to the world frame
% (3-by-3-by-n)
function R=Quat2Matrix(Q)
  n=size(Q,2);
  Q=QuatNorm(Q);

  q1=Q(1,:);
  q2=Q(2,:);
  q3=Q(3,:);
  q4=Q(4,:);

  q11=q1.*q1;
  q22=q2.*q2;
  q33=q3.*q3;
  q44=q4.*q4;

  q12=q1.*q2;
  q23=q2.*q3;
  q34=q3.*q4;
  q14=q1.*q4;
  q13=q1.*q3;
  q24=q2.*q4;

  R=zeros(3,3,n);
  if( ~isnumeric(Q) )
    R=sym(R);
  end

  R(1,1,:) = q11 + q22 - q33 - q44;
  R(2,1,:) = 2*(q23 + q14);
  R(3,1,:) = 2*(q24 - q13);

  R(1,2,:) = 2*(q23 - q14);
  R(2,2,:) = q11 - q22 + q33 - q44;
  R(3,2,:) = 2*(q34 + q12);

  R(1,3,:) = 2*(q24 + q13);
  R(2,3,:) = 2*(q34 - q12);
  R(3,3,:) = q11 - q22 - q33 + q44;
end

% Normalize each quaternion to have unit magnitude and positive first element
%
% INPUT/OUTPUT
% Q = quaternions (4-by-n)
function Q=QuatNorm(Q)
  % input checking
  if(size(Q,1)~=4)
    error('argument must be 4-by-n');
  end

  % extract elements
  q1=Q(1,:);
  q2=Q(2,:);
  q3=Q(3,:);
  q4=Q(4,:);

  % normalization factor
  n=sqrt(q1.*q1+q2.*q2+q3.*q3+q4.*q4);

  % handle negative first element and zero denominator
  s=sign(q1);
  ns=n.*s;
  ns(ns==0)=1;
  
  % normalize
  Q(1,:)=q1./ns;
  Q(2,:)=q2./ns;
  Q(3,:)=q3./ns;
  Q(4,:)=q4./ns;
end
