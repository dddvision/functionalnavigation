classdef DataContainerTest < handle
  
  methods (Access=public)
    function this = DataContainerTest(name, initialTime)
      fprintf('\n\n*** Begin DataContainer Test ***\n');
            
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
      assert(isa(list,'tom.SensorIndex'));
      fprintf(' [');
      for s=1:numel(list)
        if(s~=1)
          fprintf(', ');
        end
        fprintf('%d', uint32(list(s)));  
      end
      fprintf(']');
        
      for id=list'
        fprintf('\n\ngetSensorDescription(%d) =', uint32(id));
        text = dataContainer.getSensorDescription(id);
        fprintf(' %s',text);
        
        fprintf('\ngetSensor(%d) =', uint32(id));
        sensor = dataContainer.getSensor(id);
        assert(isa(sensor,'tom.Sensor'));
        fprintf(' ok');
        
        testbed.SensorTest(sensor);
      end
      
      fprintf('\n\nhasReferenceTrajectory =');
      flag = dataContainer.hasReferenceTrajectory();
      assert(isa(flag,'logical'));
      if(flag)
        fprintf(' true');
        
        fprintf('\ngetReferenceTrajectory =');
        trajectory = dataContainer.getReferenceTrajectory();
        assert(isa(trajectory,'tom.Trajectory'));
        fprintf(' ok');
        
        testbed.TrajectoryTest(trajectory);
      else
        fprintf(' false');
      end
      
      fprintf('\n\n*** End DataContainer Test ***');
    end
  end
  
end
