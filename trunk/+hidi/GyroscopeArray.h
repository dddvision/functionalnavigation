#ifndef GYROSCOPEARRAY_H
#define GYROSCOPEARRAY_H

#include "Sensor.h"

namespace hidi
{
  /**
   * This class represents an array of three gyroscopes.
   */
  class GyroscopeArray : public virtual Sensor
  {
  private:
    /**
     * Prevents deep copying.
     */
    GyroscopeArray(const GyroscopeArray&);

    /**
     * Prevents assignment.
     */
    GyroscopeArray& operator=(const GyroscopeArray&);

  protected:
    /**
     * Protected constructor.
     */
    GyroscopeArray(void)
    {}

  public:
    /**
     * Get gyroscope data.
     *
     * @param[in]  n  data index
     * @param[in]  ax axis index
     * @return        average angular rate during the preceding integration period (radian/second)
     *
     * @note
     * Average angular rate is a raw measurement from a typical integrating gyroscope
     * This measurement is taken by integrating about the instantaneous axis as it moves 
     *   during the preceding time period and dividing by the time period
     * Throws an exception if either input index is out of range
     */
    virtual double getAngularRate(uint32_t n, uint32_t ax) = 0;

    /**
     * Get gyroscope data calibrated for nominal rotation, bias, and scale.
     *
     * @param[in]  n  data index
     * @param[in]  ax axis index
     * @return        average angular rate during the preceding integration period (radian/second)
     *
     * @note
     * @see getAngularRate()
     */
    virtual double getAngularRateCalibrated(uint32_t n, uint32_t ax) = 0;
    
    /**
     * Get angle random walk standard deviation.
     *
     * @return standard deviation of angle random walk applied to angular rate (radian/rt-second)
     */
    virtual double getGyroscopeAngleRandomWalk(void) = 0;

    /**
     * Get turn-on bias standard deviation.
     *
     * @return standard deviation of turn-on bias applied to angular rate (radian/second)
     *
     * @note
     * Turn-on bias does not evolve over time
     */
    virtual double getGyroscopeTurnOnBiasSigma(void) = 0;

    /**
     * Get in-run bias stability standard deviation.
     *
     * @return standard deviation of in-run bias stability applied to angular rate (radian/second)
     *
     * @note
     * In-run bias stability evolves over time according to a Gauss-Markov process
     */
    virtual double getGyroscopeInRunBiasSigma(void) = 0;

    /**
     * Get in-run bias stability Markov time constant.
     *
     * @return Markov time constant of in-run bias stability applied to angular rate (second)
     *
     * @note
     * In-run bias stability evolves over time according to a Gauss-Markov process
     */
    virtual double getGyroscopeInRunBiasStability(void) = 0;

    /**
     * Get turn-on scale factor standard deviation.
     *
     * @return standard deviation of turn-on scale factor applied to angular rate (unitless)
     *
     * @note
     * Turn-on scale factor does not evolve over time
     */
    virtual double getGyroscopeTurnOnScaleSigma(void) = 0;

    /**
     * Get in-run scale factor stability standard deviation.
     *
     * @return standard deviation of in-run scale factor stability applied to angular rate (unitless)
     *
     * @note
     * In-run scale factor stability evolves over time according to a Gauss-Markov process
     */
    virtual double getGyroscopeInRunScaleSigma(void) = 0;

    /**
     * Get in-run scale factor stability Markov time constant.
     *
     * @return Markov time constant of in-run scale factor stability applied to angular rate (second)
     *
     * @note
     * In-run scale factor stability evolves over time according to a Gauss-Markov process
     */
    virtual double getGyroscopeInRunScaleStability(void) = 0;

    /**
     * Virtual base class destructor.
     */
    virtual ~GyroscopeArray(void)
    {}
  };
}

#endif
