// Copyright 2011 Scientific Systems Company Inc., New BSD License
#ifndef HIDIHIDI_H
#define HIDIHIDI_H

#ifndef NOMINMAX
#define NOMINMAX
#endif

#include <cmath>
#include <limits>
#include <string>
#include <vector>

#ifndef EPS
static const double EPS = std::numeric_limits<double>::epsilon();
#endif
#ifndef INF
static const double INF = std::numeric_limits<double>::infinity();
#endif
#ifndef NAN
static const double NAN = sqrt(static_cast<double>(-1.0));
#endif

#if defined(__APPLE__) || defined(_MSC_VER)
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
typedef __int8 int8_t;
typedef unsigned __int16 uint16_t;
typedef __int16 int16_t;
typedef unsigned __int32 uint32_t;
typedef __int32 int32_t;
#if defined(__LP64__) || defined(_LP64)
typedef unsigned __int64 uint64_t;
typedef __int64 int64_t;
typedef uint64_t uintptr_t;
#else
typedef uint32_t uintptr_t;
#endif
#endif

#ifdef _MSC_VER
#include <fcntl.h>
#include <io.h>
class _SetOutputModeBinary
{
public:
  _SetOutputModeBinary(void)
  {
    _setmode(_fileno(stdout), _O_BINARY);
  }
};
_SetOutputModeBinary _setOutputModeBinary;
#endif

namespace hidi
{
  // Prints a platform-independent newline.
  //
  // @param[in] stream output file stream (default = stdout)
  void newline(FILE* stream = stdout)
  {
#ifdef MATLAB_MEX_FILE
    if(stream==stdout)
    {
      printf("\n");
    }
    else
    {
      fprintf(stream, "\x0d\x0a");
    }
#else
    fprintf(stream, "\x0d\x0a");
#endif
    return;
  }
}

#endif
