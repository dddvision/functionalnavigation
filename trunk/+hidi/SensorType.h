#ifndef HIDISENSORTYPE_H
#define HIDISENSORTYPE_H

#include "hidi.h"

namespace hidi
{
  typedef enum
  {
    ACCELEROMETER_ARRAY,
    GYROSCOPE_ARRAY,
    MAGNETOMETER_ARRAY,
    ALTIMETER,
    GPS_RECEIVER
  } SensorType;
}
  
#endif
