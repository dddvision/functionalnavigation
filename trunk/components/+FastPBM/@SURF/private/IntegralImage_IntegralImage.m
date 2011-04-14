function pic=IntegralImage_IntegralImage(I)
  pic = cumsum(cumsum(I,1),2);
end
