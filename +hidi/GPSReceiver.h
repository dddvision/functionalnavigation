#ifndef GPSRECEIVER_H
#define GPSRECEIVER_H

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
     * @param[in] n data index
     * @return      longitude (radians)
     *
     * @note
     * Throws an exception if the data index is out of range
     */
    virtual double getLongitude(uint32_t n) = 0;

    /**
     * Get geodetic latitude.
     *
     * @param[in] n data index
     * @return      geodetic latitude (radians)
     *
     * @note
     * Throws an exception if the data index is out of range
     */
    virtual double getLatitude(uint32_t n) = 0;

    /**
     * Get height above WGS84.
     *
     * @param[in] n data index
     * @return      height (meters)
     *
     * @note
     * Throws an exception if the data index is out of range
     */
    virtual double getHeight(uint32_t n) = 0;

    /**
     * Check whether precision information is available.
     *
     * @return true if precision information is available and false otherwise
     */
    virtual bool hasPrecision(void) = 0;

    /**
     * Get horizontal dilution of precision.
     *
     * @param[in] n data index
     * @return      horizontal dilution of precision (unitless)
     *
     * @note
     * Throws an exception if information is not available
     * Throws an exception if the data index is out of range
     */
    virtual double getPrecisionHorizontal(uint32_t n) = 0;

    /**
     * Get vertical dilution of precision.
     *
     * @param[in] n data index
     * @return      vertical dilution of precision (unitless)
     *
     * @note
     * Throws an exception if information is not available
     * Throws an exception if the data index is out of range
     */
    virtual double getPrecisionVertical(uint32_t n) = 0;

    /**
     * Get standard deviation of equivalent circular error.
     *
     * @param[in] n data index
     * @return      standard deviation (meters)
     *
     * @note
     * Throws an exception if information is not available
     * Throws an exception if the data index is out of range
     */
    virtual double getPrecisionCircular(uint32_t n) = 0;

    /**
     * Virtual base class destructor.
     */
    virtual ~GPSReceiver(void)
    {}
  };
}

#endif

