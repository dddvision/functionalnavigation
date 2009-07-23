% Omar: test commit 7/14/2009;
% David: Hey Prince, what's up?

close all;
clear classes;
drawnow;
warning('on','all');
intwarning('off');
rand('seed',0);
randn('seed',0);

M=optimizer;
H=objective;
[v,w]=init(H);
[M,H,v,w]=step(M,H,v,w);
