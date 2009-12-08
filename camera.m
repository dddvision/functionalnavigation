% This class defines a single camera as a special case of a camera array
classdef camera < cameraArray
  
  methods (Access=public)
    % Limits the cameraArray to providing exactly one view
    function num=numViews(this)
      assert(isa(this,'camera'));
      num=uint32(1);
    end
  end
    
  methods (Abstract=true)
    % These redefined methods do not require the 'view' argument
    str=interpretLayers(this,varargin);
    [numStrides,numSteps,numLayers]=getImageSize(this,k,varargin);
    im=getImage(this,k,varargin);
    flag=isFrameDynamic(this,varargin);
    [p,q]=getFrame(this,k,varargin);
    flag=isProjectionDynamic(this,varargin);
    pix=projection(this,ray,k,varargin);
    ray=inverseProjection(this,pix,k,varargin);
  end
 
end
