% ia = sub-pixel rows of patch centers in first frame
% ib = sub-pixel columns of patch centers in first frame
% Pin = pyramid structure (created by BuildPyramid()
% y = image in range [0,1]
% ia = sub-pixel rows of patch centers in first frame
% ib = sub-pixel columns of patch centers in first frame
% Pin = pyramid structure (created by BuildPyramid()

function [ibe,jbe,Pout]=TrackFeaturesKLT(ia,ja,Pin,y,halfwin,RESIDUE_THRESH)

  LEVELS=length(Pin);
  Pout=BuildPyramid(y,LEVELS);

  ibe=ia;
  jbe=ja;

  for L=LEVELS:-1:1
     za=Pin{L}.y;
    gia=Pin{L}.gi;
    gja=Pin{L}.gj;

     zb=Pout{L}.y;
    gib=Pout{L}.gi;
    gjb=Pout{L}.gj;

    [ibe,jbe]=MEXtrackFeaturesKLT(za,gia,gja,ia,ja,zb,gib,gjb,ibe,jbe,L,2*halfwin+1,RESIDUE_THRESH);
  end

end
