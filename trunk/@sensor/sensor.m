function g=sensor

% HACK: read images from the middlebury stereo dataset
im0=rgb2gray(imread('view0.png'));
im1=rgb2gray(imread('view1.png'));
im2=rgb2gray(imread('view2.png'));

g.gray=cat(3,im0,im1,im2);
g.index=[3,4,5];
g.time=[1.2,1.4,1.6];

g=class(g,'sensor');

return;
