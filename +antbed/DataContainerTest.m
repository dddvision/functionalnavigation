classdef DataContainerTest < handle
  
  methods (Access = public, Static = true)
    function this = DataContainerTest(name, initialTime)
      fprintf('\n\n*** Begin DataContainer Test ***\n');
      
      fprintf('\nantbed.DataContainer.description =');
      text = antbed.DataContainer.description(name);
      assert(isa(text, 'char'));
      fprintf(' %s', text);
      
      fprintf('\nantbed.DataContainer.create =');
      dataContainer = antbed.DataContainer.create(name, initialTime);
      assert(isa(dataContainer, 'antbed.DataContainer'));
      fprintf(' ok');
      
      fprintf('\n\nlistSensors =');
      list = dataContainer.listSensors('tom.Sensor');
      assert(isa(list, 'antbed.SensorIndex'));
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
        
        antbed.TrajectoryTest(trajectory);
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
        assert(isa(sensor, 'tom.Sensor'));
        fprintf(' ok');
        
        antbed.SensorTest(sensor);
        
        fprintf('\n\nrefresh\n');
        sensor.refresh(trajectory);
        
        antbed.SensorTest(sensor);
        
        fprintf('\n\nrefresh\n');
        sensor.refresh(trajectory);
        
        antbed.SensorTest(sensor);
        
        if(isa(sensor, 'antbed.CameraArray'))
          antbed.CameraArrayTest(sensor);
        end
        
        % tests that require a reference trajectory
        if(flag)
          if(isa(sensor, 'antbed.GPSReceiver'))
            antbed.GPSReceiverTest(sensor, trajectory);
          end
        end
      end
      
      fprintf('\n\n*** End DataContainer Test ***');
    end
  end
  
end
