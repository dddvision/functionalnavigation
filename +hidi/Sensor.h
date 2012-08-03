#ifndef HIDISENSOR_H
#define HIDISENSOR_H

// define integer types
#ifndef _MSC_VER
#include <stdint.h>
#else
#ifndef uint32_t
typedef unsigned __int32 uint32_t;
#endif
#endif

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
     * Get time stamp at a node.
     *
     * @param[in] n index of a node (MATLAB: M-by-N)
     * @return      time stamp at the node (MATLAB: M-by-N)
     *
     * @note
     * Time stamps must not decrease with increasing indices.
     * Throws an exception if data at the node is invalid.
     */
    virtual double getTime(const uint32_t& n) = 0;

    /**
     * Virtual base class destructor.
     */
    virtual ~Sensor(void)
    {}
  };
}

#endif
