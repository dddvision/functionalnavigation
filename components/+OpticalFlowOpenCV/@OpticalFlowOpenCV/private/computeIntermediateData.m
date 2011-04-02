function data = computeIntermediateData(this, na, nb)
  persistent handle

  imageA = this.sensor.getImage(na);
  imageB = this.sensor.getImage(nb);
  
  switch( this.sensor.interpretLayers() )
  case {'rgb', 'rgbi'}
    imageA = double(rgb2gray(imageA(:, :, 1:3)));
    imageB = double(rgb2gray(imageB(:, :, 1:3)));
  case {'hsv', 'hsvi'}
    imageA = double(imageA(:, :, 3));
    imageB = double(imageB(:, :, 3));
  otherwise
    imageA = double(imageA);
    imageB = double(imageB);
  end

  [pixA, pixB] = mexOpticalFlowOpenCV(double(imageA), double(imageB), double(this.isDense), this.windowSize, this.levels);
  data = struct('pixA', pixA, 'pixB', pixB);
  
  if(this.displayFlow)
    imageA = imageA/255;
    imageB = imageB/255;
    if(isempty(handle))
      handle = figure;
    else
      figure(handle);
      clf(handle);
    end
    imshow(cat(3, zeros(size(imageA)), 0.5+(imageA-imageB)/2, 0.5+(imageB-imageA)));
    hold('on');
    pixA = pixA+1;
    pixB = pixB+1;
    line([pixA(:, 1), pixB(:, 1)]', [pixA(:, 2), pixB(:, 2)]', 'Color', 'r');
    hold('off');
    drawnow;
  end
  
end
