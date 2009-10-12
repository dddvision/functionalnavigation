% This class defines a single camera as a special case of a camera array
% These abstract methods make the camera array “view” argument optional
% If you need to add optional device methods, then inherit from this class
classdef camera < cameraArray
  
  methods (Access=public)
    % This class provides one view
    function num=numViews(this)
      assert(isa(this,'camera'));
      num=uint32(1);
    end
  end
    
  methods (Abstract=true)
    str=interpretLayers(this,varargin);
    im=getImage(this,k,varargin);
    flag=isFrameDynamic(this,varargin);
    [p,q]=getFrame(this,k,varargin);
    flag=isProjectionDynamic(this,varargin);
    pix=projection(this,ray,k,varargin);
    ray=inverseProjection(this,pix,k,varargin);
  end
 
end
