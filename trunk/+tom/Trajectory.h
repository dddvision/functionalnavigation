#ifndef TOMTRAJECTORY_H
#define TOMTRAJECTORY_H

#include <utility>
#include "Pose.h"
#include "TangentPose.h"

namespace tom
{
  /**
   * This class defines a 6-DOF body trajectory in the vicinity of Earth.
   */
  class Trajectory
  {
  protected:
    /**
     * Protected constructor.
     */
    Trajectory(void)
    {}
    
  public:
    /**
     * Alias for a pointer to a trajectory that is not meant to be deleted.
     */
    typedef Trajectory* Handle;

    /**
     * Return the upper and lower bounds of the time domain of a trajectory.
     *
     * @return time domain bounds
     */
    virtual std::pair<double, double> domain(void) = 0;

    /**
     * Evaluate a trajectory at a given time instant.
     *
     * @param[in]  time time stamp (MATLAB: 1-by-N)
     * @param[out] pose pose at the given time (MATLAB: 1-by-N)
     *
     * @note
     * Times before the lower bound of the domain return NaN.
     * Times after the upper bound of the domain return predicted poses.
     */
    virtual void evaluate(const double& time, Pose& pose) = 0;

    /**
     * Evaluate a trajectory and its derivatives at a given time instant.
     *
     * @param[in]  time        time stamp (MATLAB: 1-by-N)
     * @param[out] tangentPose tangent pose at given time (MATLAB: 1-by-N)
     *
     * @note
     * Times before the lower bound of the domain return NaN.
     * Times after the upper bound of the domain return predicted tangent poses.
     */
    virtual void tangent(const double& time, TangentPose& tangentPose) = 0;
    
    /**
     * Virtual base class destructor.
     */
    virtual ~Trajectory(void)
    {}
  };
}

#endif
