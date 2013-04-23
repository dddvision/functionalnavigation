#ifndef TOMWGS84_H
#define TOMWGS84_H

#include "+hidi/hidi.h"

/**
 * WGS84 Ellipsoidal Earth model.
 *
 * @note
 * WGS84 Implementation Manual, v.2.4, 1998.
 * WGS84: It's definition and relationship to Local Geodetic Systems. NIMA Technical Report, 3rd ed. 2000.
 * Earth Centered Earth Fixed (ECEF) frame convention:
 *   Axis 1 goes through the equator at the prime meridian
 *   Axis 2 completes the frame using the right-hand-rule
 *   Axis 3 goes through the north pole
 * North East Down (NED) frame convention:
 *   This is an Earth fixed frame tangent to the WGS84 ellipsoid at a given latitude and longitude (undefined at poles)
 *   Axis 1 points North from the frame origin
 *   Axis 2 points East from the frame origin
 *   Axis 3 points Down from the frame origin
 */
namespace tom
{
  class WGS84
  {
  public:
    static const double majorRadius;
    static const double rotationRate;
    static const double minorRadius;
    static const double flattening;
    static const double inverseFlattening;
    static const double c20;
    static const double gm;
  
    /**
     * Ellipsoidal 1/r falloff gravity potential model in local North-East-Down frame.
     * 
     * @param[in]  N     North coordinate in meters
     * @param[in]  E     East coordinate in meters
     * @param[in]  D     Down coordinate in meters
     * @param[in]  gamma Geodetic latitude that defines the NED frame origin in radians
     * @param[out] gN    Gravity component in the north direction
     * @param[out] gE    Gravity component in the east direction
     * @param[out] gD    Gravity component in the down direction
     *
     * @note
     * This gravity model includes centrepetal acceleration.
     */
    static void gravityNED(const double& N, const double& E, const double& D, const double& gamma, double& gN, 
      double& gE, double& gD)
    {
      // precalculations
      double lambda = tom::WGS84::geodeticToGeocentric(gamma);
      double r = tom::WGS84::geocentricRadius(lambda);
      double sgam = sin(gamma);
      double cgam = cos(gamma);
      double slam = sin(lambda);
      double clam = cos(lambda);

      // position relative to the 3-D ellipsoid in Earth-centered frame
      double X = r*clam-sgam*N-cgam*D;
      double Y = E;
      double Z = r*slam+cgam*N-sgam*D;

      // relative longitude
      double theta = atan2(Y, X);
      double sth = sin(theta);
      double cth = cos(theta);

      // gradient of the potential around the 2-D ellipse model   
      double R2 = X*X+Y*Y+Z*Z;
      double XY = sqrt(X*X+Y*Y);

      double gmR2  = tom::WGS84::gm/R2;
      double re2R2 = (tom::WGS84::majorRadius*tom::WGS84::majorRadius)/R2;

      double gR = -gmR2*(1.0+(9.0/2.0*sqrt(5.0)*tom::WGS84::c20)*re2R2*(Z*Z/R2-1.0/3.0));
      double gT = (3.0*sqrt(5.0)*tom::WGS84::c20)*gmR2*re2R2*(XY*Z/R2);

      // gravity viewed in ECEF frame
      double gZ  = gR*slam+gT*clam;
      double gXY = gR*clam-gT*slam+tom::WGS84::rotationRate*tom::WGS84::rotationRate*XY;

      // rotate by longitude
      double gX = gXY*cth;
      double gY = gXY*sth;

      // gravity viewed in NED frame
      gN = -sgam*gX+cgam*gZ;
      gE = gY;
      gD = -cgam*gX-sgam*gZ;
      return;
    }
    
    /**
     * Ellipsoidal 1/r falloff gravity potential model in Earth-Centered-Earth-Fixed frame.
     * 
     * @param[in]  X  First coordinate in meters
     * @param[in]  Y  Second coordinate in meters
     * @param[in]  Z  Third coordinate in meters
     * @param[out] gX Gravity component in the first direction
     * @param[out] gY Gravity component in the second direction
     * @param[out] gZ Gravity component in the third direction
     *
     * @note
     * This gravity model includes centrepetal acceleration.
     */
    static void gravityECEF(const double& X, const double& Y, const double& Z, double& gX, double& gY, double& gZ)
    {
      // relative longitude
      double theta = atan2(Y, X);
      double sth = sin(theta);
      double cth = cos(theta);

      // gradient of the potential around the 2-D ellipse model   
      double R2 = X*X+Y*Y+Z*Z;
      double XY = sqrt(X*X+Y*Y);
      
      double lambda = atan2(Z, XY);
      double slam = sin(lambda);
      double clam = cos(lambda);

      double gmR2  = tom::WGS84::gm/R2;
      double re2R2 = (tom::WGS84::majorRadius*tom::WGS84::majorRadius)/R2;

      double gR = -gmR2*(1.0+(9.0/2.0*sqrt(5.0)*tom::WGS84::c20)*re2R2*(Z*Z/R2-1.0/3.0));
      double gT = (3.0*sqrt(5.0)*tom::WGS84::c20)*gmR2*re2R2*(XY*Z/R2);

      // gravity viewed in ECEF frame
      double gXY = gR*clam-gT*slam+tom::WGS84::rotationRate*tom::WGS84::rotationRate*XY;
      gX = gXY*cth;
      gY = gXY*sth;
      gZ  = gR*slam+gT*clam;
      return;
    }
    
