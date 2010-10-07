classdef DataContainerTest < handle
  
  methods (Access = public, Static = true)
    function this = DataContainerTest(name, trajectory)
      fprintf('\n\n*** Begin DataContainer Test ***\n');
      
      fprintf('\ntrajectory =');
      assert(isa(trajectory, 'tom.Trajectory'));
      fprintf(' ok');
      
      fprintf('\ninitialTime =');
      interval = trajectory.domain();
      initialTime = interval.first;
      assert(isa(initialTime, 'tom.WorldTime'));
      fprintf(' %f', double(initialTime));
      
      fprintf('\ntom.DataContainer.description =');
      text = tom.DataContainer.description(name);
      assert(isa(text, 'char'));
      fprintf(' %s', text);
      
      fprintf('\ntom.DataContainer.create =');
      dataContainer = tom.DataContainer.create(name, initialTime);
      assert(isa(dataContainer, 'tom.DataContainer'));
      fprintf(' ok');
      
      fprintf('\n\nlistSensors =');
      list = dataContainer.listSensors('tom.Sensor');
      assert(isa(list, 'tom.SensorIndex'));
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
        referenceTrajectory = dataContainer.getReferenceTrajectory();
        assert(isa(referenceTrajectory, 'tom.Trajectory'));
        fprintf(' ok');
        
        testbed.TrajectoryTest(referenceTrajectory);
      else
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
        
        testbed.SensorTest(sensor);
        
        fprintf('\n\nrefresh\n');
        sensor.refresh(trajectory);
        
        testbed.SensorTest(sensor);
        
        fprintf('\n\nrefresh\n');
        sensor.refresh(trajectory);
        
        testbed.SensorTest(sensor);
      end
      
      fprintf('\n\n*** End DataContainer Test ***');
    end
  end
  
end
