#ifndef HIDISENSORPACKAGEBRIDGE_H
#define HIDISENSORPACKAGEBRIDGE_H

#include "hidiBridge.h"
#include "SensorPackage.h"
#include "packages.h"

namespace hidi
{
  namespace SensorPackageBridge
  {
    enum Member
    {
      undefined,
      isConnected,
      description,
      create,
      destroy,
      getAccelerometerArray,
      getAltimeter,
      getCamera,
      getGPSReceiver,
      getGyroscopeArray,
      getMagnetometerArray,
      getPedometer,
      accelerometerArrayRefresh,
      accelerometerArrayHasData,
      accelerometerArrayFirst,
      accelerometerArrayLast,
      accelerometerArrayGetTime,
      getSpecificForce,
      getAccelerometerRandomWalk,
      getAccelerometerTurnOnBiasSigma,
      getAccelerometerInRunBiasSigma,
      getAccelerometerInRunBiasStability,
      getAccelerometerTurnOnScaleSigma,
      getAccelerometerInRunScaleSigma,
      getAccelerometerInRunScaleStability,
      altimeterRefresh,
      altimeterHasData,
      altimeterFirst,
      altimeterLast,
      altimeterGetTime,
      getAltitude,
      cameraRefresh,
      cameraHasData,
      cameraFirst,
      cameraLast,
      cameraGetTime,
      interpretLayers,
      numStrides,
      numSteps,
      strideMin,
      strideMax,
      stepMin,
      stepMax,
      projection,
      inverseProjection,
      getImageUInt8,
      getImageDouble,
      gpsReceiverRefresh,
      gpsReceiverHasData,
      gpsReceiverFirst,
      gpsReceiverLast,
      gpsReceiverGetTime,
      getLongitude,
      getLatitude,
      getHeight,
      hasPrecision,
      getHDOP,
      getVDOP,
      getPDOP,
      gyroscopeArrayRefresh,
      gyroscopeArrayHasData,
      gyroscopeArrayFirst,
      gyroscopeArrayLast,
      gyroscopeArrayGetTime,
      getAngularRate,
      getGyroscopeRandomWalk,
      getGyroscopeTurnOnBiasSigma,
      getGyroscopeInRunBiasSigma,
      getGyroscopeInRunBiasStability,
      getGyroscopeTurnOnScaleSigma,
      getGyroscopeInRunScaleSigma,
      getGyroscopeInRunScaleStability,
      magnetometerArrayRefresh,
      magnetometerArrayHasData,
      magnetometerArrayFirst,
      magnetometerArrayLast,
      magnetometerArrayGetTime,
      getMagneticField,
      pedometerRefresh,
      pedometerHasData,
      pedometerFirst,
      pedometerLast,
      pedometerGetTime,
      isStepComplete,
      getStepMagnitude,
      getStepDeviation,
      getStepID
    };
    
    class MemberMap
    {
    private:
      std::map<std::string, Member> mm;
    
