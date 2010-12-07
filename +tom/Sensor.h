#ifndef SENSOR_H
#define SENSOR_H

#include "WorldTime.h"
#include "Trajectory.h"

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
  protected:
    /**
     * Protected constructor
     *
     * @param[in] initialTime less than or equal to the time stamp of the first data node
     *
     * NOTES
     * Each subclass constructor must initialize this base class
     * (MATLAB) Initialize by calling this = this@tom.Sensor(initialTime);
     */
    Sensor(const WorldTime initialTime)
    {}

  public:
    /**
     * Alias for a pointer to a sensor that is not meant to be deleted
     */
    typedef Sensor* Handle;

    /**
     * Incorporate new data and allow old data to expire
     *
     * @param[in] x best available estimate of body trajectory
     *
     * NOTES
     * The input trajectory:
     *   May assist in efficient processing of sensor data
     *   May assist in fault detection and outlier removal
     *   May be a poor estimate of the body trajectory
     *   Should have approximately no effect on functions in derived classs
     * This function updates the object state without waiting for new data to be acquired
     */
    virtual void refresh(const Trajectory* x) = 0;

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
     * All time stamps must be greater than or equal to the initial time provided to the constructor
     * Time stamps must not decrease with increasing indices
     * Throws an exception if data at the node is invalid
     */
    virtual WorldTime getTime(unsigned n) = 0;
  };
}

#endif
