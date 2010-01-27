classdef dynamicModelStubConfig < handle

  properties (Constant=true,GetAccess=protected)
    blocksPerSecond=0.5;
    % state interpretation: latLonAlt,rotation,latLonAltRate,rotationRate
    A=sparse([zeros(6),eye(6);zeros(6),zeros(6)]); % 12-by-12
%    B=sparse(0.1*[zeros(6);eye(6)]); % 12-by-numInputs
    B=sparse(0.1*[zeros(6);diag([1,1,0,0,0,0])]); % 12-by-numInputs
  end
  
end