    public:
      MemberMap(void)
      {
        mm["isConnected"] = isConnected;
        mm["description"] = description;
        mm["create"] = create;
        mm["destroy"] = destroy;
        mm["getAccelerometerArray"] = getAccelerometerArray;
        mm["getAltimeter"] = getAltimeter;
        mm["getCamera"] = getCamera;
        mm["getGPSReceiver"] = getGPSReceiver;
        mm["getGyroscopeArray"] = getGyroscopeArray;
        mm["getMagnetometerArray"] = getMagnetometerArray;
        mm["getPedometer"] = getPedometer;
        mm["accelerometerArrayRefresh"] = accelerometerArrayRefresh;
        mm["accelerometerArrayHasData"] = accelerometerArrayHasData;
        mm["accelerometerArrayFirst"] = accelerometerArrayFirst;
        mm["accelerometerArrayLast"] = accelerometerArrayLast;
        mm["accelerometerArrayGetTime"] = accelerometerArrayGetTime;
        mm["getSpecificForce"] = getSpecificForce;
        mm["getAccelerometerRandomWalk"] = getAccelerometerRandomWalk;
        mm["getAccelerometerTurnOnBiasSigma"] = getAccelerometerTurnOnBiasSigma;
        mm["getAccelerometerInRunBiasSigma"] = getAccelerometerInRunBiasSigma;
        mm["getAccelerometerInRunBiasStability"] = getAccelerometerInRunBiasStability;
        mm["getAccelerometerTurnOnScaleSigma"] = getAccelerometerTurnOnScaleSigma;
        mm["getAccelerometerInRunScaleSigma"] = getAccelerometerInRunScaleSigma;
        mm["getAccelerometerInRunScaleStability"] = getAccelerometerInRunScaleStability;
        mm["altimeterRefresh"] = altimeterRefresh;
        mm["altimeterHasData"] = altimeterHasData;
        mm["altimeterFirst"] = altimeterFirst;
        mm["altimeterLast"] = altimeterLast;
        mm["altimeterGetTime"] = altimeterGetTime;
        mm["getAltitude"] = getAltitude;
        mm["cameraRefresh"] = cameraRefresh;
        mm["cameraHasData"] = cameraHasData;
        mm["cameraFirst"] = cameraFirst;
        mm["cameraLast"] = cameraLast;
        mm["cameraGetTime"] = cameraGetTime;
        mm["interpretLayers"] = interpretLayers;
        mm["numStrides"] = numStrides;
        mm["numSteps"] = numSteps;
        mm["strideMin"] = strideMin;
        mm["strideMax"] = strideMax;
        mm["stepMin"] = stepMin;
        mm["stepMax"] = stepMax;
        mm["projection"] = projection;
        mm["inverseProjection"] = inverseProjection;
        mm["getImageUInt8"] = getImageUInt8;
        mm["getImageDouble"] = getImageDouble;
        mm["gpsReceiverRefresh"] = gpsReceiverRefresh;
        mm["gpsReceiverHasData"] = gpsReceiverHasData;
        mm["gpsReceiverFirst"] = gpsReceiverFirst;
        mm["gpsReceiverLast"] = gpsReceiverLast;
        mm["gpsReceiverGetTime"] = gpsReceiverGetTime;
        mm["getLongitude"] = getLongitude;
        mm["getLatitude"] = getLatitude;
        mm["getHeight"] = getHeight;
        mm["hasPrecision"] = hasPrecision;
        mm["getHDOP"] = getHDOP;
        mm["getVDOP"] = getVDOP;
        mm["getPDOP"] = getPDOP;
        mm["gyroscopeArrayRefresh"] = gyroscopeArrayRefresh;
        mm["gyroscopeArrayHasData"] = gyroscopeArrayHasData;
        mm["gyroscopeArrayFirst"] = gyroscopeArrayFirst;
        mm["gyroscopeArrayLast"] = gyroscopeArrayLast;
        mm["gyroscopeArrayGetTime"] = gyroscopeArrayGetTime;
        mm["getAngularRate"] = getAngularRate;
        mm["getGyroscopeRandomWalk"] = getGyroscopeRandomWalk;
        mm["getGyroscopeTurnOnBiasSigma"] = getGyroscopeTurnOnBiasSigma;
        mm["getGyroscopeInRunBiasSigma"] = getGyroscopeInRunBiasSigma;
        mm["getGyroscopeInRunBiasStability"] = getGyroscopeInRunBiasStability;
        mm["getGyroscopeTurnOnScaleSigma"] = getGyroscopeTurnOnScaleSigma;
        mm["getGyroscopeInRunScaleSigma"] = getGyroscopeInRunScaleSigma;
        mm["getGyroscopeInRunScaleStability"] = getGyroscopeInRunScaleStability;
        mm["magnetometerArrayRefresh"] = magnetometerArrayRefresh;
        mm["magnetometerArrayHasData"] = magnetometerArrayHasData;
        mm["magnetometerArrayFirst"] = magnetometerArrayFirst;
        mm["magnetometerArrayLast"] = magnetometerArrayLast;
        mm["magnetometerArrayGetTime"] = magnetometerArrayGetTime;
        mm["getMagneticField"] = getMagneticField;
        mm["pedometerRefresh"] = pedometerRefresh;
        mm["pedometerHasData"] = pedometerHasData;
        mm["pedometerFirst"] = pedometerFirst;
        mm["pedometerLast"] = pedometerLast;
        mm["pedometerGetTime"] = pedometerGetTime;
        mm["isStepComplete"] = isStepComplete;
        mm["getStepMagnitude"] = getStepMagnitude;
        mm["getStepDeviation"] = getStepDeviation;
        mm["getStepID"] = getStepID;
      }
      
      Member& operator[] (const std::string& s)
      {
        return (mm[s]);
      }
    };

    template<class T>
    void getSensor(std::vector<T> sensor, mxArray*& array)
    {
      uint32_t* data;
      uint32_t index;
      array = mxCreateNumericMatrix(sensor.size(), 1, mxUINT32_CLASS, mxREAL);
      data = static_cast<uint32_t*>(mxGetData(array));
      for(index = 0; index<sensor.size(); ++index)
      {
        data[index] = index;
      }
      return;
    }

