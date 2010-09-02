classdef GlobalSatData < GlobalSatData.GlobalSatDataConfig & tom.DataContainer

  properties (GetAccess=private,SetAccess=private)
    sensor
    sensorDescription
    hasRef
    bodyRef
  end

  methods (Static=true,Access=public)
    function initialize(name)
      function text=componentDescription
        text='Simulated GPS data based on the GlobalSat BU-xxx GPS sensor.';
      end
      tom.DataContainer.connect(name,@componentDescription,@GlobalSatData.GlobalSatData);
    end
  end
  
  methods (Access=public)
    function this=GlobalSatData
      this=this@tom.DataContainer;
      this.sensor{1}=GlobalSatData.GpsSim;
      this.sensorDescription{1}='GlobalSat BU-xxx GPS sensor';
      this.hasRef=true;
      this.bodyRef=GlobalSatData.BodyReference;
    end
    
    function list=listSensors(this,type)
      K=numel(this.sensor);
      flag=false(K,1);
      for k=1:K
        if(isa(this.sensor{k},type))
          flag(k)=true;
        end
      end
      list=tom.SensorIndex(find(flag)-1);
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
