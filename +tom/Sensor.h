#ifndef SENSOR_H
#define SENSOR_H

#include "WorldTime.h"

namespace tom
{
  /**
   * This class defines methods shared by synchronously time-stamped sensors
   * Using GPS time referenced to zero at 1980-00-06T00:00:00 GMT
   *   GPS time is a few seconds ahead of UTC
   * All sensors use SI units and radians unless otherwise stated
   */
  class Sensor
  {
  public:
    /**
     * Incorporate new data and allow old data to expire
     *
     * NOTES
     * Does not block or wait for hardware events
     */
    virtual void refresh(void) = 0;

    /**
     * Check whether data is available
     *
     * @return true if any data is available and false otherwise
     */
    virtual bool hasData(void) = 0;

    /**
     * Return index to the first data node
     *
     * @return index to first node
     *
     * NOTES
     * Throws an exception if no data is available
     */
    virtual unsigned first(void) = 0;

    /**
     * Return index to the last data node
     *
     * @return index to last node
     *
     * NOTES
     * Throws an exception if no data is available
     */
    virtual unsigned last(void) = 0;

    /**
     * Get time stamp at a node
     *
     * @param[in] n index of a node
     * @return      time stamp at the node
     *
     * NOTES
     * Time stamps must not decrease with increasing indices
     * Throws an exception if data at the node is invalid
     */
    virtual WorldTime getTime(unsigned n) = 0;
  };
}

#endif
