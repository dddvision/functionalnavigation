#ifndef GYROSCOPEARRAYADAPTER_H
#define GYROSCOPEARRAYADAPTER_H

#include "GyroscopeArray.h"
#include "SensorAdapter.h"

namespace hidi
{
  class GyroscopeArrayAdapter : public virtual hidi::GyroscopeArray, public hidi::SensorAdapter
  {
  private:
    hidi::GyroscopeArray* source;

  public:
    GyroscopeArrayAdapter(hidi::GyroscopeArray* source) : SensorAdapter(source)
    {
      this->source = source;
    }

    virtual double getAngularRate(uint32_t n, uint32_t ax)
    {
      return (source->getAngularRate(n, ax));
    }

    virtual double getAngularRateCalibrated(uint32_t n, uint32_t ax)
    {
      return (source->getAngularRateCalibrated(n, ax));
    }

    virtual double getGyroscopeAngleRandomWalk(void)
    {
      return (source->getGyroscopeAngleRandomWalk());
    }

    virtual double getGyroscopeTurnOnBiasSigma(void)
    {
      return (source->getGyroscopeTurnOnBiasSigma());
    }

    virtual double getGyroscopeInRunBiasSigma(void)
    {
      return (source->getGyroscopeInRunBiasSigma());
    }

    virtual double getGyroscopeInRunBiasStability(void)
    {
      return (source->getGyroscopeInRunBiasStability());
    }

    virtual double getGyroscopeTurnOnScaleSigma(void)
    {
      return (source->getGyroscopeTurnOnScaleSigma());
    }

    virtual double getGyroscopeInRunScaleSigma(void)
    {
      return (source->getGyroscopeInRunScaleSigma());
    }

    virtual double getGyroscopeInRunScaleStability(void)
    {
      return (source->getGyroscopeInRunScaleStability());
    }
  };
}
  
#endif
