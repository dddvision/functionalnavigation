% Omar: test commit 7/14/2009;
% Hey Prince, what's up?

close all;
clear classes;
drawnow;
warning('on','all');
intwarning('off');
rand('seed',0);
randn('seed',0);

H=objective;
[v,w]=init(H);
m=optimizer;
[m,H,v,w]=step(m,H,v,w);
