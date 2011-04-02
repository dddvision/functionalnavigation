%  inputs,
%    row : 
%    column : 
%    size : 
%    img : The integral image
%  
%  outputs,
%    an : The haar response in y-direction
%  
% Function is written by D.Kroon University of Twente (July 2010)
function an=IntegralImage_HaarY(row, column, size, img)
  s2 = size/2;
  an = IntegralImage_BoxIntegral(row, column-s2, s2, size, img)-...
    IntegralImage_BoxIntegral(row-s2, column-s2, s2, size, img);
end
     