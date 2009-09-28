% Interpret error parameters to produce a camera focal length


function rho=getFocalScale(this)
% HACK: this function should be a part of sensor configuration
scalemax=0.05;

B=numel(this.focalPerturbation);
w=reshape(this.focalPerturbation,[1,B]);
dec=bin2dec(num2str(w));
z=2*dec/(2^B-1)-1;

rho=(1+scalemax*z);
end