    /**
     * Converts from Longitude-Latitude-Altitude to Earth Centered Earth Fixed coordinates.
     *
     * @param[in]  lon Longitude in radians
     * @param[in]  lat Geodetic latitude in radians
     * @param[in]  alt altitude in meters
     * @param[out] x   First coordinate in meters
     * @param[out] y   Second coordinate in meters
     * @param[out] z   Third coordinate in meters
     *
     * @note
     * http://www.microem.ru/pages/u_blox/tech/dataconvert/GPS.G1-X-00006.pdf (Retrieved 11/30/2009)
     */
    static void llaToECEF(const double& lon, const double& lat, const double& alt, double& x, double& y, double& z)
    {
      double a = tom::WGS84::majorRadius;
      double finv = tom::WGS84::inverseFlattening;
      double b = a-a/finv;
      double a2 = a*a;
      double b2 = b*b;
      double e = sqrt((a2-b2)/a2);
      double slat = sin(lat);
      double clat = cos(lat);
      double N = a/sqrt(1.0-(e*e)*(slat*slat));
      x = (alt+N)*clat*cos(lon);
      y = (alt+N)*clat*sin(lon);
      z = ((b2/a2)*N+alt)*slat;
      return;
    }
    static inline void llaToECEF(const double (&lla)[3], double& x, double& y, double& z)
    {
      tom::WGS84::llaToECEF(lla[0], lla[1], lla[2], x, y, z);
      return;
    }
    static inline void llaToECEF(const double& lon, const double& lat, const double& alt, double (&xyz)[3])
    {
      tom::WGS84::llaToECEF(lon, lat, alt, xyz[0], xyz[1], xyz[2]);
      return;
    }
    static inline void llaToECEF(const double (&lla)[3], double (&xyz)[3])
    {
      tom::WGS84::llaToECEF(lla[0], lla[1], lla[2], xyz[0], xyz[1], xyz[2]);
      return;
    }

    /**
     * Converts Earth Centered Earth Fixed coordinates to Longitude Latitude Height
     *
     * INPUT
     * @param[in]  x   First coordinate in meters
     * @param[in]  y   Second coordinate in meters
     * @param[in]  z   Third coordinate in meters
     * @param[out] lon Longitude in radians
     * @param[out] lat Geodetic latitude in radians
     * @param[out] alt Height above the Earth ellipsoid in meters
     *
     * NOTES
     * J. Zhu, "Conversion of Earth-centered Earth-fixed coordinates to geodetic coordinates," Aerospace and Electronic 
     *   Systems, vol. 30, pp. 957-961, 1994.
     */
    static void ecefToLLA(const double& x, const double& y, const double& z, double& lon, double& lat, double& alt)
    {
      double a = tom::WGS84::majorRadius;
      double finv = tom::WGS84::inverseFlattening;
      double f = 1.0/finv;
      double b = a-a/finv;
      double e2 = 2.0*f-f*f;
      double ep2 = f*(2.0-f)/((1.0-f)*(1.0-f));
      double r2 = x*x+y*y;
      double r = sqrt(r2);
      double E2 = a*a-b*b;
      double F = 54.0*b*b*z*z;
      double G = r2+(1.0-e2)*z*z-e2*E2;
      double c = (e2*e2*F*r2)/(G*G*G);
      double s = pow(1.0+c+sqrt(c*c+2.0*c), 1.0/3.0);
      double P = F/(3.0*pow(s+1.0/s+1.0, 2.0)*G*G);
      double Q = sqrt(1.0+2.0*e2*e2*P);
      double ro = -(e2*P*r)/(1.0+Q)+sqrt((a*a/2.0)*(1.0+1.0/Q)-((1.0-e2)*P*z*z)/(Q*(1.0+Q))-P*r2/2.0);
      double tmp = pow(r-e2*ro, 2.0);
      double U = sqrt(tmp+z*z);
      double V = sqrt(tmp+(1.0-e2)*z*z);
      double zo = (b*b*z)/(a*V);
      lon = atan2(y, x);
      lat = atan2(z+ep2*zo, r);
      alt = U*(1.0-b*b/(a*V));
      return;
    }
    static inline void ecefToLLA(const double (&xyz)[3], double& lon, double& lat, double& alt)
    {
      tom::WGS84::ecefToLLA(xyz[0], xyz[1], xyz[2], lon, lat, alt);
      return;
    }
    static inline void ecefToLLA(const double& x, const double& y, const double& z, double (&lla)[3])
    {
      tom::WGS84::ecefToLLA(x, y, z, lla[0], lla[1], lla[2]);
      return;
    }
    static inline void ecefToLLA(const double (&xyz)[3], double (&lla)[3])
    {
      tom::WGS84::ecefToLLA(xyz[0], xyz[1], xyz[2], lla[0], lla[1], lla[2]);
      return;
    }
    
