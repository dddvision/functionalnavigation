#ifndef HIDITIMEINTERVALBRIDGE_H
#define HIDITIMEINTERVALBRIDGE_H

#include "hidiBridge.h"

namespace hidi
{
  void convert(const mxArray* array, hidi::TimeInterval& value)
  {
    static mxArray *first;
    static mxArray *second;
    static mxArray *firstDouble;
    static mxArray *secondDouble;
    first = mxGetProperty(array, 0, "first");
    second = mxGetProperty(array, 0, "second");
    mexCallMATLAB(1, &firstDouble, 1, &first, "double");
    mexCallMATLAB(1, &secondDouble, 1, &second, "double");
    value.first = (*static_cast<double*>(mxGetData(firstDouble)));
    value.second = (*static_cast<double*>(mxGetData(secondDouble)));
    mxDestroyArray(first);
    mxDestroyArray(second);
    mxDestroyArray(firstDouble);
    mxDestroyArray(secondDouble);
    return;
  }
  
  void convert(const hidi::TimeInterval& timeInterval, mxArray* array)
  {
    mxArray* first;
    mxArray* second;
    mxArray* interval[2];
    first = mxCreateDoubleScalar(timeInterval.first);
    second = mxCreateDoubleScalar(timeInterval.second);
    interval[0] = first;
    interval[1] = second;
    mexCallMATLAB(1, &array, 2, interval, "hidi.TimeInterval");
    mxDestroyArray(first);
    mxDestroyArray(second);
    return;
  }  
}
#endif
