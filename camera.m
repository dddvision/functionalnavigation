% NOTES
% This class defines a single camera as a special case of a camera array
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
    % Interpret image layers
    %
    % INPUT
    % varargin = ignored arguments
    %
    % OUTPUT
    % str = 
    %  'rgbi' red-green-blue-infrared
    %  'rgb'  red-green-blue
    %  'hsv'  hue-saturation-value
    %  'v'    grayscale
    %  'i'    infrared
    str=interpretLayers(this,varargin);
    
    % Get an image
    %
    % INPUT
    % k = data index, uint32 scalar
    % varargin = ignored arguments
    %
    % OUTPUT
    % im = image, uint8 HEIGHT-by-WIDTH-by-LAYERS
    im=getImage(this,k,varargin);
    
    % Check whether the camera frame moves relative to the body frame
    %
    % INPUT
    % varargin = ignored arguments
    %
    % OUTPUT
    % flag = true if the offset changes, false otherwise, bool
    flag=isFrameDynamic(this,varargin);
    
    % Get sensor frame position and orientation relative to the body frame
    %
    % INPUT
    % k = data index, uint32 scalar
    % varargin = ignored arguments
    %
    % OUTPUT
    % p = position of sensor origin in the body frame, double 3-by-1
    % q = orientation of sensor frame in the body frame as a quaternion, double 4-by-1
    %
    % NOTE
    % The camera frame origin is coincident with its focal point
    [p,q]=getFrame(this,k,varargin);
        
    % Check whether the camera projection changes over time
    %
    % INPUT
    % varargin = ignored arguments
    %
    % OUTPUT
    % flag = true if the projection changes, false otherwise, bool
    flag=isProjectionDynamic(this,varargin);
    
    % Project ray vectors in the camera frame to image points and vice-versa
    %
    % INPUT
    % k = data index, uint32 scalar
    % varargin = ignored arguments
    %
    % INPUT/OUTPUT
    % ray = unit vectors in camera frame, double 3-by-P
    % pix = points in pixel coordinates, double 2-by-P
    %
    % NOTES
    % Pixel coordinate interpretation:
    %   pix(1,:) = strides along the non-contiguous dimension (Matlab column minus one)
    %   pix(2,:) = steps along the contiguous dimension (Matlab row minus one)
    % Points outside the valid image area return NaN-valued vectors
    % Region masking can be indicated through NaN-valued returns
    pix=projection(this,ray,k,varargin);
    ray=inverseProjection(this,pix,k,varargin);
  end
 
end
