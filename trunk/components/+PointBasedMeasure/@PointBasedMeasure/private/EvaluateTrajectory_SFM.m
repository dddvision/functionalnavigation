% SFM based trajectory evaluation 
% Omar Oreifej, UCF, 12/16/2009
% Last Modified, 6/29/2010
%-------------------------------------------------------------
function [intermediateData] = EvaluateTrajectory_SFM(im1,im2)

% Todo: remove intrinsic parameters' calculation once received by the interface ...
f = 5; % in mm
sensor_size = 5.27; % in mm
im_width  = size(im1,2);
im_height = size(im1,1);
center = [im_width./2,im_height./2];
scale = im_width./sensor_size; % pixels per millimeter
f_pix = f.*scale; % focal length in pixels

if(PointBasedMeasure.PointBasedMeasureConfig.MatchingAlgo==1)
    [r1 r2] = MEXSURF(double(im1), double(im2), double(.8));
    F_ERR_THRESHOLD = .0001;

    % Add 1 to convert from C to matlab convention
    nonNormalizedMatches=[];
    nonNormalizedMatches(:,1)=r1(:,1)+1;
    nonNormalizedMatches(:,2)=r1(:,2)+1;
    nonNormalizedMatches(:,3)=r2(:,1)+1;
    nonNormalizedMatches(:,4)=r2(:,2)+1;
end
p1 = [nonNormalizedMatches(:,1:2)]';
p2 = [nonNormalizedMatches(:,3:4)]';

[F, inliers] = ransacfitfundmatrix(p1, p2, F_ERR_THRESHOLD,0);
nonNormalizedMatches = nonNormalizedMatches(inliers,:);

% Compute homography to fundemental matrix inliers ratio
[H, inliers2] = ransacfithomography(p1, p2, .001,0);  
FHRatio = length(inliers2)./length(inliers);  
 
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

% Get E,R,T
p = [normalizedMatches(:,1:2) ones(length(normalizedMatches),1)]';
q =[normalizedMatches(:,3:4) ones(length(normalizedMatches),1)]';
[Tt,Rt,E]  = dessential(p,q);

% Triangulate
P1 = k1*[eye(3,3), [0;0;0]];
P2 = k2*[Rt Tt];
points = [];
for pIndex=1:size(nonNormalizedMatches,1)
    X1 =nonNormalizedMatches(pIndex,1:2);
    X2 = nonNormalizedMatches(pIndex,3:4);
    X = compute3D_omar(X1,X2,P1,P2);
    X = X./X(4);
    points(:,pIndex) = X(1:3);
end

intermediateData = struct(  'points', points, ...
                            'nonNormalizedMatches', nonNormalizedMatches, ...
                            'normalizedMatches', normalizedMatches, ...
                            'P1',P1, ...
                            'P2',P2, ...
                            'k1',k1, ...
                            'Tt',Tt, ...
                            'Rt',Rt, ...
                            'FHRatio',FHRatio, ...
                            'imageA',im1, ...
                            'imageB',im2);