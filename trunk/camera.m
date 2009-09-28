classdef camera < sensor

  methods (Access=protected)
    function this=camera
    end
  end
  
  methods (Access=public,Abstract=true)
    % Get a gray image from a node
    %
    % INPUT
    % k = integer index, double scalar
    %
    % OUTPUT
    % gray = grayscale image, double M-by-N
    gray=getGray(this,k);
    
    % Get focal length from a node
    %
    % INPUT
    % k = integer index, double scalar
    %
    % OUTPUT
    % rho = focal length, double scalar
    rho=getFocal(this,K);
  end
 
end
