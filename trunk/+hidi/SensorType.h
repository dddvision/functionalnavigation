#ifndef HIDISENSORTYPE_H
#define HIDISENSORTYPE_H

#include "hidi.h"

namespace hidi
{
  /**
   * Enumerated sensor type identifiers.
   */
  typedef enum
  {
    ACCELEROMETER_ARRAY = static_cast<uint32_t>(0),
    GYROSCOPE_ARRAY = static_cast<uint32_t>(1),
    MAGNETOMETER_ARRAY = static_cast<uint32_t>(2),
    ALTIMETER = static_cast<uint32_t>(3),
    GPS_RECEIVER = static_cast<uint32_t>(4),
    PEDOMETER = static_cast<uint32_t>(5)
  } SensorType;
}
  
#endif
