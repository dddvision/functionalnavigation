% Normalises array of homogeneous coordinates to a scale of 1
%
% Usage: nx = hnormalise(x)
%
% Argument:
%   x - an Nxnpts array of homogeneous coordinates.
%
% Returns:
%   nx - an Nxnpts array of homogeneous coordinates rescaled so
%        that the scale values nx(N,:) are all 1.
%
% Note that any homogeneous coordinates at infinity (having a scale value of 0) are left unchanged.
%
% Peter Kovesi  
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/~pk
function nx = hnormalise(x)
  rows = size(x, 1);
  nx = x;

  % Find the indices of the points that are not at infinity
  finiteind = find(abs(x(rows, :)) > eps);

  % Normalise points not at infinity
  for r = 1:rows-1
   nx(r, finiteind) = x(r, finiteind)./x(rows, finiteind);
  end
  nx(rows, finiteind) = 1;
end
