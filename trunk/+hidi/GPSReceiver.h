#ifndef HIDIGPSRECEIVER_H
#define HIDIGPSRECEIVER_H

#include "Sensor.h"

namespace hidi
{
  /**
   * This class represents a single Global Positioning Satellite (GPS) receiver.
   */
  class GPSReceiver : public virtual Sensor
  {
  private:
    /**
     * Prevents deep copying.
     */
    GPSReceiver(const GPSReceiver&);

    /**
     * Prevents assignment.
     */
    GPSReceiver& operator=(const GPSReceiver&);

  protected:
    /**
     * Protected constructor.
     */
    GPSReceiver(void)
    {}

  public:
    /**
     * Get longitude.
     *
     * @param[in] n data index (MATLAB: M-by-N)
     * @return      longitude (radians) (MATLAB: M-by-N)
     *
     * @note
     * Throws an exception if any index is out of range.
     */
    virtual double getLongitude(const uint32_t& n) = 0;

    /**
     * Get geodetic latitude.
     *
     * @param[in] n data index (MATLAB: M-by-N)
     * @return      geodetic latitude (radians) (MATLAB: M-by-N)
     *
     * @note
     * Throws an exception if any index is out of range.
     */
    virtual double getLatitude(const uint32_t& n) = 0;

    /**
     * Get height above WGS84.
     *
     * @param[in] n data index (MATLAB: M-by-N)
     * @return      height (meters) (MATLAB: M-by-N)
     *
     * @note
     * Throws an exception if any index is out of range.
     */
    virtual double getHeight(const uint32_t& n) = 0;

    /**
     * Check whether precision information is available.
     *
     * @return true if precision information is available and false otherwise
     */
    virtual bool hasPrecision(void) = 0;

    /**
     * Get horizontal dilution of precision.
     *
     * @param[in] n data index (MATLAB: M-by-N)
     * @return      horizontal dilution of precision (unitless) (MATLAB: M-by-N)
     *
     * @note
     * Throws an exception if precision information is not available.
     * Throws an exception if any index is out of range.
     */
    virtual double getHDOP(const uint32_t& n) = 0;

    /**
     * Get vertical dilution of precision.
     *
     * @param[in] n data index (MATLAB: M-by-N)
     * @return      vertical dilution of precision (unitless) (MATLAB: M-by-N)
     *
     * @note
     * Throws an exception if precision information is not available.
     * Throws an exception if any index is out of range.
     */
    virtual double getVDOP(const uint32_t& n) = 0;

    /**
     * Get position dilution of precision.
     *
     * @param[in] n data index (MATLAB: M-by-N)
     * @return      standard deviation (unitless) (MATLAB: M-by-N)
     *
     * @note
     * Throws an exception if precision information is not available.
     * Throws an exception if any index is out of range.
     */
    virtual double getPDOP(const uint32_t& n) = 0;

    /**
     * Virtual base class destructor.
     */
    virtual ~GPSReceiver(void)
    {}
  };
}

#endif

