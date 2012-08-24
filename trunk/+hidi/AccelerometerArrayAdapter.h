#ifndef HIDIACCELEROMETERARRAYADAPTER_H
#define HIDIACCELEROMETERARRAYADAPTER_H

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

    virtual double getSpecificForce(const uint32_t& n, const uint32_t& ax)
    {
      return (source->getSpecificForce(n, ax));
    }

    virtual double getAccelerometerRandomWalk(void)
    {
      return (source->getAccelerometerRandomWalk());
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
