%  inputs,
%    row : 
%    column : 
%    size : 
%    img : 
%  
%  outputs,
%    an : 
%  
% Function is written by D.Kroon University of Twente (July 2010)
function an = IntegralImage_HaarX(row, column, size, img)
  s2 = size/2;
  an = IntegralImage_BoxIntegral(row-s2, column, size, s2, img)-...
    IntegralImage_BoxIntegral(row-s2, column-s2, size, s2, img);
end
