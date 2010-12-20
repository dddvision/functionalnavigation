% Convert from Longitude Latitude Height to Earth Centered Earth Fixed coordinates
%
% @param[in]  lolah position in longitude, latitude and height, radians and meters, (MATLAB: 3-by-N)
% @param[out] ecef  position in Earth Centered Earth Fixed coordinates, meters, (MATLAB: 3-by-N)
%
% NOTES
% http://www.microem.ru/pages/u_blox/tech/dataconvert/GPS.G1-X-00006.pdf
%   Retrieved 11/30/2009
function ecef = lolah2ecef(lolah)
  lon = lolah(1, :);
  lat = lolah(2, :);
  alt = lolah(3, :);
  a = 6378137;
  finv = 298.257223563;
  b = a-a/finv;
  a2 = a.*a;
  b2 = b.*b;
  e = sqrt((a2-b2)./a2);
  slat = sin(lat);
  clat = cos(lat);
  N = a./sqrt(1-(e*e)*(slat.*slat));
  ecef = [(alt+N).*clat.*cos(lon);
          (alt+N).*clat.*sin(lon);
          ((b2./a2)*N+alt).*slat];
end

