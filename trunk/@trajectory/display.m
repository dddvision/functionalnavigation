% Visualize a set of trajectories with optional transparency
%
% INPUTS
% x = trajectory objects, 1-by-N or N-by-1
% varargin = (optional) accepts argument pairs 'alpha', 'scale', 'color'
%   alpha = transparency per trajectory, scalar, 1-by-N, or N-by-1
%   scale = scale of lines to draw, scalar, 1-by-N, or N-by-1
%   color = color of lines to draw, 1-by-3 or N-by-3
%
% OUTPUTS
% h = handles to trajectory plot elements


function h=display(x,varargin)

hfigure=gcf;
set(hfigure,'color',[1,1,1]);
haxes=axes('parent',hfigure);
set(haxes,'DataAspectRatio',[1,1,1]);
axis(haxes,'off');

K=numel(x);

alpha=trajectory_display_getalpha(K,varargin{:});
scale=trajectory_display_getscale(K,varargin{:});
color=trajectory_display_getcolor(K,varargin{:});

h=[];
for k=1:K
  h=[h,trajectory_display_individual(x(k),alpha(k),scale(k),color(k,:))];
end

return;


function h=trajectory_display_individual(x,alpha,scale,color)
h=[];

bigsteps=5;
substeps=10;

[a,b]=domain(x);
t=a:((b-a)/bigsteps/substeps):b;

p=evalPosition(x,t);
q=evalQuaternion(x,t);

h=[h,trajectory_display_plotframe(p(:,1),q(:,1),alpha,scale,color)]; % plot first frame
for bs=1:bigsteps
  ksub=(bs-1)*substeps+(1:(substeps+1));
  h=[h,trajectory_display_plotline(p(1,ksub),p(2,ksub),p(3,ksub),alpha,scale,color)]; % plot line segments
  h=[h,trajectory_display_plotframe(p(:,ksub(end)),q(:,ksub(end)),alpha,scale,color)]; % plot terminating frame
end

return;


function alpha=trajectory_display_getalpha(K,varargin)
alpha=repmat(1/K,[K,1]);
N=numel(varargin);
for n=1:N
  if( strcmp(varargin{n},'alpha') )
    if( n==N )
      error('optional inputs must be property/value pairs');
    end
    alpha=varargin{n+1};
    if( ~isa(alpha,'double') )
      error('values for alpha must be doubles');
    end
    if( numel(alpha)~=K )
      alpha=repmat(alpha(1),[K,1]);
    end
  end    
end
return;


function scale=trajectory_display_getscale(K,varargin)
scale=repmat(0.001,[K,1]);
N=numel(varargin);
for n=1:N
  if( strcmp(varargin{n},'scale') )
    if( n==N )
      error('optional inputs must be property/value pairs');
    end
    scale=varargin{n+1};
    if( ~isa(scale,'double') )
      error('values for scale must be doubles');
    end
    if( numel(scale)~=K )
      scale=repmat(scale(1),[K,1]);
    end
  end    
end
return;


function color=trajectory_display_getcolor(K,varargin)
color=zeros(K,3);
N=numel(varargin);
for n=1:N
  if( strcmp(varargin{n},'color') )
    if( n==N )
      error('optional inputs must be property/value pairs');
    end
    color=varargin{n+1};
    if( ~isa(color,'double') )
      error('values for color must be doubles, 1-by-3 or N-by-3');
    end
    if( size(scale,1)~=K )
      color=repmat(color(1,:),[K,1]);
    end
  end    
end
return;


function h=trajectory_display_plotframe(p,q,alpha,scale,color)
h=[];
M=scale*Quat2Matrix(q);
xp=p(1)+[0;10*M(1,1);5*M(1,3)];
yp=p(2)+[0;10*M(2,1);5*M(2,3)];
zp=p(3)+[0;10*M(3,1);5*M(3,3)];
h=[h,patch(xp,yp,zp,[1-color(1),color(2:3)],'FaceAlpha',alpha,'LineStyle','none')];
return;


function h=trajectory_display_plotline(x,y,z,alpha,scale,color)
persistent xo yo zo
if(isempty(xo))
  xo=[0,0;1,1;1,1;0,0];
  yo=[ 1,-1; 1,-1;-1, 1;-1, 1]/sqrt(2);
  zo=[ 1, 1; 1, 1;-1,-1;-1,-1]/sqrt(2);
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
      h=[h,patch(xp,yp,zp,color,'FaceAlpha',alpha,'LineStyle','none')];
    end
    a=b;
  end
end
return;
