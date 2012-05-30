#ifndef ACCELEROMETERARRAYADAPTER_H
#define ACCELEROMETERARRAYADAPTER_H

#include "AccelerometerArray.h"
#include "SensorAdapter.h"

namespace hidi
{
  class AccelerometerArrayAdapter : public virtual hidi::AccelerometerArray, public hidi::SensorAdapter
  {
  private:
    hidi::AccelerometerArray* source;

  public:
    AccelerometerArrayAdapter(hidi::AccelerometerArray* source) : SensorAdapter(source)
    {
      this->source = source;
    }

    virtual double getSpecificForce(uint32_t n, uint32_t ax)
    {
      return (source->getSpecificForce(n, ax));
    }

    virtual double getSpecificForceCalibrated(uint32_t n, uint32_t ax)
    {
      return (source->getSpecificForceCalibrated(n, ax));
    }

    virtual double getAccelerometerVelocityRandomWalk(void)
    {
      return (source->getAccelerometerVelocityRandomWalk());
    }

    virtual double getAccelerometerTurnOnBiasSigma(void)
    {
      return (source->getAccelerometerTurnOnBiasSigma());
    }

    virtual double getAccelerometerInRunBiasSigma(void)
    {
      return (source->getAccelerometerInRunBiasSigma());
    }

    virtual double getAccelerometerInRunBiasStability(void)
    {
      return (source->getAccelerometerInRunBiasStability());
    }

    virtual double getAccelerometerTurnOnScaleSigma(void)
    {
      return (source->getAccelerometerTurnOnScaleSigma());
    }

    virtual double getAccelerometerInRunScaleSigma(void)
    {
      return (source->getAccelerometerInRunScaleSigma());
    }

    virtual double getAccelerometerInRunScaleStability(void)
    {
      return (source->getAccelerometerInRunScaleStability());
    }
    
    virtual ~AccelerometerArrayAdapter(void)
    {}
  };
}
  
#endif
