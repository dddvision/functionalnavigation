function gray=gray_image_init
% HACK: read images from files
% REFERENCE
% Middlebury College "Art" dataset
% H. Hirschmuller and D. Scharstein. Evaluation of cost functions for 
% stereo matching. In IEEE Computer Society Conference on Computer Vision 
% and Pattern Recognition (CVPR 2007), Minneapolis, MN, June 2007.
im0=rgb2gray(imread('view0.png'));
im1=rgb2gray(imread('view1.png'));
im2=rgb2gray(imread('view2.png'));
gray=cat(3,im0,im1,im2);
end
