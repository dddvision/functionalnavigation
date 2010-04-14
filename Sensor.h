#ifndef SENSOR_H
#define SENSOR_H

#include "Time.h"

namespace tommas
{
  class Sensor
  {
  public:
    virtual void refresh(void) = 0;
    virtual bool hasData(void) = 0;
    virtual unsigned first(void) = 0;
    virtual unsigned last(void) = 0;
    virtual Time getTime(unsigned) = 0;
  };
}

#endif
