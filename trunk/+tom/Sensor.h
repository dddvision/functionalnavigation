#ifndef SENSOR_H
#define SENSOR_H

#include "WorldTime.h"
#include "Trajectory.h"

namespace tom
{
  /**
   * This class defines methods shared by synchronously time-stamped sensors.
   * All sensors use SI units and radians unless otherwise stated.
   */
  class Sensor
  {
  protected:
    /**
     * Protected constructor.
     *
     * @param[in] initialTime less than or equal to the time stamp of the first data node
     *
     * @note
     * Each subclass constructor must initialize this base class.
     * (MATLAB) Initialize by calling:
     * @code
     *   this = this@tom.Sensor(initialTime);
     * @endcode
     */
    Sensor(const WorldTime initialTime)
    {}

  public:
    /**
     * Alias for a pointer to a sensor that is not meant to be deleted.
     */
    typedef Sensor* Handle;

    /**
     * Incorporate new data and allow old data to expire.
     *
     * @param[in] x best available estimate of body trajectory
     *
     * @note
     * The input trajectory:
     *   May assist in efficient processing of sensor data;
     *   May assist in fault detection and outlier removal;
     *   May be a poor estimate of the body trajectory;
     *   Should have approximately no effect on functions in derived classs.
     * This function updates the object state without waiting for new data to be acquired.
     * Input trajectory is implied constant, even though its type is not explicitly const.
     */
    virtual void refresh(Trajectory* x) = 0;

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
     * Get time stamp at a node.
     *
     * @param[in] n index of a node
     * @return      time stamp at the node
     *
     * @note
     * All time stamps must be greater than or equal to the initial time provided to the constructor.
     * Time stamps must not decrease with increasing indices.
     * Throws an exception if data at the node is invalid.
     */
    virtual WorldTime getTime(uint32_t n) = 0;
    
    /**
     * Virtual base class destructor.
     */
    virtual ~Sensor(void)
    {}
  };
}

#endif
