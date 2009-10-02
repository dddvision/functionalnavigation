% NOTES
% Body frame axis order is forward-right-dowm
% Camera frame axis order is forward-right-down
% If you need to add optional device methods, then inherit from this class
classdef camera < sensor
  
  methods (Abstract=true)
    % Interpret image layers
    %
    % OUTPUT
    % str = 
    %  'rgbi' red-green-blue-infrared
    %  'rgb'  red-green-blue
    %  'hsv'  hue-saturation-value
    %  'v'    grayscale
    %  'i'    infrared
    str=interpretLayers(this);
    
    % Get an image
    %
    % INPUT
    % k = data index, uint32 scalar
    %
    % OUTPUT
    % im = image, uint8 HEIGHT-by-WIDTH-by-LAYERS
    im=getImage(this,k);
    
    % Check whether the camera frame moves relative to the body frame
    %
    % OUTPUT
    % flag = true if the offset changes, false otherwise, bool
    flag=isOffsetDynamic(this);
    
    % Get camera frame position and orientation relative to the body frame
    %
    % INPUT
    % k = data index, uint32 scalar
    %
    % OUTPUT
    % p = position of camera origin in the body frame, double 3-by-1
    % q = orientation of camera frame in the body frame as a quaternion, double 4-by-1
    [p,q]=getOffset(this,k);
        
    % Check whether the camera projection changes over time
    %
    % OUTPUT
    % flag = true if the projection changes, false otherwise, bool
    flag=isProjectionDynamic(this);
    
    % Project ray vectors in the camera frame to image points and vice-versa
    %
    % INPUT/OUTPUT
    % k = data index, uint32 scalar
    % ray = unit vectors in camera frame, double 3-by-P
    % pix = points in pixel coordinates, double 2-by-P
    %
    % NOTES
    % Pixel coordinate interpretation:
    %   pix(1,:) = strides along the non-contiguous dimension (Matlab column minus one)
    %   pix(2,:) = steps along the contiguous dimension (Matlab row minus one)
    % Points outside the image area return NaN-valued vectors
    pix=projection(this,k,ray);
    ray=inverseProjection(this,k,pix);
  end
 
end
