#ifndef MAGNETOMETERARRAYADAPTER_H
#define MAGNETOMETERARRAYADAPTER_H

#include "MagnetometerArray.h"
#include "SensorAdapter.h"

namespace hidi
{
  class MagnetometerArrayAdapter : public virtual hidi::MagnetometerArray, public hidi::SensorAdapter
  {
  private:
    hidi::MagnetometerArray* source;

  public:
    MagnetometerArrayAdapter(hidi::MagnetometerArray* source) :
      SensorAdapter(source)
    {
      this->source = source;
    }

    virtual double getMagneticField(uint32_t n, uint32_t ax)
    {
      return (source->getMagneticField(n, ax));
    }

    virtual double getMagneticFieldCalibrated(const uint32_t& n, const uint32_t& ax)
    {
      return (source->getMagneticFieldCalibrated(n, ax));
    }
    
    virtual ~MagnetometerArrayAdapter(void)
    {}
  };
}

#endif
