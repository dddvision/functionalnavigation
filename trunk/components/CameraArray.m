% This class defines a synchronously time-stamped array of cameras
%   rigidly attached to a body with different positions and orientations
classdef CameraArray < Sensor
  
  methods (Abstract=true)
    % Get number of cameras in the array
    %
    % OUTPUT
    % num = number of views, uint32 scalar
    num=numViews(this);
    
    % Interpret image layers
    %
    % INPUT
    % view = zero-based view index, uint32 scalar
    %
    % OUTPUT
    % str = 
    %  'rgbi' red-green-blue-infrared
    %  'rgb'  red-green-blue
    %  'hsv'  hue-saturation-value
    %  'v'    grayscale
    %  'i'    infrared
    %
    % NOTES
    % Throws an exception when view index is out of range
    str=interpretLayers(this,view);
    
    % Get image size
    %
    % INPUT
    % n = data index, uint32 scalar
    % view = zero-based view index, uint32 scalar
    %
    % OUTPUT
    % numStrides = number of strides along the non-contiguous dimension (MATLAB columns), uint32 scalar
    % numSteps = number of steps along the contiguous dimension (MATLAB rows), uint32 scalar
    % numLayers = number of color layers at each pixel location
    %
    % NOTES
    % Throws an exception when either input index is out of range
    [numStrides,numSteps,numLayers]=getImageSize(this,n,view);
    
    % Get an image
    %
    % INPUT
    % n = data index, uint32 scalar
    % view = zero-based view index, uint32 scalar
    %
    % OUTPUT
    % im = image, uint8 height-by-width-by-layers
    %
    % NOTES
    % Throws an exception when either input index is out of range
    im=getImage(this,n,view);
    
    % Check whether the camera frame moves relative to the body frame
    %
    % INPUT
    % view = zero-based view index, uint32 scalar
    %
    % OUTPUT
    % flag = true if the offset changes, false otherwise, bool
    %
    % NOTES
    % Throws an exception when view index is out of range
    flag=isFrameDynamic(this,view);
    
    % Get sensor frame position and orientation relative to the body frame
    %
    % INPUT
    % n = data index, uint32 scalar
    % view = zero-based view index, uint32 scalar
    %
    % OUTPUT
    % p = position of sensor origin in the body frame, double 3-by-1
    % q = orientation of sensor frame in the body frame as a quaternion, double 4-by-1
    %
    % NOTES
    % Camera frame axis order is forward-right-down relative to the body frame
    % Throws an exception when either input index is out of range
    [p,q]=getFrame(this,n,view);
        
    % Check whether the camera projection changes over time
    %
    % INPUT
    % view = zero-based view index, uint32 scalar
    %
    % OUTPUT
    % flag = true if the projection changes, false otherwise, bool
    %
    % NOTES
    % Throws an exception when view index is out of range
    flag=isProjectionDynamic(this,view);
    
    % Project ray vectors in the camera frame to image points and vice-versa
    %
    % INPUT
    % n = data index, uint32 scalar
    % view = zero-based view index, uint32 scalar
    %
    % INPUT/OUTPUT
    % ray = unit vectors in camera frame, double 3-by-P
    % pix = points in pixel coordinates, double 2-by-P
    %
    % NOTES
    % Pixel coordinate interpretation:
    %   pix(1,:) = strides along the non-contiguous dimension (MATLAB column minus one)
    %   pix(2,:) = steps along the contiguous dimension (MATLAB row minus one)
    % Points outside the valid image area return NaN-valued vectors
    % Region masking can be indicated through NaN-valued returns
    % Camera frame origin is coincident with focal point of the projection
    % Throws an exception when either input index is out of range
    pix=projection(this,ray,n,view);
    ray=inverseProjection(this,pix,n,view);
  end

end
