% NOTES
% This class defines a synchronously time-stamped array of cameras
%   rigidly attached to a body with different positions and orientations
% Body frame axis order is forward-right-dowm
% Camera frame axis order is forward-right-down
% All methods assume view=0 when the view argument is not present
% If you need to add optional device methods, then inherit from this class
classdef cameraArray < sensor
  
  methods (Abstract=true)
    % Get number of camera views in the array
    %
    % OUTPUT
    % num = number of views, uint32 N-by-1
    num=numViews(this);
    
    % Interpret image layers
    %
    % INPUT
    % view = (default=0) zero-based view index, uint32 scalar
    %
    % OUTPUT
    % str = 
    %  'rgbi' red-green-blue-infrared
    %  'rgb'  red-green-blue
    %  'hsv'  hue-saturation-value
    %  'v'    grayscale
    %  'i'    infrared
    str=interpretLayers(this,view);
    
    % Get an image
    %
    % INPUT
    % k = data index, uint32 scalar
    % view = (default=0) zero-based view index, uint32 scalar
    %
    % OUTPUT
    % im = image, uint8 HEIGHT-by-WIDTH-by-LAYERS
    im=getImage(this,k,view);
    
    % Check whether the camera frame moves relative to the body frame
    %
    % INPUT
    % view = (default=0) zero-based view index, uint32 scalar
    %
    % OUTPUT
    % flag = true if the offset changes, false otherwise, bool
    flag=isFrameDynamic(this,view);
    
    % Get sensor frame position and orientation relative to the body frame
    %
    % INPUT
    % k = (default=min(domain(this))) data index, uint32 scalar
    % view = (default=0) zero-based view index, uint32 scalar
    %
    % OUTPUT
    % p = position of sensor origin in the body frame, double 3-by-1
    % q = orientation of sensor frame in the body frame as a quaternion, double 4-by-1
    %
    % NOTE
    % The camera frame origin is coincident with its focal point
    [p,q]=getFrame(this,k,view);
        
    % Check whether the camera projection changes over time
    %
    % INPUT
    % view = (default=0) zero-based view index, uint32 scalar
    %
    % OUTPUT
    % flag = true if the projection changes, false otherwise, bool
    flag=isProjectionDynamic(this,view);
    
    % Project ray vectors in the camera frame to image points and vice-versa
    %
    % INPUT
    % k = (default=min(domain(this))) data index, uint32 scalar
    % view = (default=0) zero-based view index, uint32 scalar
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
    pix=projection(this,ray,k,view);
    ray=inverseProjection(this,pix,k,view);
  end
 
end
