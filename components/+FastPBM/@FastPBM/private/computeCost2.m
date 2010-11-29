% Compute the residual error for each pair of rays
% TODO: ensure that mu=0 unless there is a strong theoretical argument against it
% TODO: supply normpdf without depending on MATLAB toolboxes
function cost = computeCost2(residual, mu, sigma)
  YMax = normpdf(mu, mu, sigma);
  Y = normpdf(residual, mu, sigma);
  Y = Y/YMax;
  cost = sum(-log(Y))/numel(Y);
  % TODO: explain why this is divided by numel(Y)?
end
