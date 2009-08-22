close all;
clear classes;
drawnow;
warning('on','all');
intwarning('off');
rand('seed',0);
randn('seed',0);

config=frameworkconfig;
H=framework(config);
while(true)
  [H,x,c]=step(H);
  
  fprintf('\n');
  fprintf('\ncost summary:');
  fprintf('\n%f',c);
  fprintf('\n');
  
%   figure;
%   px=exp(-9*c.*c);
%   px=px/norm(px);
%   display(x,'alpha',px','tmin',tmin,'tmax',tmax);
%   axis('on');
%   xlabel('North');
%   ylabel('East');
%   zlabel('Down');
end
