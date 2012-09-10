classdef DataContainerTest < handle
  methods (Access = public, Static = true)
    function this = DataContainerTest(name, initialTime)
      fprintf('\n\n*** Begin DataContainer Test ***\n');
      
      fprintf('\nhidi.DataContainer.description =');
      text = hidi.DataContainer.description(name);
      assert(isa(text, 'char'));
      fprintf(' %s', text);
      
      fprintf('\nhidi.DataContainer.create =');
      dataContainer = hidi.DataContainer.create(name, initialTime);
      assert(isa(dataContainer, 'hidi.DataContainer'));
      fprintf(' ok');
      
      fprintf('\n\nlistSensors =');
      list = dataContainer.listSensors('hidi.Sensor');
      assert(isa(list, 'hidi.SensorIndex'));
      assert(size(list,2)==1);
      fprintf(' [');
      for s = 1:numel(list)
        if(s~=1)
          fprintf(', ');
        end
        fprintf('%d', uint32(list(s)));  
      end
      fprintf(']');
      
      fprintf('\n\nhasReferenceTrajectory =');
      flag = dataContainer.hasReferenceTrajectory();
      assert(isa(flag, 'logical'));
      if(flag)
        fprintf(' true');
        
        fprintf('\ngetReferenceTrajectory =');
        trajectory = dataContainer.getReferenceTrajectory();
        assert(isa(trajectory, 'tom.Trajectory'));
        fprintf(' ok');
        
        tom.TrajectoryTest(trajectory);
      else
        trajectory = tom.DynamicModel.create('tom', initialTime, '');
        fprintf(' false');
      end

      for id = list'
        fprintf('\n\ngetSensorDescription(%d) =', uint32(id));
        text = dataContainer.getSensorDescription(id);
        fprintf(' %s', text);
        
        fprintf('\ngetSensor(%d) =', uint32(id));
        sensor = dataContainer.getSensor(id);
        assert(isa(sensor, 'hidi.Sensor'));
        fprintf(' ok');
        
        hidi.SensorTest(sensor);
        
        fprintf('\n\nrefresh\n');
        sensor.refresh(trajectory);
        
        hidi.SensorTest(sensor);
        
        fprintf('\n\nrefresh\n');
        sensor.refresh(trajectory);
        
        hidi.SensorTest(sensor);
        
        if(isa(sensor, 'hidi.Camera'))
          hidi.CameraTest(sensor);
        end
        
        % tests that require a reference trajectory
        if(flag)
          if(isa(sensor, 'hidi.GPSReceiver'))
            hidi.GPSReceiverTest(sensor, trajectory);
          end
        end
      end
      
      fprintf('\n\n*** End DataContainer Test ***');
    end
  end
end