    /**
     * Convert geocentric angle to geodetic angle.
     *
     * @param[in]  lambda geocentric latitude
     * @return            geodetic latitude
     *
     * @note
     * Returns NAN if input is not in the range [-pi/2 pi/2].
     */
    static double geocentricToGeodetic(const double& lambda)
    {
      double A;
      double gamma;
      if((lambda<-PI/2.0)|(lambda>PI/2.0))
      {
        gamma = NAN;
      }
      else
      {
        A = tom::WGS84::majorRadius/tom::WGS84::minorRadius;
        gamma = atan2((A*A)*sin(lambda), cos(lambda));
      }
      return (gamma);
    }
    
    /**
     * Convert geodetic angle to geocentric angle.
     *
     * @param[in]  gamma  geodetic latitude
     * @return            geocentric latitude
     *
     * @note
     * Returns NAN if input is not in the range [-pi/2 pi/2].
     */
    static double geodeticToGeocentric(const double& gamma)
    {
      double lambda;
      if((gamma<-PI/2.0)|(gamma>PI/2.0))
      {
        lambda = NAN;
      }
      else
      {
        lambda = atan2(pow(tom::WGS84::minorRadius/tom::WGS84::majorRadius, 2.0)*sin(gamma), cos(gamma));
      }
      return (lambda);
    }

    /**
     * Radius from center of ellipse to point on the ellipse at a geocentric angle from the major axis.
     * 
     * @param[in]  lambda Geocentric latitude in radians
     * @param[out] radius Radius in meters
     */
    static double geocentricRadius(const double& lambda)
    {
      double A = tom::WGS84::majorRadius*sin(lambda);
      double B = tom::WGS84::minorRadius*cos(lambda);
      double radius = (tom::WGS84::majorRadius*tom::WGS84::minorRadius)/sqrt(A*A+B*B);
      return (radius);
    }
    
    /**
     * Radius from center of ellipse to point on the ellipse at a geodetic angle from the major axis.
     * 
     * @param[in]  gamma  Geodetic latitude in radians
     * @param[out] radius Radius in meters
     */
    static double geodeticRadius(const double& gamma)
    {
      double lambda = tom::WGS84::geodeticToGeocentric(gamma);
      double A = tom::WGS84::majorRadius*sin(lambda);
      double B = tom::WGS84::minorRadius*cos(lambda);
      double radius = (tom::WGS84::majorRadius*tom::WGS84::minorRadius)/sqrt(A*A+B*B);
      return (radius);
    }
  };
  // primary source values
  const double WGS84::majorRadius = 6378137.0; // meters
  const double WGS84::rotationRate = 7.2921151467e-5; // rad/sec
  const double WGS84::gm = 3.986005E14; // meters^3/sec^2
  const double WGS84::flattening = 1.0/298.257223563; // unitless
  // const double WGS84::surfacePotential = 62636851.7146; // meters^2/sec^2

  // derived values
  const double WGS84::inverseFlattening = 298.257223563; // unitless
  const double WGS84::c20 = -4.84166E-4; // unitless (combined sources)
  const double WGS84::minorRadius = tom::WGS84::majorRadius-tom::WGS84::majorRadius/tom::WGS84::inverseFlattening; // meters (Implementation Manual)
  // const double WGS84::polarGravity = -9.8321849378; // meters/sec^2 (NIMA)
  // const double WGS84::polarGravity = -9.8322131433; // meters/sec^2 (Draper)
  // const double WGS84::equatorialGravity = -9.7803253359-(tom::WGS84::rotationRate*tom::WGS84::rotationRate*1000000)*(tom::WGS84::majorRadius/1000000); // meters/sec^2 (combined sources)
  // const double WGS84::equatorialGravity = -9.78049-(tom::WGS84::rotationRate*tom::WGS84::rotationRate*1000000)*(tom::WGS84::majorRadius/1000000); // meters/sec^2 (Draper)
  // const double WGS84::equatorialGravity = -9.8144057073; // meters/sec^2 (Draper)
}

#endif
