import math


class WGS84:
    # WGS84 Ellipsoidal Earth model.
    #
    # Note
    # WGS84 Implementation Manual, v.2.4, 1998.
    majorRadius = 6378137.0  # meters
    rotationRate = 7.2921151467e-5  # rad/sec
    gm = 3.986005e14  # meters^3/sec^2
    flattening = 1.0 / 298.257223563  # unitless
    inverseFlattening = 298.257223563  # unitless
    c20 = -4.84166e-4  # unitless (combined sources)
    minorRadius = majorRadius - majorRadius / inverseFlattening  # meters (Implementation Manual)

    @staticmethod
    def geodeticToGeocentric(gamma):
        # Convert geodetic angle to geocentric angle
        #
        # Input
        # gamma :  geodetic latitude in radians
        #
        # Output
        # lam :  geocentric latitude in radians
        #
        # Note
        # Returns NAN if input is not in the range [-pi/2 pi/2].
        halfpi = math.pi / 2.0
        if (gamma < -halfpi) or (gamma > halfpi):
            lam = float("nan")
        else:
            ratio = WGS84.minorRadius, WGS84.majorRadius
            lam = math.atan2(ratio * ratio * math.sin(gamma), math.cos(gamma))
        return lam

    @staticmethod
    def geocentricRadius(lam):
        # Radius from center of ellipse to point on the ellipse at a geocentric angle from the major axis
        #
        # Input
        # lambda : geocentric latitude in radians
        #
        # Output
        # radius : radius in meters
        A = WGS84.majorRadius * math.sin(lam)
        B = WGS84.minorRadius * math.cos(lam)
        radius = (WGS84.majorRadius * WGS84.minorRadius) / math.sqrt(A * A + B * B)
        return radius

    @staticmethod
    def geodeticRadius(gamma):
        # Radius from center of ellipse to point on the ellipse at a geodetic angle from the major axis
        #
        # Input
        # gamma :  geodetic latitude in radians
        #
        # Output
        # radius : radius in meters
        lam = WGS84.geodeticToGeocentric(gamma)
        radius = WGS84.geocentricRadius(lam)
        return radius
