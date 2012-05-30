#ifndef MAGNETOMETERARRAY_H
#define MAGNETOMETERARRAY_H

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
     * @param[in]  n  data index (MATLAB: N-by-1)
     * @param[in]  ax axis index (MATLAB: 1-by-A)
     * @return        average magnetic field during the preceding integration period (tesla) (MATLAB: N-by-A)
     *
     * @note
     * This measurement is taken by integrating about the instantaneous axis as it moves 
     *   during the preceding time period and dividing by the time period
     * Throws an exception if either input index is out of range
     */
    virtual double getMagneticField(uint32_t n, uint32_t ax) = 0;

    /**
     * Get calibrated magnetometer data.
     *
     * @param[in]  n  data index (MATLAB: N-by-1)
     * @param[in]  ax axis index (MATLAB: 1-by-A)
     * @return        average magnetic field during the preceding integration period (tesla) (MATLAB: N-by-A)
     *
     * @note
     * @see getMagneticField()
     * Calibration may correct bias, scale, and/or orientation, depending on the specific implementation
     * The calibrated axis interpretation is typically 0=Forward, 1=Right, 2=Down
     */
    virtual double getMagneticFieldCalibrated(uint32_t n, uint32_t ax) = 0;

    /**
     * Virtual base class destructor.
     */
    virtual ~MagnetometerArray(void)
    {}
  };
}

#endif
