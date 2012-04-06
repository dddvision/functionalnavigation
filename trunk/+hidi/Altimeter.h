#ifndef ALTIMETER_H
#define ALTIMETER_H

#include "Sensor.h"

namespace hidi
{
  /**
   * This class represents a single altimeter.
   */
  class Altimeter : public virtual Sensor
  {
  private:
    /**
     * Prevents deep copying.
     */
    Altimeter(const Altimeter&);

    /**
     * Prevents assignment.
     */
    Altimeter& operator=(const Altimeter&);

  protected:
    /**
     * Protected constructor.
     */
    Altimeter(void)
    {}

  public:
    /**
     * Get altimeter data.
     * 
     * @param[in] n data index
     * @return      altitude above the WGS84 ellipsoid (meters)
     */
    virtual double getAltitude(uint32_t n) = 0;

    /**
     * Virtual base class destructor.
     */
    virtual ~Altimeter(void)
    {}
  };
}

#endif
