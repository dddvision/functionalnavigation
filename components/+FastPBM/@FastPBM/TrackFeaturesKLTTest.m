function TrackFeaturesKLTTest(this)

levels = 3;
halfwin = 5;

imageA = this.sensor.getImage(uint32(1));
imageB = this.sensor.getImage(uint32(2));
imageA = double(rgb2gray(imageA))/255;
imageB = double(rgb2gray(imageB))/255;

% HACK: crop images to have a size that is a multiple of 2^(LEVELS-1)
[M, N] = size(imageA);
M = M-mod(M, 2^(levels-1));
N = N-mod(N, 2^(levels-1));
imageA = imageA(1:M, 1:N);
imageB = imageB(1:M, 1:N);

pyramidA = BuildPyramid(imageA, levels);
pyramidB = BuildPyramid(imageB, levels);

kappa = DetectCorners(pyramidA{1}.gx, pyramidA{1}.gy, halfwin, 'HarrisCorner');
peaksA = FindPeaks(kappa, [3,3]);
[xA, yA] = find(peaksA);
xB = xA;
yB = yA;

[xB, yB] = TrackFeaturesKLT(pyramidA, xA, yA, pyramidB, xB, yB, halfwin, 0.000001);

good = ~isnan(xB);
xA = xA(good);
yA = yA(good);
xB = xB(good);
yB = yB(good);

figure;
imshow(imageA);
hold('on');
axis('image');
plot([yA,yB]', [xA,xB]', 'r');
drawnow;

end
