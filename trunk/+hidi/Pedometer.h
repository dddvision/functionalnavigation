#ifndef PEDOMETER_H
#define PEDOMETER_H

#include "Sensor.h"

namespace hidi
{
  class Pedometer : public virtual Sensor
  {
  private:
    /**
     * Prevents deep copying.
     */
    Pedometer(const Pedometer&);

    /**
     * Prevents assignment.
     */
    Pedometer& operator=(const Pedometer&);

  protected:
    /**
     * Protected constructor.
     */
    Pedometer(void)
    {}
    
  public:
    typedef enum
    {
      STILL,      // zero velocity and zero angular rate
      LOITER,     // zero velocity
      FORWARD,    // positive sign along forward axis
      RIGHT,      // positive sign along right axis
      BACKWARD,   // negative sign along forward axis
      LEFT,       // negative sign along right axis
      UPSTAIRS,
      DOWNSTAIRS,
      CRAWL,
      RUN,
      JOG,
      BRISK,
      UPHILL,
      DOWNHILL,
      DRAGFORWARD,
      DRAGBACKWARD
    } StepLabel;

    /**
     * Check for the successful completion of a measurement.
     *
     * @param[in] node data index
     * @return         flag
     *
     * @note
     * Each node refers to a time period that begins the instant after the previous node and ends at the node.
     * The flag will be true only if the motion was successfully characterized.
     * A false flag indicates either the initial time or the end of an unsuccessful measurement period.
     */
    virtual bool isComplete(const uint32_t& node) = 0;

    /**
     * Get the mean statistic of magnitude of distance traveled during the measurement period.
     *
     * @param[in] node data index
     * @return         mean statistic
     */
    virtual double getMagnitude(const uint32_t& node) = 0;

    /**
     * Get the standard deviation statistic of magnitude of distance traveled during the measurement period.
     *
     * @param[in] node data index
     * @return         deviation statistic
     *
     * @note
     * This deviation accounts for a representative percentage of mislabled steps.
     */
    virtual double getDeviation(const uint32_t& node) = 0;

    /**
     * Get step label.
     *
     * @param[in] node data index
     * @return         step label
     */
    virtual StepLabel getLabel(const uint32_t& node) = 0;
    
    /**
     * Virtual base class destructor.
     */
    virtual ~Pedometer(void)
    {}
  };
}

#endif
