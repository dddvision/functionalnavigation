#ifndef HIDIACCELEROMETERARRAY_H
#define HIDIACCELEROMETERARRAY_H

#include "Sensor.h"

namespace hidi
{
  /**
   * This class represents an array of three accelerometers.
   */
  class AccelerometerArray : public virtual Sensor
  {
  private:
    /**
     * Prevents deep copying.
     */
    AccelerometerArray(const AccelerometerArray&);

    /**
     * Prevents assignment.
     */
    AccelerometerArray& operator=(const AccelerometerArray&);

  protected:
    /**
     * Protected constructor.
     */
    AccelerometerArray(void)
    {}

  public:
    /**
     * Get accelerometer data.
     *
     * @param[in]  n  data index (MATLAB: N-by-1)
     * @param[in]  ax axis index (MATLAB: 1-by-A)
     * @return        average specific force during the preceding integration period (meter/second^2) (MATLAB: N-by-A)
     *
     * @note
     * Specific force is a raw measurement from a typical integrating accelerometer.
     * This measurement has not been gravity compensated.
     * The axis interpretation is typically 0=Forward, 1=Right, 2=Down.
     * This measurement is taken by integrating about the instantaneous axis as it moves 
     *   during the preceding time period and dividing by the time period.
     * Throws an exception if any index is out of range.
     */
    virtual double getSpecificForce(const uint32_t& n, const uint32_t& ax) = 0;

    /**
     * Get velocity random walk standard deviation.
     *
     * @return standard deviation of velocity random walk applied to specific force (meter/second/rt-second)
     */
    virtual double getAccelerometerRandomWalk(void) = 0;

    /**
     * Get turn-on bias standard deviation.
     *
     * @return standard deviation of turn-on bias applied to specific force (meter/second^2)
     *
     * @note
     * Turn-on bias does not evolve over time.
     */
    virtual double getAccelerometerTurnOnBiasSigma(void) = 0;

    /**
     * Get in-run bias stability standard deviation.
     *
     * @return standard deviation of in-run bias stability applied to specific force (meter/second^2)
     *
     * @note
     * In-run bias stability evolves over time according to a Gauss-Markov process.
     */
    virtual double getAccelerometerInRunBiasSigma(void) = 0;

    /**
     * Get in-run bias stability Markov time constant.
     *
     * @return Markov time constant of in-run bias stability applied to specific force (second)
     *
     * @note
     * In-run bias stability evolves over time according to a Gauss-Markov process.
     */
    virtual double getAccelerometerInRunBiasStability(void) = 0;

    /**
     * Get turn-on scale factor standard deviation.
     *
     * @return standard deviation of turn-on scale factor applied to specific force (unitless)
     *
     * @note
     * Turn-on scale factor does not evolve over time.
     */
    virtual double getAccelerometerTurnOnScaleSigma(void) = 0;

    /**
     * Get in-run scale factor stability standard deviation.
     *
     * @return standard deviation of in-run scale factor stability applied to specific force (unitless)
     *
     * @note
     * In-run scale factor stability evolves over time according to a Gauss-Markov process.
     */
    virtual double getAccelerometerInRunScaleSigma(void) = 0;

    /**
     * Get in-run scale factor stability Markov time constant.
     *
     * @return Markov time constant of in-run scale factor stability applied to specific force (second)
     *
     * @note
     * In-run scale factor stability evolves over time according to a Gauss-Markov process.
     */
    virtual double getAccelerometerInRunScaleStability(void) = 0;

    /**
     * Virtual base class destructor.
     */
    virtual ~AccelerometerArray(void)
    {}
  };
}

#endif
