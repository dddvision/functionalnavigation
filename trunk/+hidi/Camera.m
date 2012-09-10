% Camera rigidly fixed to a body with its frame origin coincident with the focal point of the projection
%
% Pixel coordinate interpretation:
%   pix(1, :) = strides along the non-contiguous dimension (MATLAB column minus one)
%   pix(2, :) = steps along the contiguous dimension (MATLAB row minus one)
classdef Camera < hidi.Sensor
 methods (Access = public, Abstract = true)    
    % Get number of pixels in the contiguous dimension of each image
    %
    % @return number of pixels along the contiguous dimension (MATLAB rows), uint32 scalar
    num = numSteps(this);
    
    % Get number of pixels in the non-contiguous dimension of each image
    %
    % @return number of pixels along the non-contiguous dimension (MATLAB columns), uint32 scalar
    num = numStrides(this);
    
    % Interpret image layers
    %
    % @return         (see examples below), string
    %  'rgbi' red-green-blue-infrared
    %  'rgb'  red-green-blue
    %  'hsv'  hue-saturation-value
    %  'v'    grayscale
    %  'i'    infrared
    %
    % NOTES
    % The number of characters in the returned string is equal to the number of image layers
    str = interpretLayers(this);
    
    % Get an image
    %
    % @param[in] n    data index, uint32 scalar
    % @return         image uint8 height-by-width-by-layers
    %
    % NOTES
    % Throws an exception if the data index is out of range
    im = getImage(this, n);
    
    % Check whether the sensor frame moves relative to the body frame
    %
    % @return true if the offset changes, false otherwise, bool
    flag = isFrameDynamic(this);
    
    % Get sensor frame position and orientation relative to the body frame
    %
    % @param[in] n data index, uint32 scalar
    % @return      position and orientation of sensor origin in the body frame, Pose scalar
    %
    % NOTES
    % Sensor frame axis order is forward-right-down relative to the body frame
    % Throws an exception if the data index is out of range
    pose = getFrame(this, n);
        
    % Check whether the camera projection changes over time
    %
    % @return true if the projection changes, false otherwise, bool
    flag = isProjectionDynamic(this);
    
    % Project ray vectors in the camera frame to image points
    %
    % @param[in]  ray  unit vectors in camera frame, double 3-by-P
    % @param[in]  n    data index, uint32 scalar
    % @return          points in pixel coordinates, double 2-by-P
    %
    % NOTES
    % Points outside the valid image area return NaN-valued vectors
    % Region masking can be indicated through NaN-valued returns
    % Throws an exception if the data index is out of range
    pix = projection(this, ray, n);
    
    % Project image points to ray vectors in the camera frame
    %
    % @param[in]  pix  points in pixel coordinates, double 2-by-P
    % @param[in]  n    data index, uint32 scalar
    % @return          unit vectors in camera frame, double 3-by-P
    %
    % NOTES
    % Points outside the valid image area return NaN-valued vectors
    % Region masking can be indicated through NaN-valued returns
    % Throws an exception if the data index is out of range
    ray = inverseProjection(this, pix, n);
 end
end
