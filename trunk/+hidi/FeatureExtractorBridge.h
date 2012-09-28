#ifndef HIDIFEATUREEXTRACTORBRIDGE_H
#define HIDIFEATUREEXTRACTORBRIDGE_H

#include "hidiBridge.h"
#include "FeatureExtractor.h"

namespace hidi
{
  enum FeatureExtractorMember
  {
    FeatureExtractorUndefined,
    FeatureExtractorCreate,
    numFeatures,
    getFeatureLabel,
    getFeatureValue
  };
  
  class FeatureExtractorBridge : public virtual hidi:FeatureExtractor
  {
  private:
    mxArray* object;
    
  public:
    FeatureExtractorBridge(mxArray* object)
    {
      this->object = object;
    }
    
    uint32_t numFeatures(void)
    {
      mxArray* lhs;
      uint32_t N;
      mexCallMATLAB(1, &lhs, 1, &object, "numFeatures");
      if(mxGetClassID(lhs)!=mxUINT32_CLASS)
      {
        throw("Array must be uint32.");
      }
      N = *static_cast<uint32_t*>(mxGetData(lhs));
      mxDestroyArray(lhs);
      return (N);
    }

    std::string getFeatureLabel(const uint32_t& index)
    {
      mxArray* rhs[2];
      mxArray* lhs;
      std::string label;
      rhs[0] = object;
      rhs[1] = mxCreateDoubleScalar(static_cast<double>(index));
      mexCallMATLAB(1, &lhs, 2, &rhs, "getFeatureLabel");
      mxDestroyArray(rhs[1]);
      if(mxGetClassID(lhs)!=mxCHAR_CLASS)
      {
        throw("Array must be char.");
      }
      convert(lhs, label);
      mxDestroyArray(lhs);
      return (label);
    }
    
    double getFeatureValue(const uint32_t& index)
    {
      mxArray* rhs[2];
      mxArray* lhs;
      double value;
      rhs[0] = object;
      rhs[1] = mxCreateDoubleScalar(static_cast<double>(index));
      mexCallMATLAB(1, &lhs, 2, &rhs, "getFeatureValue");
      mxDestroyArray(rhs[1]);
      if(mxGetClassID(lhs)!=mxDOUBLE_CLASS)
      {
        throw("Array must be double.");
      }
      value = mxGetScalar(lhs);
      mxDestroyArray(lhs);
      return (value);
    }
  };
  
  typedef void (*safeMexCallback)(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]);
  void safeMexFunction(safeMexCallback callback, int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
  {
    std::string message;
    try
    {
      callback(nlhs, plhs, nrhs, prhs);
    }
    catch(std::exception& e)
    {
      message = "FeatureExtractorBridge: ";
      message = message+e.what();
      mexErrMsgTxt(message.c_str());
    }
    catch(const char* str)
    {
      message = "FeatureExtractorBridge: ";
      message = message+str;
      mexErrMsgTxt(message.c_str());
    }
    catch(...)
    {
      message = "FeatureExtractorBridge: ";
      message = message+"Unhandled exception.";
      mexErrMsgTxt(message.c_str());
    }
    return;
  }
}

#endif
