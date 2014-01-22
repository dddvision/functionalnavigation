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
          stepLabel = 'Run';
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
          stepLabel = 'Crawl';
        otherwise
          stepLabel = 'Undefined';
      end
    end
    
    function stepID = labelToID(stepLabel)
      persistent lookup
      if(isempty(lookup))
        lookup = containers.Map;
        if(lookup.length()==0)
          for stepID = uint32(0:27)
            lookup(hidi.Pedometer.idToLabel(stepID)) = stepID;
          end
        end
      end
      try
        stepID = lookup(stepLabel);
      catch %#ok return zero on lookup error
        stepID = uint32(0);
      end
    end
    
    % Simplify a step identifier to fall within a limited set of classes.
    %
    % @param[in] stepID any step identifier
    % @return           simplified step identifier
    % 
    % @note
    % The return value identifies one of the following labels
    %   "Still"     zero displacement and zero rotation
    %   "Loiter"    zero displacement
    %   "Backward"  negative sign along forward axis
    %   "Right"     positive sign along right axis
    %   "Left"      negative sign along right axis
    %   "Forward"   positive sign along forward axis
    %   "Run"       positive sign along forward axis
    %   "Crawl"     positive sign along forward axis
    %   "Undefined" undefined
    function simpleID = simplifyStepID(stepID)
      simpleID = zeros(size(stepID), 'uint32');
      for k = 1:numel(stepID)
        switch(stepID(k))
          case {1, 2, 4}
            simpleID(k) = 1; % Still
          case {3, 5}
            simpleID(k) = 3; % Loiter
          case {8, 18}
            simpleID(k) = 8; % Backward
          case 9
            simpleID(k) = 9; % Right
          case 10
            simpleID(k) = 10; % Left
          case {6, 7, 11, 12, 15, 16, 17, 19, 20, 21, 22, 23, 24, 25, 26}
            simpleID(k) = 11; % Forward
          case {13, 14}
            simpleID(k) = 14; % Run
          case 27
            simpleID(k) = 27; % Crawl
          otherwise
            simpleID(k) = 0; % Undefined
        end
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
