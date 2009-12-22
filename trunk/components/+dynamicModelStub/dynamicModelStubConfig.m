classdef dynamicModelStubConfig < handle

  properties (Constant=true,GetAccess=protected)
    A=[zeros(6),eye(6);zeros(6),zeros(6)]; % 12-by-12
    B=0.1*[zeros(6);eye(6)]; % 12-by-numInputs
  end
  
end
