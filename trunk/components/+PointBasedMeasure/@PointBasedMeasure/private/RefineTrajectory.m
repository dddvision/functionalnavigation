function [ data,intermediateData ] = RefineTrajectory( intermediateData )
%REFINETRAJECTORY excludes outliers and runs sparse bundle adjustment(SBA)
%   Once image pair has been determined to be a vailed pair to use this
%   algorithm with, the rest of the computation is preformed from a cache

% Exclude way-off points
[points,nonNormalizedMatches]=RefinePoints(intermediateData.points,intermediateData.nonNormalizedMatches);

% SBA
Wframes = cat(3,nonNormalizedMatches(:,1:2)',nonNormalizedMatches(:,3:4)');
Pframes = cat(3,intermediateData.P1,intermediateData.P2);
[corrS corrP corrK corrR corrT] = bundleAdjustment( 1, 1, Wframes, points, 'P0', Pframes,'nItrSBA', 1000 );



%% Exclude points with bad reprojection
P1 = corrP(:,:,1);
P2 = corrP(:,:,2);
REPROJ_THRESH = .3;
err1 = [];
err2 = [];
for pIndex=1:size(corrS,2)
    m = [corrS(:,pIndex);1];
    mp = P1*m;
    mp = mp./mp(3);
    err1(pIndex) = norm(nonNormalizedMatches(pIndex,1:2) - mp(1:2)');
    
    mp = P2*m;
    mp = mp./mp(3);
    err2(pIndex) = norm(nonNormalizedMatches(pIndex,3:4) - mp(1:2)'); 
end
ind = find((err1< REPROJ_THRESH) & (err2<REPROJ_THRESH));
corrS = corrS(:,ind);
intermediateData.nonNormalizedMatches = nonNormalizedMatches(ind,:);
intermediateData.normalizedMatches = intermediateData.normalizedMatches(ind,:);
intermediateData.points = intermediateData.points(:,ind);

data = struct(  'corrS',corrS, ...
    'corrP',corrP, ...
    'corrK',corrK, ...
    'corrR',corrR, ...
    'corrT',corrT, ...
    'nonNormalizedMatches',intermediateData.nonNormalizedMatches, ...
    'normalizedMatches',intermediateData.normalizedMatches, ...
    'imageA',intermediateData.imageA, ...
    'imageB',intermediateData.imageB);

end