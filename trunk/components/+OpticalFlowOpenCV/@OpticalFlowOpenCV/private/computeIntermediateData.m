function data = computeIntermediateData(this, na, nb)
  persistent handle

  ia = this.sensor.getImage(na);
  ib = this.sensor.getImage(nb);
  
  switch( this.sensor.interpretLayers() )
  case {'rgb', 'rgbi'}
    ia = double(rgb2gray(ia(:, :, 1:3)));
    ib = double(rgb2gray(ib(:, :, 1:3)));
  case {'hsv', 'hsvi'}
    ia = double(ia(:, :, 3));
    ib = double(ib(:, :, 3));
  otherwise
    ia = double(ia);
    ib = double(ib);
  end

  [pixA, pixB] = mexOpticalFlowOpenCV(double(ia), double(ib), double(this.isDense), this.windowSize, this.levels);
  data = struct('pixA', pixA, 'pixB', pixB);
  
  if(this.displayFlow)
    if(isempty(handle))
      handle = figure;
    else
      figure(handle);
      clf(handle);
    end
    imagesc(ia);
    hold('on');
    pixA = pixA+1;
    pixB = pixB+1;
    for ind = 1:size(pixA, 1)
      line([pixA(ind, 1), pixB(ind, 1)], [pixA(ind, 2), pixB(ind, 2)], 'Color', 'c');
    end
    colormap('gray');
    hold('off');
    drawnow;
  end
  
end
