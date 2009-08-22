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
end
