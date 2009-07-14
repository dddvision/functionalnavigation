% Omar: test commit 7/14/2009;
close all;
clear classes;
drawnow;
warning('on','all');
intwarning('off');
rand('seed',0);
randn('seed',0);

m=optimizer;
[v,w]=init(m);
F=integrator;
x=eval(F,v);
g=sensor;
s=eval(g,x,w);
