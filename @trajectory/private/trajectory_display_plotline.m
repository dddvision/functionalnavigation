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
end
