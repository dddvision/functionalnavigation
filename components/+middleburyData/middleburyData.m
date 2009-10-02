classdef middleburyData < multiSensor

  properties (GetAccess=private,SetAccess=private)
    sensor
  end
  
  methods (Access=public)
    function this=middleburyData
      this.sensor=middleburyData.cameraSim1;
    end
      
    function list=listSensors(this,type)
      if(isa(this.sensor(1),type))
        list=uint32(0);
      else
        list=uint32([]);
      end
    end
    
    function name=getName(this,id)
      if(id~=0)
        error('invalid id');
      end
      name=getName(this.sensor);
    end
    
    function obj=getSensor(this,id)
      if(id~=0)
        error('invalid id');
      end
      obj=this.sensor;
    end
  end
  
end
