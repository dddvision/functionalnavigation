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
     * @param[in] n data index (MATLAB: M-by-N)
     * @return      altitude above the WGS84 ellipsoid (meters) (MATLAB: M-by-N)
     */
    virtual double getAltitude(const uint32_t& n) = 0;

    /**
     * Virtual base class destructor.
     */
    virtual ~Altimeter(void)
    {}
  };
}

#endif
