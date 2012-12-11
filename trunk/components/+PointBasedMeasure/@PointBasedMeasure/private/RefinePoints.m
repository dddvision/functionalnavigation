function [points,nonNormalizedMatches]=RefinePoints(points,nonNormalizedMatches)
% reject points with -ve z
[v,i]=find(points(3,:)>0);
points = points(:,i);
nonNormalizedMatches = nonNormalizedMatches(i,:);

% reject points larger than STD_THRES sigma in each direction
STD_THRES = 5;
stndrd=std(points')';
m = mean(points')';
mm = sqrt((points - repmat(m,1,size(points,2))).^2);
[v,i] = find((mm(1,:) <= STD_THRES.*stndrd(1)) & (mm(1,:) <= STD_THRES.*stndrd(2)) & (mm(1,:) <= STD_THRES.*stndrd(3)));
% remove the points out of range ...
points = points(:,i);
nonNormalizedMatches = nonNormalizedMatches(i,:);
