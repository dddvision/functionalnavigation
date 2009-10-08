classdef thesisDataDDiel < multiSensor

  properties (GetAccess=private,SetAccess=private)
    sensors
    names
  end
  
  methods (Access=public)
    function this=thesisDataDDiel
      config=thesisDataDDiel.thesisDataDDielConfig;

      dataSetName=config.dataSetName;
      repository=config.repository;
      localDir=fileparts(mfilename('fullpath'));
      localCache=fullfile(localDir,dataSetName);
      
      if(~exist(localCache,'dir'))
        zipName=[dataSetName,'.zip'];
        localZip=[localDir,'/',zipName];
        url=[repository,zipName];
        fprintf('\ncaching: %s',url);
        urlwrite(url,localZip);
        fprintf('\nunzipping: %s',localZip);
        unzip(localZip,localDir);
        delete(localZip);
      end
      
      this.sensors{1}=thesisDataDDiel.cameraSim(localCache);
      this.names{1}='CAMERA';
      this.sensors{2}=thesisDataDDiel.inertialSim(localCache);
      this.names{2}='IMU';
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
