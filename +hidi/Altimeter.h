#ifndef HIDIALTIMETER_H
#define HIDIALTIMETER_H

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
     * @return      barometric altitude including inherent bias (meters) (MATLAB: M-by-N)
     *
     * @note
     * The probability distribution associated with the inherent bias is uniform over the sensor range.
     * Throws an exception if any index is out of range.
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
