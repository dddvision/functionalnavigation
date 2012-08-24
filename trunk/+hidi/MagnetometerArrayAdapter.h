#ifndef HIDIMAGNETOMETERARRAYADAPTER_H
#define HIDIMAGNETOMETERARRAYADAPTER_H

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

    virtual double getMagneticField(const uint32_t& n, const uint32_t& ax)
    {
      return (source->getMagneticField(n, ax));
    }
    
    virtual ~MagnetometerArrayAdapter(void)
    {}
  };
}

#endif
