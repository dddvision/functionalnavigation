#ifndef HIDIGYROSCOPEARRAYADAPTER_H
#define HIDIGYROSCOPEARRAYADAPTER_H

#include "GyroscopeArray.h"
#include "SensorAdapter.h"

namespace hidi
{
  class GyroscopeArrayAdapter : public virtual hidi::GyroscopeArray, public hidi::SensorAdapter
  {
  private:
    hidi::GyroscopeArray* source;

  public:
    GyroscopeArrayAdapter(hidi::GyroscopeArray* source) :
      SensorAdapter(source)
    {
      this->source = source;
    }

    virtual double getAngularRate(const uint32_t& n, const uint32_t& ax)
    {
      return (source->getAngularRate(n, ax));
    }

    virtual double getGyroscopeRandomWalk(void)
    {
      return (source->getGyroscopeRandomWalk());
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
    
    virtual ~GyroscopeArrayAdapter(void)
    {}
  };
}

#endif
