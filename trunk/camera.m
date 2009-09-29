classdef camera < sensor

  methods (Access=protected)
    function this=camera
    end
  end
  
  methods (Access=public,Abstract=true)
    % Get grayscale image
    %
    % INPUT
    % k = node index, uint32 scalar
    %
    % OUTPUT
    % gray = grayscale image, uint8 M-by-N
    %
    % NOTE
    % If no image is available, then return value is 0-by-0
    % TODO: define exceptions for error handling
    gray=getGray8RowMajor(this,k);
    gray=getGray8ColMajor(this,k);
    
    % Get color image
    %
    % INPUT
    % k = node index, uint32 scalar
    %
    % OUTPUT
    % rgb = color image, uint8 M-by-N-by-3
    %
    % NOTE
    % If no image is available, then return value is 0-by-0-by-3
    % TODO: define exceptions for error handling
    rgb=getColor32RowMajor(this,k);
    rgb=getColor32ColMajor(this,k);

    
    %%% GETFOCAL IS LIKELY TO BE DEPRICATED %%%
    
    
    % Get focal length
    %
    % INPUT
    % k = node index, uint32 scalar
    %
    % OUTPUT
    % rho = focal length, double scalar
    % TODO: provide intrinsic calibration data or forward/reverse projection functions
    % TODO: define exceptions for error handling
    rho=getFocal(this,k);
    
    
    %%% THE FOLLOWING ARE UNDER CONSIDERATION %%%


    % Get camera frame represented in the body frame
    %
    % INPUT
    % k = node index, uint32 scalar
    %
    % OUTPUT
    % posquat = position and quaternion transformation, double 7-by-1
    % TODO: define exceptions for error handling
    % posquat=gimbalState(this,k);
    
    % Transform ray vectors in the camera frame to image points
    %
    % INPUT
    % k = node index, uint32 scalar
    % ray = unit vector in camera frame, double 3-by-1
    %
    % OUTPUT
    % ij = point in image coordinates, double 2-by-1
    % ij=project(this,k,ray);
    
    % Transform image points to ray vectors in the camera frame
    %
    % INPUT
    % k = node index, uint32 scalar
    % ij = point in image coordinates, double 2-by-1
    %
    % OUTPUT
    % ray = unit vector in camera frame, double 3-by-1
    % ray=inverseProject(this,k,ij);
  end
 
end
