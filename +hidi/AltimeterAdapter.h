#ifndef HIDIALTIMETERADAPTER_H
#define HIDIALTIMETERADAPTER_H

#include "Altimeter.h"
#include "SensorAdapter.h"

namespace hidi
{
  class AltimeterAdapter : public virtual hidi::Altimeter, public hidi::SensorAdapter
  {
  private:
    hidi::Altimeter* source;

  public:
    AltimeterAdapter(hidi::Altimeter* source) :
      SensorAdapter(source)
    {
      this->source = source;
    }

    virtual double getAltitude(const uint32_t& n)
    {
      return (source->getAltitude(n));
    }
    
    virtual ~AltimeterAdapter(void)
    {}
  };
}

#endif
