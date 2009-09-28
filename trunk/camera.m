classdef camera < sensor

  methods (Access=protected)
    function this=camera
    end
  end
  
  methods (Access=public,Abstract=true)
    % Get grayscale image from a node
    %
    % INPUT
    % k = integer index, uint32 scalar
    %
    % OUTPUT
    % gray = grayscale image, uint8 M-by-N
    %
    % NOTE
    % If no image is available, then return value is 0-by-0
    % TODO: use exceptions for error handling
    gray=getGray8RowMajor(this,k);
    gray=getGray8ColMajor(this,k);
    
    % Get color image from a node
    %
    % INPUT
    % k = integer index, uint32 scalar
    %
    % OUTPUT
    % rgb = color image, uint8 M-by-N-by-3
    %
    % NOTE
    % If no image is available, then return value is 0-by-0-by-3
    % TODO: use exceptions for error handling
    rgb=getColor32RowMajor(this,k);
    rgb=getColor32ColMajor(this,k);
    
    % Get focal length from a node
    %
    % INPUT
    % k = integer index, uint32 scalar
    %
    % OUTPUT
    % rho = focal length, double scalar
    rho=getFocal(this,k);
  end
 
end
