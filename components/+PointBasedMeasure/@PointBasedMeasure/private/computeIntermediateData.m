function IntermediateData=computeIntermediateData(this,ia,ib)
  
  switch( interpretLayers(this.sensor) )
    case {'rgb','rgbi'}
      ia=rgb2gray(ia(:,:,1:3));
      ib=rgb2gray(ib(:,:,1:3));
    case {'hsv','hsvi'}
      ia=ia(:,:,3);
      ib=ib(:,:,3);
    otherwise
      % do nothing
  end

  [IntermediateData] = EvaluateTrajectory_SFM(ia,ib);
end
