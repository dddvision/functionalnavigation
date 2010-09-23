% Finds locations of features in the second image based on their locations in the first image
%
% @param[in]     pyramidA pyramid structure built from the first frame
% @param[in]     xA       one-based sub-pixel rows of patch centers in first frame
% @param[in]     yA       one-based sub-pixel columns of patch centers in first frame
% @param[in]     pyramidB pyramid structure built from the second frame
% @param[in,out] xB       one-based estimated sub-pixel rows of patch centers in second frame
% @param[in,out] yB       one-based estimated sub-pixel columns of patch centers in second frame
% @param[in]     halfwin  half window size over which to track
% @param[in]     thresh   matching threshold below which features will not be matched
%
% NOTES
% @see BuildPyramid()
function [xB, yB] = TrackFeaturesKLT(pyramidA, xA, yA, pyramidB, xB, yB, halfwin, thresh)

  xAref=xA-1;
  yAref=yA-1;
  xB=xB-1;
  yB=yB-1;
  
  numLevels = length(pyramidA);
  for level = numLevels:-1:1
    imageA = pyramidA{level}.f;
    gxA = pyramidA{level}.gx;
    gyA = pyramidA{level}.gy;

    imageB = pyramidB{level}.f;
    gxB = pyramidB{level}.gx;
    gyB = pyramidB{level}.gy;

    if(level>1)
      scale = 2^(level-1);
      xA = xAref/scale;
      yA = yAref/scale;
      xB = xB/scale;
      yB = yB/scale;
    else
      xA = xAref;
      yA = yAref;
    end

    [xB, yB] = mexTrackFeaturesKLT(imageA, gxA, gyA, xA, yA, imageB, gxB, gyB, xB, yB, halfwin, thresh);
    
    if(level>1)
      xB = xB*scale;
      yB = yB*scale;
    end
  end
  
  xB=xB+1;
  yB=yB+1;

end
