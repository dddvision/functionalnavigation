#include <map>
#include <vector>
#include "mex.h"
#include "PNAVPackage.h"

namespace PNAVPackageBridge
{
  enum PNAVPackageMember
  {
    undefined,
    PNAVPackageIsConnected,
    PNAVPackageDescription,
    PNAVPackageCreate,
    getAccelerometerArray,
    getGyroscopeArray,
    getMagnetometerArray,
    getAltimeter,
    getGPSReceiver,
    refresh,
    hasData,
    first,
    last,
    getTime,
    getSpecificForce,
    getSpecificForceCalibrated,
    getAccelerometerVelocityRandomWalk,
    getAccelerometerTurnOnBiasSigma,
    getAccelerometerInRunBiasSigma,
    getAccelerometerInRunBiasStability,
    getAccelerometerTurnOnScaleSigma,
    getAccelerometerInRunScaleSigma,
    getAccelerometerInRunScaleStability,
    getAngularRate,
    getAngularRateCalibrated,
    getGyroscopeAngleRandomWalk,
    getGyroscopeTurnOnBiasSigma,
    getGyroscopeInRunBiasSigma,
    getGyroscopeInRunBiasStability,
    getGyroscopeTurnOnScaleSigma,
    getGyroscopeInRunScaleSigma,
    getGyroscopeInRunScaleStability,
    getMagneticField,
    getMagneticFieldCalibrated,
    getAltitude,
    getLongitude,
    getLatitude,
    getHeight,
    hasPrecision,
    getPrecisionHorizontal,
    getPrecisionVertical,
    getPrecisionCircular
  };

  void argcheck(int& narg, int n)
  {
    if(n>narg)
    {
      throw("Too few input arguments.");
    }
    return;
  }

  void convert(const mxArray*& array, uint32_t& value)
  {
    if(mxGetClassID(array)!=mxUINT32_CLASS)
    {
      throw("Array must be uint32.");
    }
    value = (*static_cast<uint32_t*>(mxGetData(array)));
    return;
  }

  void convert(const mxArray*& array, std::vector<uint32_t> &value)
  {
    uint32_t* data;
    size_t n;
    size_t N;
    if(mxGetClassID(array)!=mxUINT32_CLASS)
    {
      throw("Array must be uint32.");
    }
    N = mxGetNumberOfElements(array);
    data = (uint32_t*)mxGetData(array);
    value.resize(N, 0);
    for(n = 0; n<N; ++n)
    {
      value[n] = data[n];
    }
    return;
  }

  void convert(const mxArray*& array, std::string& cppString)
  {
    unsigned N = mxGetNumberOfElements(array)+1; // add one for terminating character
    char *cString = new char[N];
    if(mxGetClassID(array)!=mxCHAR_CLASS)
    {
      throw("Array must be char.");
    }
    mxGetString(array, cString, N);
    cppString = cString;
    delete[] cString;
    return;
  }

  void convert(const double& value, mxArray*& array)
  {
    array = mxCreateDoubleScalar(value);
    return;
  }

  void convert(const uint32_t& value, mxArray*& array)
  {
    array = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    (*static_cast<uint32_t*>(mxGetData(array))) = value;
    return;
  }

  void convert(const bool& value, mxArray*& array)
  {
    array = mxCreateLogicalScalar(value);
    return;
  }

  void convert(std::string str, mxArray*& array)
  {
    array = mxCreateString(str.c_str());
    return;
  }

  static hidi::PNAVPackage* package = NULL;

  void deletePackage(void)
  {
    if(package)
    {
      delete package;
      package = NULL;
    }
  }
  
