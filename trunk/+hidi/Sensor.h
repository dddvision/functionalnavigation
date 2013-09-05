#ifndef HIDISENSOR_H
#define HIDISENSOR_H

#include "hidi.h"

namespace hidi
{
  /**
   * This class defines methods shared by synchronously time-stamped sensors.
   *
   * @note
   * All sensors use SI units and radians unless otherwise stated.
   */
  class Sensor
  {
  private:
    /**
     * Prevents deep copying.
     */
    Sensor(const Sensor&);

    /**
     * Prevents assignment.
     */
    Sensor& operator=(const Sensor&);

  protected:
    /**
     * Protected constructor.
     */
    Sensor(void)
    {}

  public:
    /**
     * Incorporate new data and allow old data to expire.
     *
     * @note
     * This function updates the object state without waiting for new data to be acquired.
     */
    virtual void refresh(void) = 0;

    /**
     * Check whether data is available.
     *
     * @return true if any data is available and false otherwise
     */
    virtual bool hasData(void) = 0;

    /**
     * Return index to the first data node.
     *
     * @return index to first node
     *
     * @note
     * Throws an exception if no data is available.
     */
    virtual uint32_t first(void) = 0;

    /**
     * Return index to the last data node.
     *
     * @return index to last node
     *
     * @note
     * Throws an exception if no data is available.
     */
    virtual uint32_t last(void) = 0;

    /**
     * Get GPS equivalent time stamp at a node.
     *
     * @param[in] node index of a node (MATLAB: M-by-N)
     * @return         time stamp at the node (MATLAB: M-by-N)
     *
     * @note
     * GPS time is measured from the prime meridian in seconds since 1980 JAN 06 T00:00:00.
     * GPS time may be a few seconds ahead of UTC.
     * Time stamps must not decrease with increasing indices.
     * Throws an exception if any index is out of range.
     */
    virtual double getTime(const uint32_t& node) = 0;

    /**
     * Virtual base class destructor.
     */
    virtual ~Sensor(void)
    {}
  };
}

#endif
