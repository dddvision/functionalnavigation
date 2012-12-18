#ifndef HIDIMAGNETOMETERARRAY_H
#define HIDIMAGNETOMETERARRAY_H

#include "Sensor.h"

namespace hidi
{
  /**
   * This class represents an array of three magnetometers.
   */
  class MagnetometerArray : public virtual Sensor
  {
  private:
    /**
     * Prevents deep copying.
     */
    MagnetometerArray(const MagnetometerArray&);

    /**
     * Prevents assignment.
     */
    MagnetometerArray& operator=(const MagnetometerArray&);

  protected:
    /**
     * Protected constructor.
     */
    MagnetometerArray(void)
    {}

  public:   
    /**
     * Get magnetometer data.
     * 
     * @param[in] n  data index (MATLAB: N-by-1)
     * @param[in] ax axis index (MATLAB: 1-by-A)
     * @return       average magnetic field during the preceding integration period (microtesla) (MATLAB: N-by-A)
     *
     * @note
     * The axis interpretation is typically 0=Forward, 1=Right, 2=Down.
     * This measurement is taken by integrating about the instantaneous axis as it moves 
     *   during the preceding time period and dividing by the time period.
     * Throws an exception if any index is out of range.
     */
    virtual double getMagneticField(const uint32_t& n, const uint32_t& ax) = 0;

    /**
     * Virtual base class destructor.
     */
    virtual ~MagnetometerArray(void)
    {}
  };
}

#endif
