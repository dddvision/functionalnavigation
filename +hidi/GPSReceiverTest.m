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
      trueX = trueECEF(1, :);
      trueY = trueECEF(2, :);
      trueZ = trueECEF(3, :);
      [trueLon, trueLat, trueAlt] = earth.WGS84.ecefToLLA(trueX, trueY, trueZ);
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
      gpsLon = gpsLonLatAlt(1, :);
      gpsLat = gpsLonLatAlt(2, :);
      gpsAlt = gpsLonLatAlt(3, :);
      [gpsX, gpsY, gpsZ] = earth.WGS84.llaToECEF(gpsLon, gpsLat, gpsAlt);
      gpsECEF = [gpsX; gpsY; gpsZ];
      errECEF = gpsECEF-trueECEF;
      Raxes = [0, 0, -1;0, 1, 0;1, 0, 0];
      R = tom.Rotation.eulerToMatrix(0, -trueLonLatAlt(2, 1), trueLonLatAlt(1, 1))*Raxes;
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
