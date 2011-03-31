% Compute the residual error for each pair of rays
% TODO: ensure that mu=0 unless there is a strong theoretical argument against it
% TODO: supply normpdf without depending on MATLAB toolboxes
function cost = computeCost2(residual, mu, sigma, maxCost)
  y = sum(((residual-mu)/sigma).^2); % Sum of normalized squared differences 
  Pux = chisqpdf(y,length(residual)); % P(u|x)
  infN = chisqpdf(length(residual)-2,length(residual)); % ||P(u|x)||_inf
  if(infN*exp(-maxCost)<Pux)
    cost = -log(Pux/infN);
  else
    cost = maxCost;
  end
end
