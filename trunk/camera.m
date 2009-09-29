classdef camera < sensor
  
  % TODO: define exceptions for invalid indices and other errors
  methods (Access=public,Abstract=true)
    % Interpret image layers
    %
    % OUTPUT
    % str = 
    %  'rgbi' red-green-blue-infrared
    %  'rgb'  red-green-blue
    %  'hsv'  hue-saturation-value
    %  'v'    grayscale
    %  'i'    infrared
    str=layers(this);
    
    % Get an image
    %
    % INPUT
    % k = node index, uint32 scalar
    %
    % OUTPUT
    % im = image, uint8 HEIGHT-by-WIDTH-by-LAYERS
    im=getImage(this,k);

    % Get camera frame origin in the body frame
    %
    % INPUT
    % k = node index, uint32 scalar
    %
    % OUTPUT
    % pos = position of camera frame origin in the body frame, double 3-by-1
    pos=origin(this,k);
    
    % Project ray vectors to image points and vice-versa
    %
    % INPUT/OUTPUT
    % k = node index, uint32 scalar
    % ray = unit vector in camera frame, double 3-by-1
    % xy = point in pixel coordinates, double 2-by-1
    %
    % NOTES
    % Camera frame axis order is forward-right-down
    % Pixel coordinate interpretation:
    %   xy(1) = stride along the non-contiguous dimension (Matlab column minus one)
    %   xy(2) = step along the contiguous dimension (Matlab row minus one)
    % Points outside the image area return NaN-valued vectors
    xy=projection(this,k,ray);
    ray=inverseProjection(this,k,xy);
  end
 
end