    void getTime(hidi::Sensor* sensor, const mxArray* n, mxArray*& array)
    {    
      uint32_t* node;
      double* data;
      size_t k;
      size_t K;
      checkUInt32(n);
      node = static_cast<uint32_t*>(mxGetData(n));
      K = mxGetNumberOfElements(n);
      array = mxCreateDoubleMatrix(mxGetM(n), mxGetN(n), mxREAL);
      data = mxGetPr(array);
      for(k = 0; k<K; ++k)
      {
        data[k] = sensor->getTime(node[k]);
      }
      return;
    }

    static hidi::SensorPackage* package = NULL;
    
    static void deleteSensorPackage(void)
    {
      if(package)
      {
        delete package;
        package = NULL;
      }
      return;
    }
    
    void SensorPackageBridge(int nlhs, mxArray** plhs, int nrhs, const mxArray** prhs)
    {
      static MemberMap memberMap;
      uint32_t index;
      std::string memberName;

      checkNumArgs(nrhs, 2);
      convert(prhs[0], index);
      convert(prhs[1], memberName);
      switch(memberMap[memberName])
      {
        case undefined:
        {
          throw("SensorPackageBridge: Undefined function call.");
          break;
        }

        case isConnected:
        {
          checkNumArgs(nrhs, 3);
          static std::string name;
          convert(prhs[2], name);
          convert(hidi::SensorPackage::isConnected(name), plhs[0]);
          break;
        }

        case description:
        {
          checkNumArgs(nrhs, 3);
          static std::string name;
          convert(prhs[2], name);
          convert(hidi::SensorPackage::description(name), plhs[0]);
          break;
        }

        case create:
        {
          checkNumArgs(nrhs, 4);
          static std::string name;
          static std::string parameters;
          convert(prhs[2], name);
          convert(prhs[3], parameters);
          deleteSensorPackage(); // treat package as a singleton
          package = hidi::SensorPackage::create(name, parameters);
          mexAtExit(deleteSensorPackage);
          break;
        }
        
        case destroy:
        {
          deleteSensorPackage();
          break;
        }

        case getAccelerometerArray:
        {
          getSensor(package->getAccelerometerArray(), plhs[0]);
          break;
        }

        case getGyroscopeArray:
        {
          getSensor(package->getGyroscopeArray(), plhs[0]);
          break;
        }

        case getMagnetometerArray:
        {
          getSensor(package->getMagnetometerArray(), plhs[0]);
          break;
        }

        case getAltimeter:
        {
          getSensor(package->getAltimeter(), plhs[0]);
          break;
        }
        
        case getCamera:
        {
          getSensor(package->getCamera(), plhs[0]);
          break;
        }

        case getGPSReceiver:
        {
          getSensor(package->getGPSReceiver(), plhs[0]);
          break;
        }

        case getPedometer:
        {
          getSensor(package->getPedometer(), plhs[0]);
          break;
        }

        case accelerometerArrayRefresh:
        {
          hidi::AccelerometerArray* sensor = package->getAccelerometerArray()[index];
          sensor->refresh();
          break;
        }

        case accelerometerArrayHasData:
        {
          hidi::AccelerometerArray* sensor = package->getAccelerometerArray()[index];
          convert(sensor->hasData(), plhs[0]);
          break;
        }

        case accelerometerArrayFirst:
        {
          hidi::AccelerometerArray* sensor = package->getAccelerometerArray()[index];
          convert(sensor->first(), plhs[0]);
          break;
        }

        case accelerometerArrayLast:
        {
          hidi::AccelerometerArray* sensor = package->getAccelerometerArray()[index];
          convert(sensor->last(), plhs[0]);
          break;
        }

        case accelerometerArrayGetTime:
        {
          checkNumArgs(nrhs, 3);
          hidi::AccelerometerArray* sensor = package->getAccelerometerArray()[index];
          getTime(static_cast<hidi::Sensor*>(sensor), prhs[2], plhs[0]);
          break;
        }

        case getSpecificForce:
        {
          checkNumArgs(nrhs, 4);
          hidi::AccelerometerArray* sensor = package->getAccelerometerArray()[index];
          const mxArray* n = prhs[2];
          const mxArray* ax = prhs[3];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          uint32_t* axis = static_cast<uint32_t*>(mxGetData(ax));
          size_t N = mxGetNumberOfElements(n);
          size_t A = mxGetNumberOfElements(ax);
          double* data;
          size_t i;
          size_t j;
          size_t k;
          checkUInt32(n);
          checkUInt32(ax);
          plhs[0] = mxCreateDoubleMatrix(N, A, mxREAL);
          data = mxGetPr(plhs[0]);
          k = 0;
          for(j = 0; j<A; ++j)
          {
            for(i = 0; i<N; ++i)
            {
              data[k] = sensor->getSpecificForce(node[i], axis[j]);
              ++k;
            }
          }
          break;
        }

        case getAccelerometerRandomWalk:
        {
          hidi::AccelerometerArray* sensor = package->getAccelerometerArray()[index];
          convert(sensor->getAccelerometerRandomWalk(), plhs[0]);
          break;
        }

        case getAccelerometerTurnOnBiasSigma:
        {
          hidi::AccelerometerArray* sensor = package->getAccelerometerArray()[index];
          convert(sensor->getAccelerometerTurnOnBiasSigma(), plhs[0]);
          break;
        }

        case getAccelerometerInRunBiasSigma:
        {
          hidi::AccelerometerArray* sensor = package->getAccelerometerArray()[index];
          convert(sensor->getAccelerometerInRunBiasSigma(), plhs[0]);
          break;
        }

        case getAccelerometerInRunBiasStability:
        {
          hidi::AccelerometerArray* sensor = package->getAccelerometerArray()[index];
          convert(sensor->getAccelerometerInRunBiasStability(), plhs[0]);
          break;
        }

        case getAccelerometerTurnOnScaleSigma:
        {
          hidi::AccelerometerArray* sensor = package->getAccelerometerArray()[index];
          convert(sensor->getAccelerometerTurnOnScaleSigma(), plhs[0]);
          break;
        }

        case getAccelerometerInRunScaleSigma:
        {
          hidi::AccelerometerArray* sensor = package->getAccelerometerArray()[index];
          convert(sensor->getAccelerometerInRunScaleSigma(), plhs[0]);
          break;
        }

        case getAccelerometerInRunScaleStability:
        {
          hidi::AccelerometerArray* sensor = package->getAccelerometerArray()[index];
          convert(sensor->getAccelerometerInRunScaleStability(), plhs[0]);
          break;
        }
        
        case altimeterRefresh:
        {
          hidi::Altimeter* sensor = package->getAltimeter()[index];
          sensor->refresh();
          break;
        }

        case altimeterHasData:
        {
          hidi::Altimeter* sensor = package->getAltimeter()[index];
          convert(sensor->hasData(), plhs[0]);
          break;
        }

        case altimeterFirst:
        {
          hidi::Altimeter* sensor = package->getAltimeter()[index];
          convert(sensor->first(), plhs[0]);
          break;
        }

        case altimeterLast:
        {
          hidi::Altimeter* sensor = package->getAltimeter()[index];
          convert(sensor->last(), plhs[0]);
          break;
        }

        case altimeterGetTime:
        {
          checkNumArgs(nrhs, 3);
          hidi::Altimeter* sensor = package->getAltimeter()[index];
          getTime(static_cast<hidi::Sensor*>(sensor), prhs[2], plhs[0]);
          break;
        }

        case getAltitude:
        {
          checkNumArgs(nrhs, 3);
          hidi::Altimeter* sensor = package->getAltimeter()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          double* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateDoubleMatrix(mxGetM(n), mxGetN(n), mxREAL);
          data = mxGetPr(plhs[0]);
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->getAltitude(node[k]);
          }
          break;
        }
        
        case cameraRefresh:
        {
          hidi::Camera* sensor = package->getCamera()[index];
          sensor->refresh();
          break;
        }

        case cameraHasData:
        {
          hidi::Camera* sensor = package->getCamera()[index];
          convert(sensor->hasData(), plhs[0]);
          break;
        }

        case cameraFirst:
        {
          hidi::Camera* sensor = package->getCamera()[index];
          convert(sensor->first(), plhs[0]);
          break;
        }

        case cameraLast:
        {
          hidi::Camera* sensor = package->getCamera()[index];
          convert(sensor->last(), plhs[0]);
          break;
        }

        case cameraGetTime:
        {
          checkNumArgs(nrhs, 3);
          hidi::Camera* sensor = package->getCamera()[index];
          getTime(static_cast<hidi::Sensor*>(sensor), prhs[2], plhs[0]);
          break;
        }
        
        case interpretLayers:
        {
          hidi::Camera* sensor = package->getCamera()[index];
          convert(sensor->interpretLayers(), plhs[0]);
          break;
        }
        
        case numStrides:
        {
          hidi::Camera* sensor = package->getCamera()[index];
          convert(sensor->numStrides(), plhs[0]);
          break;
        }
        
        case numSteps:
        {
          hidi::Camera* sensor = package->getCamera()[index];
          convert(sensor->numSteps(), plhs[0]);
          break;
        }
        
        case strideMin:
        {
          checkNumArgs(nrhs, 3);
          hidi::Camera* sensor = package->getCamera()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          uint32_t* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateNumericMatrix(mxGetM(n), mxGetN(n), mxUINT32_CLASS, mxREAL);
          data = static_cast<uint32_t*>(mxGetData(plhs[0]));
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->strideMin(node[k]);
          }
          break;
        }
        
