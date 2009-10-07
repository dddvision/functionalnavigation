classdef middleburyData < multiSensor

  properties (GetAccess=private,SetAccess=private)
    sensors
    names
  end

  methods (Access=public)
    function this=middleburyData
      this.sensors{1}=middleburyData.cameraSim1;
      this.names{1}='CAMERA';
    end
    
    function list=listSensors(this,type)
      assert(isa(type,'char'));
      list=uint32([]);
      for k=1:numel(this.sensors)
        if(isa(this.sensors{k},type))
          list=[list;uint32(k-1)];
        end
      end
    end
    
    function name=getName(this,id)
      assert(isa(id,'uint32'));
      name=this.names{id+1};
    end
        
    function obj=getSensor(this,id)
      assert(isa(id,'uint32'));
      obj=this.sensors{id+1};
    end
  end
  
end
