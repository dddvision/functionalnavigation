% REFERENCE
% Middlebury College "Art" dataset
% H. Hirschmuller and D. Scharstein. Evaluation of cost functions for 
% stereo matching. In IEEE Computer Society Conference on Computer Vision 
% and Pattern Recognition (CVPR 2007), Minneapolis, MN, June 2007.
classdef middleburyData < sensorContainer

  properties (GetAccess=private,SetAccess=private)
    sensors
    names
  end

  methods (Access=public)
    function this=middleburyData
      this.sensors{1}=middleburyData.cameraSim;
      this.names{1}='CAMERA';
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