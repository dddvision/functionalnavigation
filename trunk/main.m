close all;
clear classes;
drawnow;
warning('on','all');
intwarning('off');
rand('seed',0);
randn('seed',0);

thisFrameworkConfig=frameworkConfig;
thisFramework=framework(thisFrameworkConfig);

while(true)
  [thisFramework,xEstimate,cost,costPotential]=step(thisFramework);
  
  fprintf('\n');
  fprintf('\ncostPotential: %f',costPotential);
  fprintf('\ncost:');
  fprintf('\n%f',cost);
  fprintf('\n');
  
%   figure;
%   px=exp(-9*(cost.*cost));
%   px=px/norm(px);
%   display(xEstimate,'alpha',px');
%   axis('on');
%   xlabel('North');
%   ylabel('East');
%   zlabel('Down');
end
