classdef sensor
  methods (Abstract)
    [a,b]=domain(this);
    c=evaluate(this,x,w,tmin,tmax);
    time=gettime(this,k);
  end
end
