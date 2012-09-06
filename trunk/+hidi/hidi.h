#ifndef HIDI_H
#define HIDI_H

#include <cmath>
#include <limits>

#ifndef PI
static const double PI = 4.0*atan(1.0);
#endif
#ifndef EPS
static const double EPS = std::numeric_limits<double>::epsilon();
#endif
#ifndef INF
static const double INF = std::numeric_limits<double>::infinity();
#endif
#ifndef NAN
static const double NAN = sqrt(static_cast<double>(-1.0));
static bool isnan(const double& x)
{
  volatile double y = x;
  return (y!=x);
}
#endif

#ifndef _MSC_VER
#include <stdint.h>
#else
typedef unsigned __int8 uint8_t;
typedef unsigned __int16 uint16_t;
typedef unsigned __int32 uint32_t;
typedef unsigned __int64 uint64_t;
typedef __int8 int8_t;
typedef __int16 int16_t;
typedef __int32 int32_t;
typedef __int64 int64_t;
#endif

#endif
