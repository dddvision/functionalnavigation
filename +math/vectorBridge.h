#ifndef MATHVECTORBRIDGE_H
#define MATHVECTORBRIDGE_H

#include "+hidi/hidiBridge.h"
#include "+math/vector.h"

namespace math
{
  void convert(const mxArray* array, math::vector& value)
  {
    double* data;
    size_t n;
    size_t N;
    hidi::checkDouble(array);
    data = static_cast<double*>(mxGetData(array));
    N = mxGetNumberOfElements(array);
    value.resize(N);
    for(n = 0; n<N; ++n)
    {
      value(n) = data[n];
    }
    return;
  }
  
  void convert(const math::vector& value, mxArray*& array)
  {
    size_t M;
    size_t m;
    M = value.size();
    array = mxCreateNumericMatrix(M, 1, mxDOUBLE_CLASS, mxREAL);
    for(m = 0; m<M; ++m)
    {
      static_cast<double*>(mxGetData(array))[m] = value(m);
    }
    return;
  }
}

#endif
