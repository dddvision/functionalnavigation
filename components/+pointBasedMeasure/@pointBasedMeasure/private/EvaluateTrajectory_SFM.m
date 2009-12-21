% SFM based trajectory evaluation 
% Omar Oreifej, UCF, 12/16/2009
%-------------------------------------------------------------
function [cost] = EvaluateTrajectory_SFM(im1,im2,tr)

% Parameters
f = 5; % in mm
sensor_size = 5.27; % in mm

global nonNormalizedMatches;
global normalizedMatches;
global k1;
global k2;

% calculate intrinsic parameters
im_width  = size(im1,2);
im_height = size(im1,1);
center = [im_width./2,im_height./2];
scale = im_width./sensor_size; % pixels per millimeter
f_pix = f.*scale; % focal length in pixels

% calc the matches
currentDirectory=pwd;
localDir=fileparts(mfilename('fullpath'));
cd(localDir); 
[nonNormalizedMatches im1 im2] = sift_match(im1, im2);
cd(currentDirectory);
F_ERR_THRESHOLD = .00005;

p1 = [nonNormalizedMatches(:,1:2)]';
p2 = [nonNormalizedMatches(:,3:4)]';
[F, inliers] = ransacfitfundmatrix(p1, p2, F_ERR_THRESHOLD,1);
nonNormalizedMatches = nonNormalizedMatches(inliers,:);

% plot the matches between images
PlotMatches_omar(im1,im2,nonNormalizedMatches);


% compute k
k1 =[f_pix  0      center(1);
    0   f_pix      center(2);
    0   0      1];

k1inv = inv(k1);
k2 = k1;
k2inv = inv(k2);

newMatches1 = [nonNormalizedMatches(:,1:2) ones(length(nonNormalizedMatches),1)];
newMatches2 = [nonNormalizedMatches(:,3:4) ones(length(nonNormalizedMatches),1)];
newMatches1 = (k1inv * newMatches1')';
newMatches2 = (k2inv * newMatches2')';
normalizedMatches = [newMatches1(:,1:2) newMatches2(:,1:2)];

%% Get E,R,T
p = [normalizedMatches(:,1:2) ones(length(normalizedMatches),1)]';
q =[normalizedMatches(:,3:4) ones(length(normalizedMatches),1)]';

[Tt,Rt,E]  = dessential(p,q);

points = [];
P1 = k1*[eye(3,3), [0;0;0]];
P2 = k2*[Rt Tt];
for pIndex=1:size(nonNormalizedMatches,1)
    X1 =nonNormalizedMatches(pIndex,1:2);
    X2 = nonNormalizedMatches(pIndex,3:4);
    X = compute3D_omar(X1,X2,P1,P2);
    X = X./X(4);
    points(:,pIndex) = X(1:3);
end;

Wframes = cat(3,nonNormalizedMatches(:,1:2)',nonNormalizedMatches(:,3:4)');
Pframes = cat(3,P1,P2);
[corrS corrP corrK corrR corrT] = bundleAdjustment( 1, 1, Wframes, points, 'P0', Pframes,'nItrSBA', 1000 );
PlotMatches_omar(im1,im2,nonNormalizedMatches);
Plot_Reporjection_omar(nonNormalizedMatches,corrS,corrP,corrK,corrR,corrT,im1,im2);


%% Calcuate cost
r1 = tr.Rotation;
t1 = tr.Translation;
[th1_2 th2_2 th3_2]=rotationMatrix(corrR(:,:,2));
r2 = pi- [th1_2 th2_2 th3_2];
t1 = t1./norm(t1);
t2 = corrT(:,2);
t2 = t2./norm(t2);
t2 = t2';
maxr = 9.4248; %(3.*pi)
maxt = 2;
cost = ((sum(abs(r1-r2))./maxr) + (sum(abs(t1-t2))./maxt))./2; 