  void safeMexFunction(int& nlhs, mxArray**& plhs, int& nrhs, const mxArray**& prhs)
  {
    static std::string memberName;
    static std::map<std::string, PNAVPackageMember> memberMap;
    static bool initialized = false;

    if(!initialized)
    {
      mexAtExit(deletePackage);
      memberMap["PNAVPackageIsConnected"] = PNAVPackageIsConnected;
      memberMap["PNAVPackageDescription"] = PNAVPackageDescription;
      memberMap["PNAVPackageCreate"] = PNAVPackageCreate;
      memberMap["getAccelerometerArray"] = getAccelerometerArray;
      memberMap["getGyroscopeArray"] = getGyroscopeArray;
      memberMap["getMagnetometerArray"] = getMagnetometerArray;
      memberMap["getAltimeter"] = getAltimeter;
      memberMap["getGPSReceiver"] = getGPSReceiver;
      memberMap["refresh"] = refresh;
      memberMap["hasData"] = hasData;
      memberMap["first"] = first;
      memberMap["last"] = last;
      memberMap["getTime"] = getTime;
      memberMap["getSpecificForce"] = getSpecificForce;
      memberMap["getSpecificForceCalibrated"] = getSpecificForceCalibrated;
      memberMap["getAccelerometerVelocityRandomWalk"] = getAccelerometerVelocityRandomWalk;
      memberMap["getAccelerometerTurnOnBiasSigma"] = getAccelerometerTurnOnBiasSigma;
      memberMap["getAccelerometerInRunBiasSigma"] = getAccelerometerInRunBiasSigma;
      memberMap["getAccelerometerInRunBiasStability"] = getAccelerometerInRunBiasStability;
      memberMap["getAccelerometerTurnOnScaleSigma"] = getAccelerometerTurnOnScaleSigma;
      memberMap["getAccelerometerInRunScaleSigma"] = getAccelerometerInRunScaleSigma;
      memberMap["getAccelerometerInRunScaleStability"] = getAccelerometerInRunScaleStability;
      memberMap["getAngularRate"] = getAngularRate;
      memberMap["getAngularRateCalibrated"] = getAngularRateCalibrated;
      memberMap["getGyroscopeAngleRandomWalk"] = getGyroscopeAngleRandomWalk;
      memberMap["getGyroscopeTurnOnBiasSigma"] = getGyroscopeTurnOnBiasSigma;
      memberMap["getGyroscopeInRunBiasSigma"] = getGyroscopeInRunBiasSigma;
      memberMap["getGyroscopeInRunBiasStability"] = getGyroscopeInRunBiasStability;
      memberMap["getGyroscopeTurnOnScaleSigma"] = getGyroscopeTurnOnScaleSigma;
      memberMap["getGyroscopeInRunScaleSigma"] = getGyroscopeInRunScaleSigma;
      memberMap["getGyroscopeInRunScaleStability"] = getGyroscopeInRunScaleStability;
      memberMap["getMagneticField"] = getMagneticField;
      memberMap["getMagneticFieldCalibrated"] = getMagneticFieldCalibrated;
      memberMap["getAltitude"] = getAltitude;
      memberMap["getLongitude"] = getLongitude;
      memberMap["getLatitude"] = getLatitude;
      memberMap["getHeight"] = getHeight;
      memberMap["hasPrecision"] = hasPrecision;
      memberMap["getPrecisionHorizontal"] = getPrecisionHorizontal;
      memberMap["getPrecisionVertical"] = getPrecisionVertical;
      memberMap["getPrecisionCircular"] = getPrecisionCircular;
      initialized = true;
    }

    argcheck(nrhs, 1);
    convert(prhs[0], memberName);
    switch(memberMap[memberName])
    {
      case undefined:
      {
        throw("Undefined function call.");
        break;
      }
      
      case PNAVPackageIsConnected:
      {
        static std::string name;

        argcheck(nrhs, 2);
        convert(prhs[1], name);
        convert(hidi::PNAVPackage::isConnected(name), plhs[0]);
        break;
      }
      
      case PNAVPackageDescription:
      {
        static std::string name;

        argcheck(nrhs, 2);
        convert(prhs[1], name);
        convert(hidi::PNAVPackage::description(name), plhs[0]);
        break;
      }
      
      case PNAVPackageCreate:
      {
        static std::string name;
        static std::string uri;

        argcheck(nrhs, 3);
        convert(prhs[1], name);
        convert(prhs[2], uri);
        deletePackage();
        package = hidi::PNAVPackage::create(name, uri);
        break;
      }

      case getAccelerometerArray:
      {
        break;
      }

      case getGyroscopeArray:
      {
        break;
      }

      case getMagnetometerArray:
      {
        break;
      }

      case getAltimeter:
      {
        break;
      }

      case getGPSReceiver:
      {
        break;
      }

      case refresh:
      {
        package->refresh();
        break;
      }

      case hasData:
      {
        hidi::AccelerometerArray* sensor = package->getAccelerometerArray();
        convert(sensor->hasData(), plhs[0]);
        break;
      }

      case first:
      {
        hidi::AccelerometerArray* sensor = package->getAccelerometerArray();
        convert(sensor->first(), plhs[0]);
        break;
      }

      case last:
      {
        hidi::AccelerometerArray* sensor = package->getAccelerometerArray();
        convert(sensor->last(), plhs[0]);
        break;
      }

      case getTime:
      {
        hidi::AccelerometerArray* sensor = package->getAccelerometerArray();
        static uint32_t n;
        argcheck(nrhs, 2);
        convert(prhs[1], n);
        convert(sensor->getTime(n), plhs[0]);
        break;
      }

      case getSpecificForce:
      {
        hidi::AccelerometerArray* sensor = package->getAccelerometerArray();
        static std::vector<uint32_t> n;
        static std::vector<uint32_t> ax;
        double* data;
        size_t i;
        size_t j;
        size_t k;
        argcheck(nrhs, 3);
        convert(prhs[1], n);
        convert(prhs[2], ax);
        plhs[0] = mxCreateDoubleMatrix(ax.size(), n.size(), mxREAL);
        data = mxGetPr(plhs[0]);
        k = 0;
        for(j = 0; j<n.size(); ++j)
        {
          for(i = 0; i<ax.size(); ++i)
          {
            data[k] = sensor->getSpecificForce(n[j], ax[i]);
            ++k;
          }
        }
        break;
      }

      case getSpecificForceCalibrated:
      {
        hidi::AccelerometerArray* sensor = package->getAccelerometerArray();
        static std::vector<uint32_t> n;
        static std::vector<uint32_t> ax;
        double* data;
        size_t i;
        size_t j;
        size_t k;
        argcheck(nrhs, 3);
        convert(prhs[1], n);
        convert(prhs[2], ax);
        plhs[0] = mxCreateDoubleMatrix(ax.size(), n.size(), mxREAL);
        data = mxGetPr(plhs[0]);
        k = 0;
        for(j = 0; j<n.size(); ++j)
        {
          for(i = 0; i<ax.size(); ++i)
          {
            data[k] = sensor->getSpecificForceCalibrated(n[j], ax[i]);
            ++k;
          }
        }
        break;
      }

      case getAccelerometerVelocityRandomWalk:
      {
        hidi::AccelerometerArray* sensor = package->getAccelerometerArray();
        convert(sensor->getAccelerometerVelocityRandomWalk(), plhs[0]);
        break;
      }

      case getAccelerometerTurnOnBiasSigma:
      {
        hidi::AccelerometerArray* sensor = package->getAccelerometerArray();
        convert(sensor->getAccelerometerTurnOnBiasSigma(), plhs[0]);
        break;
      }

      case getAccelerometerInRunBiasSigma:
      {
        hidi::AccelerometerArray* sensor = package->getAccelerometerArray();
        convert(sensor->getAccelerometerInRunBiasSigma(), plhs[0]);
        break;
      }

      case getAccelerometerInRunBiasStability:
      {
        hidi::AccelerometerArray* sensor = package->getAccelerometerArray();
        convert(sensor->getAccelerometerInRunBiasStability(), plhs[0]);
        break;
      }

      case getAccelerometerTurnOnScaleSigma:
      {
        hidi::AccelerometerArray* sensor = package->getAccelerometerArray();
        convert(sensor->getAccelerometerTurnOnScaleSigma(), plhs[0]);
        break;
      }

      case getAccelerometerInRunScaleSigma:
      {
        hidi::AccelerometerArray* sensor = package->getAccelerometerArray();
        convert(sensor->getAccelerometerInRunScaleSigma(), plhs[0]);
        break;
      }

      case getAccelerometerInRunScaleStability:
      {
        hidi::AccelerometerArray* sensor = package->getAccelerometerArray();
        convert(sensor->getAccelerometerInRunScaleStability(), plhs[0]);
        break;
      }

      case getAngularRate:
      {
        hidi::GyroscopeArray* sensor = package->getGyroscopeArray();
        static std::vector<uint32_t> n;
        static std::vector<uint32_t> ax;
        double* data;
        size_t i;
        size_t j;
        size_t k;
        argcheck(nrhs, 3);
        convert(prhs[1], n);
        convert(prhs[2], ax);
        plhs[0] = mxCreateDoubleMatrix(ax.size(), n.size(), mxREAL);
        data = mxGetPr(plhs[0]);
        k = 0;
        for(j = 0; j<n.size(); ++j)
        {
          for(i = 0; i<ax.size(); ++i)
          {
            data[k] = sensor->getAngularRate(n[j], ax[i]);
            ++k;
          }
        }
        break;
      }

      case getAngularRateCalibrated:
      {
        hidi::GyroscopeArray* sensor = package->getGyroscopeArray();
        static std::vector<uint32_t> n;
        static std::vector<uint32_t> ax;
        double* data;
        size_t i;
        size_t j;
        size_t k;
        argcheck(nrhs, 3);
        convert(prhs[1], n);
        convert(prhs[2], ax);
        plhs[0] = mxCreateDoubleMatrix(ax.size(), n.size(), mxREAL);
        data = mxGetPr(plhs[0]);
        k = 0;
        for(j = 0; j<n.size(); ++j)
        {
          for(i = 0; i<ax.size(); ++i)
          {
            data[k] = sensor->getAngularRateCalibrated(n[j], ax[i]);
            ++k;
          }
        }
        break;
      }

      case getGyroscopeAngleRandomWalk:
      {
        hidi::GyroscopeArray* sensor = package->getGyroscopeArray();
        convert(sensor->getGyroscopeAngleRandomWalk(), plhs[0]);
        break;
      }

      case getGyroscopeTurnOnBiasSigma:
      {
        hidi::GyroscopeArray* sensor = package->getGyroscopeArray();
        convert(sensor->getGyroscopeTurnOnBiasSigma(), plhs[0]);
        break;
      }

      case getGyroscopeInRunBiasSigma:
      {
        hidi::GyroscopeArray* sensor = package->getGyroscopeArray();
        convert(sensor->getGyroscopeInRunBiasSigma(), plhs[0]);
        break;
      }

      case getGyroscopeInRunBiasStability:
      {
        hidi::GyroscopeArray* sensor = package->getGyroscopeArray();
        convert(sensor->getGyroscopeInRunBiasStability(), plhs[0]);
        break;
      }

      case getGyroscopeTurnOnScaleSigma:
      {
        hidi::GyroscopeArray* sensor = package->getGyroscopeArray();
        convert(sensor->getGyroscopeTurnOnScaleSigma(), plhs[0]);
        break;
      }

      case getGyroscopeInRunScaleSigma:
      {
        hidi::GyroscopeArray* sensor = package->getGyroscopeArray();
        convert(sensor->getGyroscopeInRunScaleSigma(), plhs[0]);
        break;
      }

      case getGyroscopeInRunScaleStability:
      {
        hidi::GyroscopeArray* sensor = package->getGyroscopeArray();
        convert(sensor->getGyroscopeInRunScaleStability(), plhs[0]);
        break;
      }

      case getMagneticField:
      {
        hidi::MagnetometerArray* sensor = package->getMagnetometerArray();
        static std::vector<uint32_t> n;
        static std::vector<uint32_t> ax;
        double* data;
        size_t i;
        size_t j;
        size_t k;
        argcheck(nrhs, 3);
        convert(prhs[1], n);
        convert(prhs[2], ax);
        plhs[0] = mxCreateDoubleMatrix(ax.size(), n.size(), mxREAL);
        data = mxGetPr(plhs[0]);
        k = 0;
        for(j = 0; j<n.size(); ++j)
        {
          for(i = 0; i<ax.size(); ++i)
          {
            data[k] = sensor->getMagneticField(n[j], ax[i]);
            ++k;
          }
        }
        break;
      }

      case getMagneticFieldCalibrated:
      {
        hidi::MagnetometerArray* sensor = package->getMagnetometerArray();
        static std::vector<uint32_t> n;
        static std::vector<uint32_t> ax;
        double* data;
        size_t i;
        size_t j;
        size_t k;
        argcheck(nrhs, 3);
        convert(prhs[1], n);
        convert(prhs[2], ax);
        plhs[0] = mxCreateDoubleMatrix(ax.size(), n.size(), mxREAL);
        data = mxGetPr(plhs[0]);
        k = 0;
        for(j = 0; j<n.size(); ++j)
        {
          for(i = 0; i<ax.size(); ++i)
          {
            data[k] = sensor->getMagneticFieldCalibrated(n[j], ax[i]);
            ++k;
          }
        }
        break;
      }

      case getAltitude:
      {
        hidi::Altimeter* sensor = package->getAltimeter();
        static uint32_t n;
        argcheck(nrhs, 2);
        convert(prhs[1], n);
        convert(sensor->getAltitude(n), plhs[0]);
        break;
      }

      case getLongitude:
      {
        hidi::GPSReceiver* sensor = package->getGPSReceiver();
        static uint32_t n;
        argcheck(nrhs, 2);
        convert(prhs[1], n);
        convert(sensor->getLongitude(n), plhs[0]);
        break;
      }

      case getLatitude:
      {
        hidi::GPSReceiver* sensor = package->getGPSReceiver();
        static uint32_t n;
        argcheck(nrhs, 2);
        convert(prhs[1], n);
        convert(sensor->getLatitude(n), plhs[0]);
        break;
      }

      case getHeight:
      {
        hidi::GPSReceiver* sensor = package->getGPSReceiver();
        static uint32_t n;
        argcheck(nrhs, 2);
        convert(prhs[1], n);
        convert(sensor->getLongitude(n), plhs[0]);
        break;
      }

      case hasPrecision:
      {
        hidi::GPSReceiver* sensor = package->getGPSReceiver();
        convert(sensor->hasPrecision(), plhs[0]);
        break;
      }

      case getPrecisionHorizontal:
      {
        hidi::GPSReceiver* sensor = package->getGPSReceiver();
        static uint32_t n;
        argcheck(nrhs, 2);
        convert(prhs[1], n);
        convert(sensor->getPrecisionHorizontal(n), plhs[0]);
        break;
      }

      case getPrecisionVertical:
      {
        hidi::GPSReceiver* sensor = package->getGPSReceiver();
        static uint32_t n;
        argcheck(nrhs, 2);
        convert(prhs[1], n);
        convert(sensor->getPrecisionVertical(n), plhs[0]);
        break;
      }

      case getPrecisionCircular:
      {
        hidi::GPSReceiver* sensor = package->getGPSReceiver();
        static uint32_t n;
        argcheck(nrhs, 2);
        convert(prhs[1], n);
        convert(sensor->getPrecisionCircular(n), plhs[0]);
        break;
      }

      default:
      {
        throw("Invalid member function call.");
      }
    }
    return;
  }
}
  
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
  std::string prefix("PNAVPackageBridge: ");
  try
  {
    PNAVPackageBridge::safeMexFunction(nlhs, plhs, nrhs, prhs);
  }
  catch(std::exception& e)
  {
    mexErrMsgTxt((prefix+e.what()).c_str());
  }
  catch(const char* str)
  {
    mexErrMsgTxt((prefix+str).c_str());
  }
  catch(...)
  {
    mexErrMsgTxt((prefix+"Unhandled exception.").c_str());
  }
  return;
}
