#ifndef HIDIBRIDGE_H
#define HIDIBRIDGE_H

#include <cstdio>
#include "mex.h" // must follow cstdio and precede custom headers for printf to work
#include "hidi.h"

namespace hidi
{
  void callMATLAB(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[], const char *functionName)
  {
    mxArray* exception;
    exception = mexCallMATLABWithTrap(nlhs, plhs, nrhs, prhs, functionName);
    if(exception!=NULL)
    {
      mexCallMATLAB(0, NULL, 1, &exception, "throw");
    }
    return;
  }

  typedef void (*MEXFunctionWithCatchCallback)(int, mxArray**, int, const mxArray**);
  void mexFunctionWithCatch(MEXFunctionWithCatchCallback mexFunctionWithCatchCallback, int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
  {
    std::string message;
    try
    {
      mexFunctionWithCatchCallback(nlhs, plhs, nrhs, prhs);
    }
    catch(std::exception& e)
    {
      message = "ERROR: ";
      message = message+e.what();
      mexErrMsgTxt(message.c_str());
    }
    catch(const char* str)
    {
      message = "ERROR: ";
      message = message+str;
      mexErrMsgTxt(message.c_str());
    }
    catch(...)
    {
      message = "ERROR: ";
      message = message+"Unhandled exception.";
      mexErrMsgTxt(message.c_str());
    }
    return;
  }
  
  void checkNumArgs(const int& narg, const int& n)
  {
    if(n>narg)
    {
      throw("Too few input arguments.");
    }
    return;
  }
  
  void checkNumElements(const mxArray* array, const size_t& n)
  {
    if(mxGetNumberOfElements(array)!=n)
    {
      throw("Incorrect number of elements.");
    }
    return;
  }
  
  void checkNumRows(const mxArray* array, const size_t& m)
  {
    if(mxGetM(array)!=m)
    {
      throw("Incorrect number of rows.");
    }
    return;
  }
  
  void checkNumCols(const mxArray* array, const size_t& n)
  {
    if(mxGetN(array)!=n)
    {
      throw("Incorrect number of columns.");
    }
    return;
  }

  void checkDouble(const mxArray* array)
  {
    if((mxGetClassID(array)!=mxDOUBLE_CLASS))
    {
      throw("Must be type double.");
    }
    return;
  }

  void checkFloat(const mxArray* array)
  {
    if((mxGetClassID(array)!=mxSINGLE_CLASS))
    {
      throw("Must be type single.");
    }
    return;
  }
 
  void checkUInt32(const mxArray* array)
  {
    if((mxGetClassID(array)!=mxUINT32_CLASS))
    {
      throw("Must be type uint32.");
    }
    return;
  }

  void checkUInt16(const mxArray* array)
  {
    if((mxGetClassID(array)!=mxUINT16_CLASS))
    {
      throw("Must be type uint16.");
    }
    return;
  }

  void checkUInt8(const mxArray* array)
  {
    if((mxGetClassID(array)!=mxUINT8_CLASS))
    {
      throw("Must be type uint8.");
    }
    return;
  }

  void checkInt32(const mxArray* array)
  {
    if((mxGetClassID(array)!=mxINT32_CLASS))
    {
      throw("Must be type int32.");
    }
    return;
  }

  void checkInt16(const mxArray* array)
  {
    if((mxGetClassID(array)!=mxINT16_CLASS))
    {
      throw("Must be type int16.");
    }
    return;
  }

  void checkInt8(const mxArray* array)
  {
    if((mxGetClassID(array)!=mxINT8_CLASS))
    {
      throw("Must be type int8.");
    }
    return;
  }

  void checkBool(const mxArray* array)
  {
    if((mxGetClassID(array)!=mxLOGICAL_CLASS))
    {
      throw("Must be type logical.");
    }
    return;
  }

  void checkString(const mxArray* array)
  {
    if((mxGetClassID(array)!=mxCHAR_CLASS))
    {
      throw("Must be type char.");
    }
    return;
  }
  
  void checkClass(const mxArray* array, const std::string& className)
  {
    static std::string err;
    if(!mxIsClass(array, className.c_str()))
    {
      err = "Must be type "+className;
      err = err+".";
      throw(err.c_str());
    }
    return;
  }

  void convert(const mxArray* array, double& value)
  {
    checkDouble(array);
    value = (*static_cast<double*>(mxGetData(array)));
    return;
  }

  void convert(const mxArray* array, float& value)
  {
    checkFloat(array);
    value = (*static_cast<float*>(mxGetData(array)));
    return;
  }

  void convert(const mxArray* array, uint32_t& value)
  {
    checkUInt32(array);
    value = (*static_cast<uint32_t*>(mxGetData(array)));
    return;
  }

  void convert(const mxArray* array, uint16_t& value)
  {
    checkUInt16(array);
    value = (*static_cast<uint16_t*>(mxGetData(array)));
    return;
  }

  void convert(const mxArray* array, uint8_t& value)
  {
    checkUInt8(array);
    value = (*static_cast<uint8_t*>(mxGetData(array)));
    return;
  }

  void convert(const mxArray* array, int32_t& value)
  {
    checkInt32(array);
    value = (*static_cast<int32_t*>(mxGetData(array)));
    return;
  }

  void convert(const mxArray* array, int16_t& value)
  {
    checkInt16(array);
    value = (*static_cast<int16_t*>(mxGetData(array)));
    return;
  }

  void convert(const mxArray* array, int8_t& value)
  {
    checkInt8(array);
    value = (*static_cast<int8_t*>(mxGetData(array)));
    return;
  }

  void convert(const mxArray* array, bool& value)
  {
    checkBool(array);
    value = (*static_cast<bool*>(mxGetData(array)));
    return;
  }

  void convert(const mxArray* array, std::vector<double> &value)
  {
    double* data;
    size_t n;
    size_t N;
    checkDouble(array);
    data = static_cast<double*>(mxGetData(array));
    N = mxGetNumberOfElements(array);
    value.resize(N);
    for(n = 0; n<N; ++n)
    {
      value[n] = data[n];
    }
    return;
  }

  void convert(const mxArray* array, std::vector<float> &value)
  {
    float* data;
    size_t n;
    size_t N;
    checkFloat(array);
    data = static_cast<float*>(mxGetData(array));
    N = mxGetNumberOfElements(array);
    value.resize(N);
    for(n = 0; n<N; ++n)
    {
      value[n] = data[n];
    }
    return;
  }

  void convert(const mxArray* array, std::vector<uint32_t> &value)
  {
    uint32_t* data;
    size_t n;
    size_t N;
    checkUInt32(array);
    data = static_cast<uint32_t*>(mxGetData(array));
    N = mxGetNumberOfElements(array);
    value.resize(N);
    for(n = 0; n<N; ++n)
    {
      value[n] = data[n];
    }
    return;
  }

  void convert(const mxArray* array, std::vector<uint16_t> &value)
  {
    uint16_t* data;
    size_t n;
    size_t N;
    checkUInt16(array);
    data = static_cast<uint16_t*>(mxGetData(array));
    N = mxGetNumberOfElements(array);
    value.resize(N);
    for(n = 0; n<N; ++n)
    {
      value[n] = data[n];
    }
    return;
  }

  void convert(const mxArray* array, std::vector<uint8_t> &value)
  {
    uint8_t* data;
    size_t n;
    size_t N;
    checkUInt8(array);
    data = static_cast<uint8_t*>(mxGetData(array));
    N = mxGetNumberOfElements(array);
    value.resize(N);
    for(n = 0; n<N; ++n)
    {
      value[n] = data[n];
    }
    return;
  }

  void convert(const mxArray* array, std::vector<int32_t> &value)
  {
    int32_t* data;
    size_t n;
    size_t N;
    checkInt32(array);
    data = static_cast<int32_t*>(mxGetData(array));
    N = mxGetNumberOfElements(array);
    value.resize(N);
    for(n = 0; n<N; ++n)
    {
      value[n] = data[n];
    }
    return;
  }

  void convert(const mxArray* array, std::vector<int16_t> &value)
  {
    int16_t* data;
    size_t n;
    size_t N;
    checkInt16(array);
    data = static_cast<int16_t*>(mxGetData(array));
    N = mxGetNumberOfElements(array);
    value.resize(N);
    for(n = 0; n<N; ++n)
    {
      value[n] = data[n];
    }
    return;
  }

  void convert(const mxArray* array, std::vector<int8_t> &value)
  {
    int8_t* data;
    size_t n;
    size_t N;
    checkInt8(array);
    data = static_cast<int8_t*>(mxGetData(array));
    N = mxGetNumberOfElements(array);
    value.resize(N);
    for(n = 0; n<N; ++n)
    {
      value[n] = data[n];
    }
    return;
  }

  void convert(const mxArray* array, std::vector<bool> &value)
  {
    bool* data;
    size_t n;
    size_t N;
    checkBool(array);
    data = static_cast<bool*>(mxGetData(array));
    N = mxGetNumberOfElements(array);
    value.resize(N);
    for(n = 0; n<N; ++n)
    {
      value[n] = data[n];
    }
    return;
  }

  void convert(const mxArray* array, std::string& value)
  {
    size_t N;
    N = mxGetNumberOfElements(array)+1; // add one for terminating character
    char *cString = new char[N];
    checkString(array);
    mxGetString(array, cString, N);
    value = cString;
    delete[] cString;
    return;
  }
  
  void convert(const mxArray* array, std::pair<double, double>& value)
  {
    mxArray *first;
    mxArray *second;
    first = mxGetField(array, 0, "first");
    second = mxGetField(array, 0, "second");
    value.first = *mxGetPr(first);
    value.second = *mxGetPr(second);
    return;
  }

  void convert(const double& value, mxArray*& array)
  {
    array = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
    (*static_cast<double*>(mxGetData(array))) = value;
    return;
  }

  void convert(const float& value, mxArray*& array)
  {
    array = mxCreateNumericMatrix(1, 1, mxSINGLE_CLASS, mxREAL);
    (*static_cast<float*>(mxGetData(array))) = value;
    return;
  }
  
  void convert(const uint32_t& value, mxArray*& array)
  {
    array = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    (*static_cast<uint32_t*>(mxGetData(array))) = value;
    return;
  }

  void convert(const uint16_t& value, mxArray*& array)
  {
    array = mxCreateNumericMatrix(1, 1, mxUINT16_CLASS, mxREAL);
    (*static_cast<uint16_t*>(mxGetData(array))) = value;
    return;
  }

  void convert(const uint8_t& value, mxArray*& array)
  {
    array = mxCreateNumericMatrix(1, 1, mxUINT8_CLASS, mxREAL);
    (*static_cast<uint8_t*>(mxGetData(array))) = value;
    return;
  }

  void convert(const int32_t& value, mxArray*& array)
  {
    array = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    (*static_cast<int32_t*>(mxGetData(array))) = value;
    return;
  }

  void convert(const int16_t& value, mxArray*& array)
  {
    array = mxCreateNumericMatrix(1, 1, mxINT16_CLASS, mxREAL);
    (*static_cast<int16_t*>(mxGetData(array))) = value;
    return;
  }

  void convert(const int8_t& value, mxArray*& array)
  {
    array = mxCreateNumericMatrix(1, 1, mxINT8_CLASS, mxREAL);
    (*static_cast<int8_t*>(mxGetData(array))) = value;
    return;
  }

  void convert(const bool& value, mxArray*& array)
  {
    array = mxCreateNumericMatrix(1, 1, mxLOGICAL_CLASS, mxREAL);
    (*static_cast<bool*>(mxGetData(array))) = value;
    return;
  }

  void convert(const std::vector<double>& value, mxArray*& array)
  {
    double* pValue;
    size_t n;
    size_t N = value.size();
    array = mxCreateNumericMatrix(N, 1, mxDOUBLE_CLASS, mxREAL);
    pValue = static_cast<double*>(mxGetData(array));
    for(n = 0; n<N; ++n)
    {
      pValue[n] = value[n];
    }
    return;
  }

  void convert(const std::vector<float>& value, mxArray*& array)
  {
    float* pValue;
    size_t n;
    size_t N = value.size();
    array = mxCreateNumericMatrix(N, 1, mxSINGLE_CLASS, mxREAL);
    pValue = static_cast<float*>(mxGetData(array));
    for(n = 0; n<N; ++n)
    {
      pValue[n] = value[n];
    }
    return;
  }
  
  void convert(const std::vector<uint32_t>& value, mxArray*& array)
  {
    uint32_t* pValue;
    size_t n;
    size_t N = value.size();
    array = mxCreateNumericMatrix(N, 1, mxUINT32_CLASS, mxREAL);
    pValue = static_cast<uint32_t*>(mxGetData(array));
    for(n = 0; n<N; ++n)
    {
      pValue[n] = value[n];
    }
    return;
  }
 
  void convert(const std::vector<uint16_t>& value, mxArray*& array)
  {
    uint16_t* pValue;
    size_t n;
    size_t N = value.size();
    array = mxCreateNumericMatrix(N, 1, mxUINT16_CLASS, mxREAL);
    pValue = static_cast<uint16_t*>(mxGetData(array));
    for(n = 0; n<N; ++n)
    {
      pValue[n] = value[n];
    }
    return;
  }

  void convert(const std::vector<uint8_t>& value, mxArray*& array)
  {
    uint8_t* pValue;
    size_t n;
    size_t N = value.size();
    array = mxCreateNumericMatrix(N, 1, mxUINT8_CLASS, mxREAL);
    pValue = static_cast<uint8_t*>(mxGetData(array));
    for(n = 0; n<N; ++n)
    {
      pValue[n] = value[n];
    }
    return;
  }
  
  void convert(const std::vector<int32_t>& value, mxArray*& array)
  {
    int32_t* pValue;
    size_t n;
    size_t N = value.size();
    array = mxCreateNumericMatrix(N, 1, mxINT32_CLASS, mxREAL);
    pValue = static_cast<int32_t*>(mxGetData(array));
    for(n = 0; n<N; ++n)
    {
      pValue[n] = value[n];
    }
    return;
  }

  void convert(const std::vector<int16_t>& value, mxArray*& array)
  {
    int16_t* pValue;
    size_t n;
    size_t N = value.size();
    array = mxCreateNumericMatrix(N, 1, mxINT16_CLASS, mxREAL);
    pValue = static_cast<int16_t*>(mxGetData(array));
    for(n = 0; n<N; ++n)
    {
      pValue[n] = value[n];
    }
    return;
  }

  void convert(const std::vector<int8_t>& value, mxArray*& array)
  {
    int8_t* pValue;
    size_t n;
    size_t N = value.size();
    array = mxCreateNumericMatrix(N, 1, mxINT8_CLASS, mxREAL);
    pValue = static_cast<int8_t*>(mxGetData(array));
    for(n = 0; n<N; ++n)
    {
      pValue[n] = value[n];
    }
    return;
  }

  void convert(const std::vector<bool>& value, mxArray*& array)
  {
    bool* pValue;
    size_t n;
    size_t N = value.size();
    array = mxCreateNumericMatrix(N, 1, mxLOGICAL_CLASS, mxREAL);
    pValue = static_cast<bool*>(mxGetData(array));
    for(n = 0; n<N; ++n)
    {
      pValue[n] = value[n];
    }
    return;
  }

  void convert(const std::string& str, mxArray*& array)
  {
    array = mxCreateString(str.c_str());
    return;
  }
  
  void convert(const std::pair<double, double>& value, mxArray*& array)
  {
    static const mwSize dims[2] = {1, 1};
    static const char* fieldnames[] = {"first", "second"};
    mxArray* first;
    mxArray* second;
    first = mxCreateDoubleScalar(value.first);
    second = mxCreateDoubleScalar(value.second);
    array = mxCreateStructArray(2, dims, 2, fieldnames);
    mxSetField(array, 0, "first", first);
    mxSetField(array, 0, "second", second);
    return;
  }
  
#if defined(__LP64__) || defined(_LP64)
  void checkUInt64(const mxArray* array)
  {
    if((mxGetClassID(array)!=mxUINT64_CLASS))
    {
      throw("Must be type uint64.");
    }
    return;
  }
  
  void convert(const mxArray* array, uint64_t& value)
  {
    checkUInt64(array);
    value = (*static_cast<uint64_t*>(mxGetData(array)));
    return;
  }
  
  void convert(const uint64_t& value, mxArray*& array)
  {
    array = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    (*static_cast<uint64_t*>(mxGetData(array))) = value;
    return;
  }
  
  void convert(const std::vector<uint64_t>& value, mxArray*& array)
  {
    uint64_t* pValue;
    size_t n;
    size_t N = value.size();
    array = mxCreateNumericMatrix(N, 1, mxUINT64_CLASS, mxREAL);
    pValue = static_cast<uint64_t*>(mxGetData(array));
    for(n = 0; n<N; ++n)
    {
      pValue[n] = value[n];
    }
    return;
  }
  
  void convert(const std::vector<int64_t>& value, mxArray*& array)
  {
    int64_t* pValue;
    size_t n;
    size_t N = value.size();
    array = mxCreateNumericMatrix(N, 1, mxINT64_CLASS, mxREAL);
    pValue = static_cast<int64_t*>(mxGetData(array));
    for(n = 0; n<N; ++n)
    {
      pValue[n] = value[n];
    }
    return;
  }
#endif
}
  
#endif
