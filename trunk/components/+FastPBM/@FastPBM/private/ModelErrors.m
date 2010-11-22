function model = ModelErrors(T, rays)
Vectors1 = rays(1:3,:);
Vectors2 = rays(4:6,:);

%% Calculate the error for each ray-pair
N = zeros(3,size(Vectors1,2));
Errors = zeros(1,size(Vectors1,2));
for indVec=1:size(Vectors1,2)
    
    % calculate the normal to the epipolar plane
    N(:,indVec) = cross(T,Vectors1(:,indVec));
    
    % normalize vectors
    n = N(:,indVec)./norm(N(:,indVec));
    x = Vectors2(:,indVec)/norm(Vectors2(:,indVec));
    
    % calculate the error
    Errors(indVec) = n'*x;
end

% %% Histogram the errors
% SEP = (ErrorsMax - ErrorsMin)/1000;
% ErrorsMin = min(Errors);
% ErrorsMax = max(Errors);
% range = (ErrorsMin:SEP:ErrorsMax);
% [N,X] = hist(Errors,range);
% Nn = N./max(N);

%% Model with a Gaussian
[M,S] = normfit(Errors);
%     Y = NORMPDF(range,M,S);
%     Y = Y./max(Y);
%     figure(1),clf;
%     plot(range,Y,'.');
%     hold on;
%     plot(range,Nn,'.','Color','r');
%     hold off;
%     legend('Gaussian','Data');
%     SSE1 = sum((Nn-Y).^2)./length(range);
%     title(sprintf('SSE = %.4d%',SSE1));
%
%     %% Model with KDE
%     f = ksdensity(Errors,range);
%     f = f./max(f);
%     figure(3),clf;
%     plot(range,f,'.');
%     hold on;
%     plot(range,Nn,'.','Color','r');
%     hold off;
%     legend('KDE','Data');
%     SSE2 = sum((Nn-f).^2)./length(range);
%     title(sprintf('SSE = %.4d%',SSE2));

%TODO: Omar add a method to save the model into this varaible
%      if you need multiple variables, use a struct
model = [];
model.parameters(1) = M;
model.parameters(2) = S;
end