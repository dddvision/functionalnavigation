function TrackFeaturesKLTTest(this)

imageA = this.sensor.getImage(uint32(1));
imageB = this.sensor.getImage(uint32(2));
imageA = double(rgb2gray(imageA))/255;
imageB = double(rgb2gray(imageB))/255;

numLevels = 3;
halfwin = 5;
thresh = 0.98;

% zero pad without affecting pixel coordinates
multiple = 2^(numLevels-1);
[M, N] = size(imageA);
Mpad = multiple-mod(M, multiple);
Npad = multiple-mod(N, multiple);
if((Mpad>0)||(Npad>0))
  imageA(M+Mpad, N+Npad) = 0;
  imageB(M+Mpad, N+Npad) = 0;
end

pyramidA = buildPyramid(imageA, numLevels);
pyramidB = buildPyramid(imageB, numLevels);

kappa = computeCornerStrength(pyramidA{1}.gx, pyramidA{1}.gy, halfwin, 'Harris');
peaksA = findPeaks(kappa, halfwin);
[xA, yA] = find(peaksA);
xB = xA;
yB = yA;

[xB, yB] = TrackFeaturesKLT(pyramidA, xA, yA, pyramidB, xB, yB, halfwin, thresh);

good = ~isnan(xB);
xA = xA(good);
yA = yA(good);
xB = xB(good);
yB = yB(good);

figure;
imshow(imageA(1:M,1:N));
hold('on');
axis('image');
plot([yA,yB]', [xA,xB]', 'r');
drawnow;

end
