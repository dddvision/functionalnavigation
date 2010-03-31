% REFERENCE
% Middlebury College "Art" dataset
% H. Hirschmuller and D. Scharstein. Evaluation of cost functions for 
% stereo matching. In IEEE Computer Society Conference on Computer Vision 
% and Pattern Recognition (CVPR 2007), Minneapolis, MN, June 2007.
classdef MiddleburyData < MiddleburyData.MiddleburyDataConfig & DataContainer

  properties (GetAccess=private,SetAccess=private)
    sensors
    names
    hasRef
    bodyRef
  end
  
  methods (Access=public)
    function this=MiddleburyData
      this=this@DataContainer;
      this.sensors{1}=MiddleburyData.CameraSim;
      this.names{1}='CAMERA';
      this.hasRef=true;
      this.bodyRef=MiddleburyData.BodyReference;
    end
    
    function list=listSensors(this,type)
      assert(isa(type,'char'));
      K=numel(this.sensors);
      flag=false(K,1);
      for k=1:K
        if(isa(this.sensors{k},type))
          flag(k)=true;
        end
      end
      list=uint32(find(flag)-1);
    end
    
    function name=getSensorName(this,id)
      assert(isa(id,'uint32'));
      name=this.names{id+1};
    end
        
    function obj=getSensor(this,id)
      assert(isa(id,'uint32'));
      obj=this.sensors{id+1};
    end
    
    function flag=hasReferenceTrajectory(this)
      flag=this.hasRef;
    end
    
    function x=getReferenceTrajectory(this)
      x=this.bodyRef;
    end
  end
  
end
