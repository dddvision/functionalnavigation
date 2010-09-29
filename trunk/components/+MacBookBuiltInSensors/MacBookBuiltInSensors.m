classdef MacBookBuiltInSensors < MacBookBuiltInSensors.MacBookBuiltInSensorsConfig & tom.DataContainer
  properties (Constant=true,GetAccess=private)
    hasRef=false;
    bodyRef=[];
    noRefText='MacBook cannot supply a reference trajectory';
    notMacText='This data source depends on MacBook or MacBook Pro laptop hardware';
    camDescription=['MacBook builtin iSight camera in low resolution mode. ',...
        'Depends on VLC for access. Clear the sensor instance to stop recording.'];
    accDescription=['MacBook Sudden Motion Sensor (SMS) three-axis accelerometer. ',...
        'Clear the sensor instance to stop recording.'];
  end
  
  properties (Access=private)
    sensors
    sensorDescription
  end
  
  methods (Static=true,Access=public)
    function initialize(name)
      function text=componentDescription
        text=['Provides data from the built-in camera and three-axis accelerometer ',...
        'available in most MacBook and MacBook Pro laptops.'];
      end
      tom.DataContainer.connect(name,@componentDescription,@MacBookBuiltInSensors.MacBookBuiltInSensors);
    end
  end
  
  methods (Access=public)
    function this=MacBookBuiltInSensors(initialTime)
      this=this@tom.DataContainer(initialTime);

      if(~ismac)
        error(this.notMacText);
      end

      this.sensorDescription{1}=this.camDescription;
      this.sensorDescription{2}=this.accDescription;
      this.sensors{1}=MacBookBuiltInSensors.MacCam(initialTime);
      this.sensors{2}=MacBookBuiltInSensors.MacAcc(initialTime);
    end
    
    function list=listSensors(this,type)
      K=numel(this.sensors);
      flag=false(K,1);
      for k=1:K
        if(isa(this.sensors{k},type))
          flag(k)=true;
        end
      end
      list=tom.SensorIndex(find(flag)-1);
    end
    
    function text=getSensorDescription(this,id)
      text=this.sensorDescription{id+1};
    end
    
    function obj=getSensor(this,id)
      obj=this.sensors{id+1};
    end
    
    function flag=hasReferenceTrajectory(this)
      flag=this.hasRef;
    end
    
    function x=getReferenceTrajectory(this)
      x=this.bodyRef;
      error(this.noRefText);
    end
  end
end
