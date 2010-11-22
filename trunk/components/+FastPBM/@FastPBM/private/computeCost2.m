function cost=computeCost2(this, model,T,rayA,rayB)
% Calculate the error for each ray-pair
N = zeros(3,size(rayA,2));
Errors = zeros(1,size(rayB,2));
for indVec=1:size(rayA,2)
    
    % calculate the normal to the epipolar plane
    N(:,indVec) = cross(T,rayA(:,indVec));
    
    % normalize vectors
    n = N(:,indVec)./norm(N(:,indVec));
    x = rayB(:,indVec)/norm(rayB(:,indVec));
    
    % calculate the error
    Errors(indVec) = n'*x;
end

% load the model and use that to get the cost
M = model.parameters(1);
S = model.parameters(2);
YMax = normpdf(M,M,S);
Y = normpdf(Errors,M,S);
Y = Y./YMax;
cost = sum(-log(Y))./length(Y);

