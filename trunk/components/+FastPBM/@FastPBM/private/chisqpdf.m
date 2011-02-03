function y = chisqpdf(x, nu)
  a = nu/2;
  b = 2^a;
  c = b*gamma(a);
  y = ((x.^(a-1))./exp(x/2))./c;
end