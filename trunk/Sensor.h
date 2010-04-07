#ifndef SENSOR_H
#define SENSOR_H

#include "tommas.h"

namespace tommas
{
  class Sensor
  {
  public:
    virtual void refresh(void);
    virtual bool hasData(void);
    virtual NodeIndex first(void);
    virtual NodeIndex last(void);
    virtual Time getTime(NodeIndex);
  };
}

#endif

