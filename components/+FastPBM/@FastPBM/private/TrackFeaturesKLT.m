% Finds locations of features in the second image based on their locations in the first image
%
% @param[in]     pyramidA pyramid structure built from the first frame
% @param[in]     xA       sub-pixel rows of patch centers in first frame
% @param[in]     yA       sub-pixel columns of patch centers in first frame
% @param[in]     pyramidB pyramid structure built from the second frame
% @param[in,out] xB       estimated sub-pixel rows of patch centers in second frame
% @param[in,out] yB       estimated sub-pixel columns of patch centers in second frame
% @param[in]     halfwin  half window size over which to track
% @param[in]     thresh   matching threshold below which features will not be matched
%
% NOTES
% @see BuildPyramid()
function [xB,yB]=TrackFeaturesKLT(pyramidA,xA,yA,pyramidB,xB,yB,halfwin,thresh)

  levels=length(pyramidA);

  for L=levels:-1:1
    imageA=pyramidA{L}.f;
    gxA=pyramidA{L}.gx;
    gyA=pyramidA{L}.gy;

    imageB=pyramidB{L}.f;
    gxB=pyramidB{L}.gx;
    gyB=pyramidB{L}.gy;

    [xB,yB]=mexTrackFeaturesKLT(imageA,gxA,gyA,xA,yA,imageB,gxB,gyB,xB,yB,L,halfwin,thresh);
  end

end
