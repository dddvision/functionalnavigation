classdef MiddleburyData < MiddleburyData.MiddleburyDataConfig & DataContainer

  properties (GetAccess=private,SetAccess=private)
    sensor
    sensorDescription
    hasRef
    bodyRef
  end
  
  methods (Static=true,Access=protected)
    function initialize(name)
      function text=componentDescription
        text=['Image data simulating pure translation from the Middlebury stereo dataset. ',...
          'Reference: H. Hirschmuller and D. Scharstein. Evaluation of cost functions for ',...
          'stereo matching. In IEEE Computer Society Conference on Computer Vision ',...
          'and Pattern Recognition (CVPR 2007), Minneapolis, MN, June 2007.'];
      end
      DataContainer.connect(name,@componentDescription,@MiddleburyData.MiddleburyData);
    end
  end
  
  methods (Access=public)
    function this=MiddleburyData
      this=this@DataContainer;
      this.sensor{1}=MiddleburyData.CameraSim;
      this.sensorDescription{1}='Forward facing monocular perspective camera fixed at the body origin';
      this.hasRef=true;
      this.bodyRef=MiddleburyData.BodyReference;
    end
    
    function list=listSensors(this,type)
      K=numel(this.sensor);
      flag=false(K,1);
      for k=1:K
        if(isa(this.sensor{k},type))
          flag(k)=true;
        end
      end
      list=SensorIndex(find(flag)-1);
    end
    
    function text=getSensorDescription(this,id)
      text=this.sensorDescription{id+1};
    end
        
    function obj=getSensor(this,id)
      obj=this.sensor{id+1};
    end
    
    function flag=hasReferenceTrajectory(this)
      flag=this.hasRef;
    end
    
    function x=getReferenceTrajectory(this)
      x=this.bodyRef;
    end
  end
  
end
