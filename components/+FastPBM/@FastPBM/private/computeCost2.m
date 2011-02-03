% Compute the residual error for each pair of rays
% TODO: ensure that mu=0 unless there is a strong theoretical argument against it
% TODO: supply normpdf without depending on MATLAB toolboxes
function cost = computeCost2(residual, mu, sigma)
  y = sum( ( (residual - mu)/sigma ).^2 ); % Sum of normalized squared differences 
  Pux = chi2pdf(y,length(residual)); % P(u|x)
  infN = chi2pdf(length(residual)-2,length(residual)); % ||P(u|x)||_inf
  cost = -log(Pux/infN);
  
  %YMax = normProb(mu, mu, sigma);
  %Y = normProb(residual, mu, sigma);
  %Y = Y/YMax;
  %cost = sum(-log(Y))/numel(Y);
  % TODO: explain why this is divided by numel(Y)?
end
