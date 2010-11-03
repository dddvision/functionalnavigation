% This class defines a synchronously time-stamped array of cameras
%   rigidly attached to a body with different positions and orientations
%
% NOTES
% The camera frame origin is coincident with focal point of the projection
% Pixel coordinate interpretation:
%   pix(1, :) = strides along the non-contiguous dimension (MATLAB column minus one)
%   pix(2, :) = steps along the contiguous dimension (MATLAB row minus one)
classdef CameraArray < tom.Sensor
  
  methods (Access = protected, Static = true)
    % Protected onstructor
    %
    % @param[in] initialTime less than or equal to the time stamp of the first data node
    %
    % NOTES
    % Each subclass constructor must initialize this base class
    % Initialize by calling this = this@tom.CameraArray(initialTime);
    function this = CameraArray(initialTime)
      this = this@tom.Sensor(initialTime);
    end
  end
  
  methods (Abstract = true, Access = public, Static = false)
    % Get number of cameras in the array
    %
    % OUTPUT
    % @return number of views, uint32 scalar
    num = numViews(this);
    
    % Get number of pixels in the contiguous dimension of each image
    %
    % @param[in] view zero-based view index, uint32 scalar
    % @return         number of steps along the contiguous dimension (MATLAB rows), uint32 scalar
    %
    % NOTES
    % Throws an exception when view index is out of range
    num = numSteps(this, view);
    
    % Get number of pixels in the non-contiguous dimension of each image
    %
    % @param[in] view zero-based view index, uint32 scalar
    % @return         number of strides along the non-contiguous dimension (MATLAB columns), uint32 scalar
    %
    % NOTES
    % Throws an exception when view index is out of range
    num = numStrides(this, view);
    
    % Interpret image layers
    %
    % @param[in] view zero-based view index, uint32 scalar
    % @return         (see examples below), string
    %  'rgbi' red-green-blue-infrared
    %  'rgb'  red-green-blue
    %  'hsv'  hue-saturation-value
    %  'v'    grayscale
    %  'i'    infrared
    %
    % NOTES
    % The number of characters in the returned string is equal to the number of image layers
    % Throws an exception when view index is out of range
    str = interpretLayers(this, view);
    
    % Get an image
    %
    % @param[in] n    data index, uint32 scalar
    % @param[in] view zero-based view index, uint32 scalar
    % @return         image uint8 height-by-width-by-layers
    %
    % NOTES
    % Throws an exception when either input index is out of range
    im = getImage(this, n, view);
    
    % Check whether the sensor frame moves relative to the body frame
    %
    % @param[in] view zero-based view index, uint32 scalar
    % @return         true if the offset changes, false otherwise, bool
    %
    % NOTES
    % Throws an exception when view index is out of range
    flag = isFrameDynamic(this, view);
    
    % Get sensor frame position and orientation relative to the body frame
    %
    % @param[in] n    data index, uint32 scalar
    % @param[in] view zero-based view index, uint32 scalar
    % @return         position and orientation of sensor origin in the body frame, Pose scalar
    %
    % NOTES
    % Sensor frame axis order is forward-right-down relative to the body frame
    % Throws an exception when either input index is out of range
    pose = getFrame(this, n, view);
        
    % Check whether the camera projection changes over time
    %
    % @param[in] view zero-based view index, uint32 scalar
    % @return         true if the projection changes, false otherwise, bool
    %
    % NOTES
    % Throws an exception when view index is out of range
    flag = isProjectionDynamic(this, view);
    
    % Project ray vectors in the camera frame to image points
    %
    % @param[in]  ray  unit vectors in camera frame, double 3-by-P
    % @param[in]  n    data index, uint32 scalar
    % @param[in]  view zero-based view index, uint32 scalar
    % @return          points in pixel coordinates, double 2-by-P
    %
    % NOTES
    % Points outside the valid image area return NaN-valued vectors
    % Region masking can be indicated through NaN-valued returns
    % Throws an exception when either input index is out of range
    pix = projection(this, ray, n, view);
    
    % Project image points to ray vectors in the camera frame
    %
    % @param[in]  pix  points in pixel coordinates, double 2-by-P
    % @param[in]  n    data index, uint32 scalar
    % @param[in]  view zero-based view index, uint32 scalar
    % @return          unit vectors in camera frame, double 3-by-P
    %
    % NOTES
    % Points outside the valid image area return NaN-valued vectors
    % Region masking can be indicated through NaN-valued returns
    % Throws an exception when either input index is out of range
    ray = inverseProjection(this, pix, n, view);
  end

end
