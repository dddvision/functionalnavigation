% Demo for SFM based trajectory evaluation 
% Omar Oreifej, UCF, 12/16/2009
%-------------------------------------------------------------

function cost = demo()

clear;
clc;
close all;

PATH = [pwd '\'];
IMAGE_TYPE = 'png';
d = dir([PATH '*.' IMAGE_TYPE]);
imageIndex = 1;
imPath1 = [PATH d(imageIndex).name];
imPath2 = [PATH d(imageIndex+1).name];

% example candidate trajectory
tr.Translation = [-1.0002,0.0004,0.0256];
tr.Rotation = [0.0000,0.0000,0.1000];

cost = EvaluateTrajectory_SFM(tr,imPath1,imPath2);

end
%-------------------------------------------------------------