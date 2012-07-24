% For each valid index in the GPS data domain, evaluate the reference
%   trajectory and compare with the reported GPS position
classdef GPSReceiverTest
  methods (Access = public, Static = true)
    function this = GPSReceiverTest(gpsHandle, trajectory)
      assert(isa(gpsHandle, 'hidi.GPSReceiver'));
      if(~gpsHandle.hasData())
        return;
      end

      na = gpsHandle.first();
      nb = gpsHandle.last();
      assert(isa(na, 'uint32'));
      assert(isa(nb, 'uint32'));

      K = 1+nb-na;
      gpsLonLatAlt = zeros(3, K);
      trueECEF = zeros(3, K);
      for indx = 1:K
        currTime = gpsHandle.getTime(indx);
        pose = trajectory.evaluate(currTime);
        trueECEF(:, indx) = cat(2, pose.p);
        [gpsLonLatAlt(1, indx), gpsLonLatAlt(2, indx), gpsLonLatAlt(3, indx)] = gpsHandle.getGlobalPosition(na+indx-1);
      end
      [trueLon, trueLat, trueAlt] = tom.WGS84.ecef2lolah(trueECEF(1, :), trueECEF(2, :), trueECEF(3, :));
      trueLonLatAlt = [trueLon; trueLat; trueAlt];
      errLonLatAlt = gpsLonLatAlt-trueLonLatAlt;

      figure;
      hist(errLonLatAlt(1, :));
      title('GPS error (longitude)');

      figure;
      hist(errLonLatAlt(2, :));
      title('GPS error (latitude)');

      figure;
      hist(errLonLatAlt(3, :));
      title('GPS error (altitude)');

      figure;
      [gpsX, gpsY, gpsZ] = tom.WGS84.lolah2ecef(gpsLonLatAlt(1, :), gpsLonLatAlt(2, :), gpsLonLatAlt(3, :));
      gpsECEF = [gpsX; gpsY; gpsZ];
      errECEF = gpsECEF-trueECEF;
      Raxes = [0, 0, -1;0, 1, 0;1, 0, 0];
      R = Euler2Matrix([0;-trueLonLatAlt(2, 1);trueLonLatAlt(1, 1)])*Raxes;
      errNED = R*errECEF;
      plot3(errNED(1, :), errNED(2, :), errNED(3, :), 'b.');
      title('GPS error (scatter plot)');
      xlabel('north (meters)');
      ylabel('east (meters)');
      zlabel('down (meters)');
      axis('equal');
      drawnow;
    end
  end
end

% Converts rotation from Euler to matrix form
function M = Euler2Matrix(Y)
  Y1 = Y(1);
  Y2 = Y(2);
  Y3 = Y(3);
  c1 = cos(Y1);
  c2 = cos(Y2);
  c3 = cos(Y3);
  s1 = sin(Y1);
  s2 = sin(Y2);
  s3 = sin(Y3);
  M = zeros(3);
  M(1, 1) = c3.*c2;
  M(1, 2) = c3.*s2.*s1-s3.*c1;
  M(1, 3) = s3.*s1+c3.*s2.*c1;
  M(2, 1) = s3.*c2;
  M(2, 2) = c3.*c1+s3.*s2.*s1;
  M(2, 3) = s3.*s2.*c1-c3.*s1;
  M(3, 1) = -s2;
  M(3, 2) = c2.*s1;
  M(3, 3) = c2.*c1;
end