        case strideMax:
        {
          checkNumArgs(nrhs, 3);
          hidi::Camera* sensor = package->getCamera()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          uint32_t* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateNumericMatrix(mxGetM(n), mxGetN(n), mxUINT32_CLASS, mxREAL);
          data = static_cast<uint32_t*>(mxGetData(plhs[0]));
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->strideMax(node[k]);
          }
          break;
        }
        
        case stepMin:
        {
          checkNumArgs(nrhs, 3);
          hidi::Camera* sensor = package->getCamera()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          uint32_t* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateNumericMatrix(mxGetM(n), mxGetN(n), mxUINT32_CLASS, mxREAL);
          data = static_cast<uint32_t*>(mxGetData(plhs[0]));
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->stepMin(node[k]);
          }
          break;
        }
        
        case stepMax:
        {
          checkNumArgs(nrhs, 3);
          hidi::Camera* sensor = package->getCamera()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          uint32_t* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateNumericMatrix(mxGetM(n), mxGetN(n), mxUINT32_CLASS, mxREAL);
          data = static_cast<uint32_t*>(mxGetData(plhs[0]));
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->stepMax(node[k]);
          }
          break;
        }
        
        case projection:
        {
          checkNumArgs(nrhs, 5);
          hidi::Camera* sensor = package->getCamera()[index];
          const mxArray* f = prhs[2];
          const mxArray* r = prhs[3];
          const mxArray* d = prhs[4];
          double* forward = mxGetPr(f);
          double* right = mxGetPr(r);
          double* down = mxGetPr(d);
          size_t M = mxGetM(f);
          size_t N = mxGetN(f);
          size_t K = mxGetNumberOfElements(f);
          double* stride;
          double* step;
          size_t k;
          checkDouble(f);
          checkDouble(r);
          checkDouble(d);
          checkNumRows(r, M);
          checkNumRows(d, M);
          checkNumCols(r, N);
          checkNumCols(d, N);
          plhs[0] = mxCreateDoubleMatrix(M, N, mxREAL);
          plhs[1] = mxCreateDoubleMatrix(M, N, mxREAL);
          stride = mxGetPr(plhs[0]);
          step = mxGetPr(plhs[1]);
          for(k = 0; k<K; ++k)
          {
            sensor->projection(forward[k], right[k], down[k], stride[k], step[k]);
          }
          break;
        }
        
        case inverseProjection:
        {
          checkNumArgs(nrhs, 4);
          hidi::Camera* sensor = package->getCamera()[index];
          const mxArray* strideArray = prhs[2];
          const mxArray* stepArray = prhs[3];
          double* stride = mxGetPr(strideArray);
          double* step = mxGetPr(stepArray);
          size_t M = mxGetM(strideArray);
          size_t N = mxGetN(strideArray);
          size_t K = mxGetNumberOfElements(strideArray);
          double* forward;
          double* right;
          double* down;
          size_t k;
          checkDouble(strideArray);
          checkDouble(stepArray);
          checkNumRows(stepArray, M);
          checkNumCols(stepArray, N);
          plhs[0] = mxCreateDoubleMatrix(M, N, mxREAL);
          plhs[1] = mxCreateDoubleMatrix(M, N, mxREAL);
          plhs[2] = mxCreateDoubleMatrix(M, N, mxREAL);
          forward = mxGetPr(plhs[0]);
          right = mxGetPr(plhs[1]);
          down = mxGetPr(plhs[2]);
          for(k = 0; k<K; ++k)
          {
            sensor->inverseProjection(stride[k], step[k], forward[k], right[k], down[k]);
          }
          break;
        }
        
        case getImageUInt8:
        {
          checkNumArgs(nrhs, 5);
          hidi::Camera* sensor = package->getCamera()[index];
          const mxArray* nodeArray = prhs[2];
          const mxArray* layerArray = prhs[3];
          const mxArray* imgArray = prhs[4];
          uint32_t node = (*static_cast<uint32_t*>(mxGetData(nodeArray)));
          uint32_t layer = (*static_cast<uint32_t*>(mxGetData(layerArray)));
          uint8_t* img = static_cast<uint8_t*>(mxGetData(imgArray));
          size_t K = mxGetNumberOfElements(imgArray);
          std::vector<uint8_t> imgIO(K);
          size_t k;
          checkNumElements(nodeArray, 1);
          checkNumElements(layerArray, 1);
          for(k = 0; k<K; ++k)
          {
            imgIO[k] = img[k];
          }
          sensor->getImageUInt8(node, layer, imgIO);
          convert(imgIO, plhs[0]);
          break;
        }
        
        case getImageDouble:
        {
          checkNumArgs(nrhs, 5);
          hidi::Camera* sensor = package->getCamera()[index];
          const mxArray* nodeArray = prhs[2];
          const mxArray* layerArray = prhs[3];
          const mxArray* imgArray = prhs[4];
          uint32_t node = (*static_cast<uint32_t*>(mxGetData(nodeArray)));
          uint32_t layer = (*static_cast<uint32_t*>(mxGetData(layerArray)));
          double* img = mxGetPr(imgArray);
          size_t K = mxGetNumberOfElements(imgArray);
          std::vector<double> imgIO(K);
          size_t k;
          checkNumElements(nodeArray, 1);
          checkNumElements(layerArray, 1);
          for(k = 0; k<K; ++k)
          {
            imgIO[k] = img[k];
          }
          sensor->getImageDouble(node, layer, imgIO);
          convert(imgIO, plhs[0]);
          break;
        }

        case gpsReceiverRefresh:
        {
          hidi::GPSReceiver* sensor = package->getGPSReceiver()[index];
          sensor->refresh();
          break;
        }

        case gpsReceiverHasData:
        {
          hidi::GPSReceiver* sensor = package->getGPSReceiver()[index];
          convert(sensor->hasData(), plhs[0]);
          break;
        }

        case gpsReceiverFirst:
        {
          hidi::GPSReceiver* sensor = package->getGPSReceiver()[index];
          convert(sensor->first(), plhs[0]);
          break;
        }

        case gpsReceiverLast:
        {
          hidi::GPSReceiver* sensor = package->getGPSReceiver()[index];
          convert(sensor->last(), plhs[0]);
          break;
        }

        case gpsReceiverGetTime:
        {
          checkNumArgs(nrhs, 3);
          hidi::GPSReceiver* sensor = package->getGPSReceiver()[index];
          getTime(static_cast<hidi::Sensor*>(sensor), prhs[2], plhs[0]);
          break;
        }

        case getLongitude:
        {
          checkNumArgs(nrhs, 3);
          hidi::GPSReceiver* sensor = package->getGPSReceiver()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          double* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateDoubleMatrix(mxGetM(n), mxGetN(n), mxREAL);
          data = mxGetPr(plhs[0]);
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->getLongitude(node[k]);
          }
          break;
        }

        case getLatitude:
        {
          checkNumArgs(nrhs, 3);
          hidi::GPSReceiver* sensor = package->getGPSReceiver()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          double* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateDoubleMatrix(mxGetM(n), mxGetN(n), mxREAL);
          data = mxGetPr(plhs[0]);
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->getLatitude(node[k]);
          }
          break;
        }

        case getHeight:
        {
          checkNumArgs(nrhs, 3);
          hidi::GPSReceiver* sensor = package->getGPSReceiver()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          double* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateDoubleMatrix(mxGetM(n), mxGetN(n), mxREAL);
          data = mxGetPr(plhs[0]);
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->getHeight(node[k]);
          }
          break;
        }

        case hasPrecision:
        {
          hidi::GPSReceiver* sensor = package->getGPSReceiver()[index];
          convert(sensor->hasPrecision(), plhs[0]);
          break;
        }

        case getHDOP:
        {
          checkNumArgs(nrhs, 3);
          hidi::GPSReceiver* sensor = package->getGPSReceiver()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          double* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateDoubleMatrix(mxGetM(n), mxGetN(n), mxREAL);
          data = mxGetPr(plhs[0]);
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->getHDOP(node[k]);
          }
          break;
        }

        case getVDOP:
        {
          checkNumArgs(nrhs, 3);
          hidi::GPSReceiver* sensor = package->getGPSReceiver()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          double* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateDoubleMatrix(mxGetM(n), mxGetN(n), mxREAL);
          data = mxGetPr(plhs[0]);
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->getVDOP(node[k]);
          }
          break;
        }

        case getPDOP:
        {
          checkNumArgs(nrhs, 3);
          hidi::GPSReceiver* sensor = package->getGPSReceiver()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          double* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateDoubleMatrix(mxGetM(n), mxGetN(n), mxREAL);
          data = mxGetPr(plhs[0]);
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->getPDOP(node[k]);
          }
          break;
        }

        case gyroscopeArrayRefresh:
        {
          hidi::GyroscopeArray* sensor = package->getGyroscopeArray()[index];
          sensor->refresh();
          break;
        }

        case gyroscopeArrayHasData:
        {
          hidi::GyroscopeArray* sensor = package->getGyroscopeArray()[index];
          convert(sensor->hasData(), plhs[0]);
          break;
        }

        case gyroscopeArrayFirst:
        {
          hidi::GyroscopeArray* sensor = package->getGyroscopeArray()[index];
          convert(sensor->first(), plhs[0]);
          break;
        }

        case gyroscopeArrayLast:
        {
          hidi::GyroscopeArray* sensor = package->getGyroscopeArray()[index];
          convert(sensor->last(), plhs[0]);
          break;
        }

        case gyroscopeArrayGetTime:
        {
          checkNumArgs(nrhs, 3);
          hidi::GyroscopeArray* sensor = package->getGyroscopeArray()[index];
          getTime(static_cast<hidi::Sensor*>(sensor), prhs[2], plhs[0]);
          break;
        }

        case getAngularRate:
        {
          checkNumArgs(nrhs, 4);
          hidi::GyroscopeArray* sensor = package->getGyroscopeArray()[index];
          const mxArray* n = prhs[2];
          const mxArray* ax = prhs[3];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          uint32_t* axis = static_cast<uint32_t*>(mxGetData(ax));
          size_t N = mxGetNumberOfElements(n);
          size_t A = mxGetNumberOfElements(ax);
          double* data;
          size_t i;
          size_t j;
          size_t k;
          checkUInt32(n);
          checkUInt32(ax);
          plhs[0] = mxCreateDoubleMatrix(N, A, mxREAL);
          data = mxGetPr(plhs[0]);
          k = 0;
          for(j = 0; j<A; ++j)
          {
            for(i = 0; i<N; ++i)
            {
              data[k] = sensor->getAngularRate(node[i], axis[j]);
              ++k;
            }
          }
          break;
        }

        case getGyroscopeRandomWalk:
        {
          hidi::GyroscopeArray* sensor = package->getGyroscopeArray()[index];
          convert(sensor->getGyroscopeRandomWalk(), plhs[0]);
          break;
        }

        case getGyroscopeTurnOnBiasSigma:
        {
          hidi::GyroscopeArray* sensor = package->getGyroscopeArray()[index];
          convert(sensor->getGyroscopeTurnOnBiasSigma(), plhs[0]);
          break;
        }

        case getGyroscopeInRunBiasSigma:
        {
          hidi::GyroscopeArray* sensor = package->getGyroscopeArray()[index];
          convert(sensor->getGyroscopeInRunBiasSigma(), plhs[0]);
          break;
        }

        case getGyroscopeInRunBiasStability:
        {
          hidi::GyroscopeArray* sensor = package->getGyroscopeArray()[index];
          convert(sensor->getGyroscopeInRunBiasStability(), plhs[0]);
          break;
        }

        case getGyroscopeTurnOnScaleSigma:
        {
          hidi::GyroscopeArray* sensor = package->getGyroscopeArray()[index];
          convert(sensor->getGyroscopeTurnOnScaleSigma(), plhs[0]);
          break;
        }

        case getGyroscopeInRunScaleSigma:
        {
          hidi::GyroscopeArray* sensor = package->getGyroscopeArray()[index];
          convert(sensor->getGyroscopeInRunScaleSigma(), plhs[0]);
          break;
        }

        case getGyroscopeInRunScaleStability:
        {
          hidi::GyroscopeArray* sensor = package->getGyroscopeArray()[index];
          convert(sensor->getGyroscopeInRunScaleStability(), plhs[0]);
          break;
        }

        case magnetometerArrayRefresh:
        {
          hidi::MagnetometerArray* sensor = package->getMagnetometerArray()[index];
          sensor->refresh();
          break;
        }

        case magnetometerArrayHasData:
        {
          hidi::MagnetometerArray* sensor = package->getMagnetometerArray()[index];
          convert(sensor->hasData(), plhs[0]);
          break;
        }

        case magnetometerArrayFirst:
        {
          hidi::MagnetometerArray* sensor = package->getMagnetometerArray()[index];
          convert(sensor->first(), plhs[0]);
          break;
        }

        case magnetometerArrayLast:
        {
          hidi::MagnetometerArray* sensor = package->getMagnetometerArray()[index];
          convert(sensor->last(), plhs[0]);
          break;
        }

        case magnetometerArrayGetTime:
        {
          checkNumArgs(nrhs, 3);
          hidi::MagnetometerArray* sensor = package->getMagnetometerArray()[index];
          getTime(static_cast<hidi::Sensor*>(sensor), prhs[2], plhs[0]);
          break;
        }

        case getMagneticField:
        {
          checkNumArgs(nrhs, 4);
          hidi::MagnetometerArray* sensor = package->getMagnetometerArray()[index];
          const mxArray* n = prhs[2];
          const mxArray* ax = prhs[3];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          uint32_t* axis = static_cast<uint32_t*>(mxGetData(ax));
          size_t N = mxGetNumberOfElements(n);
          size_t A = mxGetNumberOfElements(ax);
          double* data;
          size_t i;
          size_t j;
          size_t k;
          checkUInt32(n);
          checkUInt32(ax);
          plhs[0] = mxCreateDoubleMatrix(N, A, mxREAL);
          data = mxGetPr(plhs[0]);
          k = 0;
          for(j = 0; j<A; ++j)
          {
            for(i = 0; i<N; ++i)
            {
              data[k] = sensor->getMagneticField(node[i], axis[j]);
              ++k;
            }
          }
          break;
        }

        case pedometerRefresh:
        {
          hidi::Pedometer* sensor = package->getPedometer()[index];
          sensor->refresh();
          break;
        }

        case pedometerHasData:
        {
          hidi::Pedometer* sensor = package->getPedometer()[index];
          convert(sensor->hasData(), plhs[0]);
          break;
        }

        case pedometerFirst:
        {
          hidi::Pedometer* sensor = package->getPedometer()[index];
          convert(sensor->first(), plhs[0]);
          break;
        }

        case pedometerLast:
        {
          hidi::Pedometer* sensor = package->getPedometer()[index];
          convert(sensor->last(), plhs[0]);
          break;
        }

        case pedometerGetTime:
        {
          checkNumArgs(nrhs, 3);
          hidi::Pedometer* sensor = package->getPedometer()[index];
          getTime(static_cast<hidi::Sensor*>(sensor), prhs[2], plhs[0]);
          break;
        }

        case isStepComplete:
        {
          checkNumArgs(nrhs, 3);
          hidi::Pedometer* sensor = package->getPedometer()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          bool* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateLogicalMatrix(mxGetM(n), mxGetN(n));
          data = static_cast<bool*>(mxGetData(plhs[0]));
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->isStepComplete(node[k]);
          }
          break;
        }

        case getStepMagnitude:
        {
          checkNumArgs(nrhs, 3);
          hidi::Pedometer* sensor = package->getPedometer()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          double* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateDoubleMatrix(mxGetM(n), mxGetN(n), mxREAL);
          data = mxGetPr(plhs[0]);
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->getStepMagnitude(node[k]);
          }
          break;
        }

        case getStepDeviation:
        {
          checkNumArgs(nrhs, 3);
          hidi::Pedometer* sensor = package->getPedometer()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          double* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateDoubleMatrix(mxGetM(n), mxGetN(n), mxREAL);
          data = mxGetPr(plhs[0]);
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->getStepDeviation(node[k]);
          }
          break;
        }

        case getStepID:
        {
          checkNumArgs(nrhs, 3);
          hidi::Pedometer* sensor = package->getPedometer()[index];
          const mxArray* n = prhs[2];
          uint32_t* node = static_cast<uint32_t*>(mxGetData(n));
          size_t N = mxGetNumberOfElements(n);
          uint32_t* data;
          size_t k;
          checkUInt32(n);
          plhs[0] = mxCreateNumericMatrix(mxGetM(n), mxGetN(n), mxUINT32_CLASS, mxREAL);
          data = static_cast<uint32_t*>(mxGetData(plhs[0]));
          for(k = 0; k<N; ++k)
          {
            data[k] = sensor->getStepID(node[k]);
          }
          break;
        }

        default:
        {
          throw("SensorPackageBridge: Invalid member function call.");
        }
      }
      return;
    }
  }
}

#endif
