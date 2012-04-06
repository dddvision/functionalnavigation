% This class defines a single camera as a special case of a camera array
classdef Camera < antbed.CameraArray
  
  methods (Access = protected, Static = true)
    function this = Camera(initialTime)
      this = this@antbed.CameraArray(initialTime);
    end
  end
    
  methods (Access = public)
    % Limits the camera array to providing exactly one view
    function num = numViews(this)
      assert(isa(this, 'antbed.Camera'));
      num = uint32(1);
    end
  end
    
  methods (Abstract = true, Access = public)
    % These redefined methods do not require the 'view' argument
    num = numSteps(this, varargin);
    num = numStrides(this, varargin);
    str = interpretLayers(this, varargin);
    im = getImage(this, n, varargin);
    flag = isFrameDynamic(this, varargin);
    pose = getFrame(this, n, varargin);
    flag = isProjectionDynamic(this, varargin);
    pix = projection(this, ray, n, varargin);
    ray = inverseProjection(this, pix, n, varargin);
  end
 
end
