% Interpret error parameters to produce a camera focal length


function rho=getfocal(g,w)
% HACK: this function should be a part of sensor configuration
scalemax=0.05;

B=numel(w);
w=reshape(w,[1,B]);
dec=bin2dec(num2str(w));
z=2*dec/(2^B-1)-1;

rho=g.focal*(1+scalemax*z);
end