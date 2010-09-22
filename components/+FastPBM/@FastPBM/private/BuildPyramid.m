function pyramid=BuildPyramid(y,LEVELS)

  pyramid = cell(LEVELS,1);

  [gi,gj]=ComputeDerivatives2(y);
  pyramid{1}.y=y;
  pyramid{1}.gi=gi;
  pyramid{1}.gj=gj;

  for L=2:LEVELS
    y=Reduce(y);
    [gi,gj]=ComputeDerivatives2(y);

    pyramid{L}.y=y;
    pyramid{L}.gi=gi;
    pyramid{L}.gj=gj;
  end

end
