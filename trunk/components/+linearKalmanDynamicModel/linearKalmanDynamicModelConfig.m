classdef linearKalmanDynamicModelConfig < handle
  properties (Constant=true)
    % deviation of prior position distribution
    priorSigma=[1;0;0];
  end
end
