% Constructs a sensor object


function g=sensor

% HACK: read images from files
% REFERENCE
% Middlebury College "Art" dataset
% H. Hirschmuller and D. Scharstein. Evaluation of cost functions for 
% stereo matching. In IEEE Computer Society Conference on Computer Vision 
% and Pattern Recognition (CVPR 2007), Minneapolis, MN, June 2007.
im0=rgb2gray(imread('view0.png'));
im1=rgb2gray(imread('view1.png'));
im2=rgb2gray(imread('view2.png'));

g.gray=cat(3,im0,im1,im2);
g.index=[3,4,5];
g.time=[1.2,1.4,1.6];

% HACK: camera focal length should be derived from source data (change as
% needed)
g.focal=100;

g=class(g,'sensor');

return;
