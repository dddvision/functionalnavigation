classdef MacBookBuiltInSensors < MacBookBuiltInSensors.MacBookBuiltInSensorsConfig & DataContainer
  properties (GetAccess=private,SetAccess=private)
    hasRef
    bodyRef
    noRefText
    sensors
    description
    sensorDescription
  end
  
  methods (Access=public)
    function this=MacBookBuiltInSensors
      this=this@DataContainer;
      if(~ismac)
        error('This data source depends on MacBook or MacBook Pro laptop hardware.');
      end
      path=fileparts(mfilename('fullpath'));
      localCache=fullfile(path,'tmp');
      if(~exist(localCache,'dir'))
        mkdir(localCache);
      end
      delete(fullfile(localCache,'*'));
      this.hasRef=false;
      this.bodyRef=[];
      this.noRefText='MacBook cannot supply a reference trajectory';
      this.description=['Provides data from the built-in camera ',...
        'and three-axis accelerometer available ',...
        'in most MacBook and MacBook Pro laptops.'];
      this.sensorDescription{1}=['MacBook builtin iSight camera in low resolution mode. ',...
        'Depends on VLC for access. Clear the sensor instance to stop recording.'];
      this.sensorDescription{2}=['MacBook Sudden Motion Sensor (SMS) three-axis accelerometer. ',...
        'Clear the sensor instance to stop recording.'];
      this.sensors{1}=MacBookBuiltInSensors.MacCam(path,localCache);
      this.sensors{2}=MacBookBuiltInSensors.MacAcc(path,localCache);
    end
    
    function text=getDescription(this)
      text=this.description;
    end
    
    function list=listSensors(this,type)
      K=numel(this.sensors);
      flag=false(K,1);
      for k=1:K
        if(isa(this.sensors{k},type))
          flag(k)=true;
        end
      end
      list=SensorIndex(find(flag)-1);
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
      assert(isa(this,'DataContainer'));
      x=[];
      error(this.noRefText);
    end
  end
end
