classdef SparseTracker

  properties (Constant=true,GetAccess=public)
    maxFeatures = 30; % (30) maximum integer number of features per frame to find
    maxFrames = 10; % (10) maximum integer number of frames to track a feature
    maxSearch = 0.05; % (0.05) approximate maximum angle to search for a feature in radians
  end

  methods (Access=public,Static=true)
    function this=SparseTracker()
    end
  end
  
  methods (Abstract=true,Access=public,Static=false)
    % Instructs the tracker to process the next image in a sequence
    %
    % @param[in] image grayscale image (MATLAB: uint8 HEIGHT-by-WIDTH)
    % @param[in] pose  estimated camera pose when image was captured (MATLAB: Pose scalar)
    % @return          unique sequential image index (MATLAB: uint32 scalar)
    node = processGrayImage(this, image, pose);
    
    % Get a list of feature indices associated with an image index
    %
    % @param[in] node unique image index (MATLAB: uint32 scalar)
    % @return         list of unique feature indices (MATLAB: uint32 M-by-1)
    featureList = getFeatures(this, node);
    
    % Get a list of images associated with a feature index
    %
    % @param[in] feature unique feature index (MATLAB: uint32 scalar)
    % @return            list of image indices (MATLAB: uint32 N-by-1)
    %
    % NOTES
    % Throws an exception if feature index is not valid 
    % @see getFeatures()
    nodeList = getCorrespondence(this, feature);
    
    % Get the position of a feature in an image
    %
    % @param[in] node    unique image index (MATLAB: uint32 scalar)
    % @param[in] feature unique feature index (MATLAB: uint32 scalar)    
    % @return            feature location in pixel coordinates (MATLAB: double 2-by-1)
    %
    % NOTES
    % Pixel coordinate interpretation:
    %   pix(1,1) = strides along the non-contiguous dimension (MATLAB: column minus one)
    %   pix(2,1) = steps along the contiguous dimension (MATLAB: row minus one)
    % Throws an exception if either the node or the feature index are not valid
    % @see getFeatures()
    % @see getCorrespondence()
    pix = getFeaturePosition(this, node, feature);
  end

end
