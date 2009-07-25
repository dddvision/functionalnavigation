% Visualize a set of trajectories with optional transparency
%
% INPUTS
% x = trajectory objects, 1-by-N or N-by-1
% varargin = (optional) accepts argument pairs 'alpha', 'scale', 'color'
%   alpha = transparency per trajectory, scalar, 1-by-N, or N-by-1
%   scale = scale of lines to draw, scalar, 1-by-N, or N-by-1
%   color = color of lines to draw, 1-by-3 or N-by-3
%   tmin = time domain lower bound, scalar, 1-by-N, or N-by-1
%   tmax = time domain lower bound, scalar, 1-by-N, or N-by-1
%
% OUTPUTS
% h = handles to trajectory plot elements


% TODO: make sure inputs can be either row or column vectors
function h=display(x,varargin)

hfigure=gcf;
set(hfigure,'color',[1,1,1]);
haxes=gca;
set(haxes,'Units','normalized');
set(haxes,'Position',[0,0,1,1]);
set(haxes,'DataAspectRatio',[1,1,1]);
axis(haxes,'off');

K=numel(x);

alpha=trajectory_display_getparam('alpha',1/K,K,varargin{:});
scale=trajectory_display_getparam('scale',0.002,K,varargin{:});
color=trajectory_display_getparam('color',[0,0,0],K,varargin{:});
tmin=trajectory_display_getparam('tmin',-inf,K,varargin{:});
tmax=trajectory_display_getparam('tmax',inf,K,varargin{:});

h=[];
for k=1:K
  [a,b]=domain(x(k));
  tmink=max(tmin(k),a);
  tmaxk=min(tmax(k),b);
  h=[h,trajectory_display_individual(x(k),alpha(k),scale(k),color(k,:),tmink,tmaxk)];
end

return;


function h=trajectory_display_individual(x,alpha,scale,color,tmin,tmax)
h=[];

bigsteps=10;
substeps=10;

t=tmin:((tmax-tmin)/bigsteps/substeps):tmax;

p=evaluatePosition(x,t);
q=evaluateQuaternion(x,t);

h=[h,trajectory_display_plotframe(p(:,1),q(:,1),alpha,scale,color)]; % plot first frame
for bs=1:bigsteps
  ksub=(bs-1)*substeps+(1:(substeps+1));
  h=[h,trajectory_display_plotline(p(1,ksub),p(2,ksub),p(3,ksub),alpha,scale,color)]; % plot line segments
  h=[h,trajectory_display_plotframe(p(:,ksub(end)),q(:,ksub(end)),alpha,scale,color)]; % plot terminating frame
end

return;


function param=trajectory_display_getparam(str,default,K,varargin)
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
return;


% Plot a red triangle indicating the forward and up directions
function h=trajectory_display_plotframe(p,q,alpha,scale,color)
h=[];
M=scale*Quat2Matrix(q);

% xp=p(1)+[0;5*M(1,2)];
% yp=p(2)+[0;5*M(2,2)];
% zp=p(3)+[0;5*M(3,2)];
% rc=[1-color(1),color(2),color(3)];
% h=[h,trajectory_display_plotline(xp,yp,zp,alpha,scale,rc)];
% 
% xp=p(1)+[0;5*M(1,3)];
% yp=p(2)+[0;5*M(2,3)];
% zp=p(3)+[0;5*M(3,3)];
% gc=[color(1),1-color(2),color(3)];
% h=[h,trajectory_display_plotline(xp,yp,zp,alpha,scale,gc)];

xp=p(1)+[10*M(1,1);0;-5*M(1,3)];
yp=p(2)+[10*M(2,1);0;-5*M(2,3)];
zp=p(3)+[10*M(3,1);0;-5*M(3,3)];
h=[h,patch(xp,yp,zp,[1-color(1),color(2:3)],'FaceAlpha',alpha,'LineStyle','none','Clipping','off')];
return;


function h=trajectory_display_plotline(x,y,z,alpha,scale,color)
persistent xo yo zo
if(isempty(xo))
%   xo=[0,0,0;1,1,1;1,1,1;0,0,0];
%   yo=[-1, 1, 0;-1, 1, 0; 1, 0,-1; 1, 0,-1]*sqrt(3)/2;
%   zo=[-1,-1, 2;-1,-1, 2;-1, 2,-1;-1, 2,-1]/2;
  xo=[0,0,0,0;1,1,1,1;1,1,1,1;0,0,0,0];
  yo=[-1, 1, 1,-1;-1, 1, 1,-1; 1, 1,-1,-1; 1, 1,-1,-1]/sqrt(2);
  zo=[-1,-1, 1, 1;-1,-1, 1, 1;-1, 1, 1,-1;-1, 1, 1,-1]/sqrt(2);
end
ys=scale*yo;
zs=scale*zo;
N=numel(x);
h=[];
if( N>1 )
  a=[x(1);y(1);z(1)];
  for n=2:N
    b=[x(n);y(n);z(n)];
    ab=b-a;
    d=sqrt(dot(ab,ab));
    if(d>eps)
      ab=ab/d;
      %M=Euler2Matrix([0;asin(-ab(3));atan2(ab(2),ab(1))]);
      c1=sqrt(1-ab(3)*ab(3));
      c2=sqrt(dot(ab(1:2),ab(1:2)));
      if(c2<eps)
        M=eye(3);
      else
        M=[[ab(1)*c1/c2,-ab(2)/c2,-ab(1)*ab(3)/c2]
           [ab(2)*c1/c2, ab(1)/c2,-ab(2)*ab(3)/c2]
           [      ab(3),        0,             c1]];
      end
      xs=d*xo;
      xp=a(1)+M(1,1)*xs+M(1,2)*ys+M(1,3)*zs;
      yp=a(2)+M(2,1)*xs+M(2,2)*ys+M(2,3)*zs;
      zp=a(3)+M(3,1)*xs+M(3,3)*zs;
      h=[h,patch(xp,yp,zp,color,'FaceAlpha',alpha/2,'LineStyle','none','Clipping','off')];
    end
    a=b;
  end
end
return;
