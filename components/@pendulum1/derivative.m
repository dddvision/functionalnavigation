function posquatdot=derivative(this,t)

[a,b]=domain(this);
v=this.data;

t(t<a|t>b)=NaN;

thetao=pi/2+0.1*bitsplit(v');

theta=thetao*exp(-this.damp*t).*cos(this.omega*t);

N=numel(t);
posquatdot=[zeros(1,N);-0.1*cos(theta);-0.1*sin(theta);-0.5*sin(theta/2);0.5*cos(theta/2);zeros(2,N)];

end
