#ifndef SENSOR_H
#define SENSOR_H

#include "tommas.h"

namespace tommas
{
  typedef unsigned int NodeIndex;

  class Sensor
  {
  public:
    virtual void refresh(void) = 0;
    virtual bool hasData(void) = 0;
    virtual NodeIndex first(void) = 0;
    virtual NodeIndex last(void) = 0;
    virtual Time getTime(NodeIndex) = 0;
  };
}

#endif

