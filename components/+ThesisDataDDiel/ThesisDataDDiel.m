classdef ThesisDataDDiel < ThesisDataDDiel.ThesisDataDDielConfig & hidi.DataContainer

  properties (GetAccess = private, SetAccess = private)
    hasRef
    bodyRef
    sensors
    sensorDescription
  end
  
  methods (Access = public, Static = true)
    function initialize(name)
      function text = componentDescription
        text = ['Real and simulated visual and inertial data undergoing mixed motion. Reference: ',...
          'David D. Diel. Stochastic Constraints for Vision-Aided Inertial Navigation. ',...
          'MIT Masters Thesis, January 2005.'];
      end
      hidi.DataContainer.connect(name, @componentDescription, @ThesisDataDDiel.ThesisDataDDiel);
    end
  
    function this = ThesisDataDDiel(initialTime)
      this = this@hidi.DataContainer(initialTime);
      dataSetName = this.dataSetName;
      repository = this.repository;
      localDir = fileparts(mfilename('fullpath'));
      localCache = fullfile(localDir, dataSetName);

      if(~exist(localCache, 'dir'))
        zipName = [dataSetName, '.zip'];
        localZip = [localDir, '/', zipName];
        url = [repository, zipName];
        if(this.verbose)
          fprintf('\ncaching: %s', url);
        end
        urlwrite(url, localZip);
        if(this.verbose)
          fprintf('\nunzipping: %s', localZip);
        end
        unzip(localZip, localDir);
        delete(localZip);
      end
      this.hasRef = true;
      this.bodyRef = ThesisDataDDiel.BodyReference(initialTime, localCache, dataSetName);
      this.sensors{1} = ThesisDataDDiel.CameraSim(initialTime, this.secondsPerRefresh, localCache);
      this.sensorDescription{1} = 'Monocular fisheye camera fixed to body frame with offset and rotation';
      this.sensors{2} = ThesisDataDDiel.InertialSim(initialTime, this.secondsPerRefresh, localCache);
      this.sensorDescription{2} = 'Six axis inertial sensor fixed to body frame with offset and rotation';
    end
  end
  
  methods (Access = public)
    function list = listSensors(this, type)
      K = numel(this.sensors);
      flag = false(K, 1);
      for k = 1:K
        if(isa(this.sensors{k}, type))
          flag(k) = true;
        end
      end
      list = hidi.SensorIndex(find(flag)-1);
    end
    
    function text = getSensorDescription(this, id)
      text = this.sensorDescription{id+1};
    end
    
    function obj = getSensor(this, id)
      obj = this.sensors{id+1};
    end
    
    function flag = hasReferenceTrajectory(this)
      flag = this.hasRef;
    end
    
    function x = getReferenceTrajectory(this)
      x = this.bodyRef;
    end
  end
  
end
