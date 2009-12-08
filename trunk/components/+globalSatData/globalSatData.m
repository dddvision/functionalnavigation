% Simulated measurements from the global sat bu-1** gps sensor
classdef globalSatData < globalSatData.globalSatDataConfig & dataContainer

  properties (GetAccess=private,SetAccess=private)
    sensors
    names
    hasRef
    bodyRef
  end

  methods (Access=public)
    function this=globalSatData
      this.sensors{1}=globalSatData.gpsSim;
      this.names{1}='GPS';
      this.hasRef=true;
      this.bodyRef=globalSatData.bodyReference;
    end
    
    function list=listSensors(this,type)
      assert(isa(type,'char'));
      K=numel(this.sensors);
      flag=false(K,1);
      for k=1:K
        if(isa(this.sensors{k},type))
          flag(k)=true;
        end
      end
      list=uint32(find(flag)-1);
    end
    
    function name=getSensorName(this,id)
      assert(isa(id,'uint32'));
      name=this.names{id+1};
    end
        
    function obj=getSensor(this,id)
      assert(isa(id,'uint32'));
      obj=this.sensors{id+1};
    end
    
    function flag=hasReferenceTrajectory(this)
      flag=this.hasRef;
    end
    
    function x=getReferenceTrajectory(this)
      x=this.bodyRef;
    end
  end
  
end
