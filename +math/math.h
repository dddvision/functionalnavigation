#ifndef MATHMATH_H
#define MATHMATH_H

#include <cmath>

namespace math
{
  static const double PI = 4.0*atan(1.0);
  static const double RADTODEG = 180.0/math::PI;
  static const double DEGTORAD = math::PI/180.0;
  static const double FTTOM = 0.3048;
  static const double MTOFT = 1.0/0.3048;
  static const double KTTOFPS = 1.852/1.09728;
  static const double FPSTOKT = 1.09728/1.852;
  static const double FTTONMI = 0.3048/1852.0;
  static const double NMITOFT = 1852.0/0.3048;
}

#endif
