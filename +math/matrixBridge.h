#ifndef MATHMATRIXBRIDGE_H
#define MATHMATRIXBRIDGE_H

#include "+hidi/hidiBridge.h"
#include "+math/matrix.h"

namespace math
{
  void convert(const mxArray* array, math::matrix& value)
  {
    double* data;
    size_t M;
    size_t N;
    size_t k;
    hidi::checkDouble(array);
    data = static_cast<double*>(mxGetData(array));
    M = mxGetM(array);
    N = mxGetN(array);
    value.resize(M, N);
    for(k = 0; k<(M*N); ++k)
    {
      value(k) = data[k];
    }
    return;
  }
  
  void convert(const math::matrix& value, mxArray*& array)
  {
    size_t M;
    size_t N;
    size_t k;
    M = value.rows();
    N = value.cols();
    array = mxCreateNumericMatrix(M, N, mxDOUBLE_CLASS, mxREAL);
    for(k = 0; k<(M*N); ++k)
    {
      static_cast<double*>(mxGetData(array))[k] = value(k);
    }
    return;
  }
}

#endif
