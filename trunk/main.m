close all;
clear classes;
drawnow;
warning('on','all');
intwarning('off');
rand('seed',0);
randn('seed',0);

H=objective;
[M,v,w]=optimizer(H);
for iteration=1:1
  [M,H,v,w]=step(M,H,v,w);
end
