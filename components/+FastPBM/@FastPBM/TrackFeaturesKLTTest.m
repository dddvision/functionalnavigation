function TrackFeaturesKLTTest(this)

LEVELS=2;
WIN=11;

dataContainer=tom.DataContainer.create('MiddleburyData');
camera=dataContainer.getSensor(uint32(0));
imageA=camera.getImage(uint32(1));
imageB=camera.getImage(uint32(2));
imageA=double(rgb2gray(imageA))/255;
imageB=double(rgb2gray(imageB))/255;

% HACK: crop images to have a size that is a multiple of 2^(LEVELS-1)
[M,N]=size(imageA);
M=M-mod(M,2^(LEVELS-1));
N=N-mod(N,2^(LEVELS-1));
imageA=imageA(1:M,1:N);
imageB=imageB(1:M,1:N);

[gi,gj]=ComputeDerivatives2(imageA);
kappa=DetectCorners(gi,gj,WIN,'HarrisCorner');
peaksA=FindPeaks(kappa,[WIN,WIN]);
[iA,jA]=find(peaksA);
pyramidA=BuildPyramid(imageA,LEVELS);
[iB,jB,pyramidB]=TrackFeaturesKLT(iA,jA,pyramidA,imageB,WIN,0.000001);

good=~isnan(iB);
iA=iA(good);
jA=jA(good);
iB=iB(good);
jB=jB(good);

iB=round(iB);
jB=round(jB);

figure;
imshow(imageA);
hold('on');
axis('image');
plot([jA,jB]',[iA,iB]','r');

end
