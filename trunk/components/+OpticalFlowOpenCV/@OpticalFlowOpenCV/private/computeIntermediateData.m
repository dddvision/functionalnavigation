function data=computeIntermediateData(this,na,nb)
  persistent handle

  ia=getImage(this.sensor,na);
  ib=getImage(this.sensor,nb);
  
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

  [pixA,pixB]=mexOpticalFlowOpenCV(double(ia),double(ib),double(this.isDense),this.windowSize,this.levels);
  data=struct('pixA',pixA,'pixB',pixB);
  
  if(this.displayFlow)
    if(isempty(handle))
      handle=figure;
    else
      figure(handle);
      clf(handle);
    end
    imagesc(ia);
    hold('on');
    pixA=pixA+1;
    pixB=pixB+1;
    for ind = 1: size(pixA,1)
      line([pixA(ind,1) pixB(ind,1)], [pixA(ind,2) pixB(ind,2)],'Color','c');
    end
    colormap('gray');
    hold('off');
    drawnow;
  end
  
end
