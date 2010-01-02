classdef opticalFlowOpenCVConfig < handle
  properties (Constant=true,GetAccess=protected)
    % CVLIB_MEX
    cvlib_mex='cvlib_mex';
    % repository URL including ending '/'
    repository='http://j-ml-contrib.googlecode.com/svn/';
    % Agree to license, false by default
    cvlib_mexAgreeToLicense=false;
  end
end
