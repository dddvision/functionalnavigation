function prob = normProb(x, mu, sigma)
  prob = exp(-0.5 * ((x - mu)./sigma).^2) ./ (sqrt(2*pi) .* sigma);
end
