function displayFeatures(imageA, imageB, pixA, pixB)
  persistent figureHandle plotHandle
  if(isempty(figureHandle))
    figureHandle = figure;
  else
    figure(figureHandle);
    if(~isempty(plotHandle))
      delete(plotHandle);
    end
  end
  imshow(cat(3, zeros(size(imageA)), 0.5+(imageA-imageB)/2, 0.5+(imageB-imageA)));
  axis('image');
  hold('on');
  plotHandle = line([pixA(1, :); pixB(1, :)]+1, [pixA(2, :); pixB(2, :)]+1, 'Color', 'r');
  drawnow;
end
