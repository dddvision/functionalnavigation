classdef Sensor < handle
  
  methods (Abstract=true,Access=public)
    refresh(this);
    flag=hasData(this);
    na=first(this);
    nb=last(this);
    time=getTime(this,n);
  end
  
end
