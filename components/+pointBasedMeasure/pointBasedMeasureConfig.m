classdef pointBasedMeasureConfig < handle
  properties (Constant=true,GetAccess=protected)
  	% siftcode
  	siftCode='siftDemoV4';
  	% URL for SIFT Code
    siftCodeRepository='http://people.cs.ubc.ca/~lowe/keypoints/';
    % Agree to license flag, false by default
    siftCodeAgreeToLicense = false;     
    % vincentToolbox
    vincentToolbox='vincentToolbox';
    % URL for vincentToolbox
    vincentToolboxRepository='http://vision.ucsd.edu/~vrabaud/toolbox/';
    % Agree to license flag, false by default
    vincentToolboxAgreeToLicense=false; 
    % pdollarToolbox
    pdollarToolbox='piotr_toolbox_V2.40';
    % URL for pdollarToolbox
    pdollarToolboxRepository='http://vision.ucsd.edu/~pdollar/toolbox/';
    % Agree to license flag, false by default
    pdollarToolboxAgreeToLicense=false;     
  end
end
