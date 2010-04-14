classdef GlobalSatData < GlobalSatData.GlobalSatDataConfig & DataContainer

  properties (GetAccess=private,SetAccess=private)
    description
    sensor
    sensorDescription
    hasRef
    bodyRef
  end

  methods (Access=public)
    function this=GlobalSatData
      this.description='Simulated GPS data';
      this.sensor{1}=GlobalSatData.GpsSim;
      this.sensorDescription{1}='GlobalSat BU-xxx GPS sensor';
      this.hasRef=true;
      this.bodyRef=GlobalSatData.BodyReference;
    end
    
    function text=getDescription(this)
      text=this.description;
    end
    
    function list=listSensors(this,type)
      K=numel(this.sensor);
      flag=false(K,1);
      for k=1:K
        if(isa(this.sensor{k},type))
          flag(k)=true;
        end
      end
      list=uint32(find(flag)-1);
    end
    
    function text=getSensorDescription(this,id)
      text=this.sensorDescription{id+1};
    end
        
    function obj=getSensor(this,id)
      obj=this.sensor{id+1};
    end
    
    function flag=hasReferenceTrajectory(this)
      flag=this.hasRef;
    end
    
    function x=getReferenceTrajectory(this)
      x=this.bodyRef;
    end
  end
  
end
