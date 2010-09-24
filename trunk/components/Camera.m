% This class defines a single camera as a special case of a camera array
classdef Camera < CameraArray
  
  methods (Access=public)
    % Limits the camera array to providing exactly one view
    function num=numViews(this)
      assert(isa(this,'Camera'));
      num=uint32(1);
    end
  end
    
  methods (Abstract=true)
    % These redefined methods do not require the 'view' argument
    str=interpretLayers(this,varargin);
    [numStrides,numSteps,numLayers]=getImageSize(this,n,varargin);
    im=getImage(this,n,varargin);
    flag=isFrameDynamic(this,varargin);
    pose=getFrame(this,n,varargin);
    flag=isProjectionDynamic(this,varargin);
    pix=projection(this,ray,n,varargin);
    ray=inverseProjection(this,pix,n,varargin);
  end
 
end
