classdef Pedometer < hidi.Sensor
  methods (Access = protected, Static = true)
    function this = Pedometer()
    end
  end
  
  methods (Access = public, Static = true)
    function stepLabel = idToLabel(stepID)
      switch(stepID)
        case 1
          stepLabel = 'Still';
        case 2
          stepLabel = 'Remain Seated';
        case 3
          stepLabel = 'Loiter';
        case 4
          stepLabel = 'Remain Seated in Squat';
        case 5
          stepLabel = 'Jog in Place';
        case 6
          stepLabel = 'Walk Upstairs';
        case 7
          stepLabel = 'Walk Downstairs';
        case 8
          stepLabel = 'Backward';
        case 9
          stepLabel = 'Right';
        case 10
          stepLabel = 'Left';
        case 11
          stepLabel = 'Forward';
        case 12
          stepLabel = 'Brisk Walk';
        case 13
          stepLabel = 'Jog';
        case 14
          stepLabel = 'Run Fast';
        case 15
          stepLabel = 'Walk Uphill';
        case 16
          stepLabel = 'Walk Downhill';
        case 17
          stepLabel = 'Walk Forward Dragging Sand';
        case 18
          stepLabel = 'Walk Backward Dragging Sand';
        case 19
          stepLabel = 'Turn CCW 20ft';
        case 20
          stepLabel = 'Turn CCW 15ft';
        case 21
          stepLabel = 'Turn CCW 10ft';
        case 22
          stepLabel = 'Turn CCW 5ft';
        case 23
          stepLabel = 'Turn CW 20ft';
        case 24
          stepLabel = 'Turn CW 15ft';
        case 25
          stepLabel = 'Turn CW 10ft';
        case 26
          stepLabel = 'Turn CW 5ft';
        case 27
          stepLabel = 'Belly Crawl';
        otherwise
          stepLabel = 'Undefined';
      end
    end
    
    function stepID = labelToID(stepLabel)
      persistent lookup
      lookup = containers.Map;
      if(lookup.length()==0)
        for stepID = uint32(0:27)
          lookup(hidi.Pedometer.idToLabel(stepID)) = stepID;
        end
      end
      try
        stepID = lookup(stepLabel);
      catch %#ok return zero on lookup error
        stepID = uint32(0);
      end
    end
  end
    
  methods (Access = public, Abstract = true)
    flag = isStepComplete(this, n);
    magnitude = getStepMagnitude(this, n);
    deviation = getStepDeviation(this, n);
    stepID = getStepID(this, n);
  end
end
