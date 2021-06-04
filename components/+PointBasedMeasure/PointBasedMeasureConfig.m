classdef PointBasedMeasureConfig < handle
% Copyright 2011 University of Central Florida, New BSD License
  properties (Constant=true,GetAccess=public)
      ZThreshold = 3; % threshold in standard deviations of Z axis that will cause framework to throw out edge as having too small of a baseline (default=4)
      HFThreshold = .6; % Maximum accepted  ratio between the inliers homography and fundamental matrix
	ErrorType = 1; % Way to compute error:       
                     % 1 = Direct difference error 
                     %       - difference in given trajectory and estimated
                     %         trajectory trajectories
                     % 2 = Reprojection error
                     % 3 = Epipolar error 
                     %       - distance from point to epipolar line
                     % 4 = Image error
                     %       - difference image intensity at matched points
                     % 5 = Triangulation error
                     %       - do reprojection then calculate difference in
                     %         reprojected points to origional points
      MatchingAlgo = 1; % 1 = use SURF (provided for people who may wish to add an aditional point matching algorithm to measure) Add to if statement in line 21 of EvaluateTrajectory_SFM.m
      DisplayReprojection = true;           % true = display reprojection from SBA in 3D; false = display off
      DisplayReprojectionOnPictures = true; % true = display point matches and reprojection from SBA on sampled images; false = display off
      DisplayTestTrajectory = true;         % true = display console output; false = quite mode
      PauseBetweenImages = false;            % true = will pause at image procesing pairs(only active when a display is on); false=continue between pairs
  end
end
