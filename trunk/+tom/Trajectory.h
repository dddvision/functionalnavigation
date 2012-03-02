#ifndef TRAJECTORY_H
#define TRAJECTORY_H

#include <vector>

#include "WorldTime.h"
#include "TimeInterval.h"
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
    virtual TimeInterval domain(void) = 0;

    /**
     * Evaluate a single trajectory at multiple instants.
     *
     * @param[in]  time vector of time stamps (MATLAB: 1-by-N)
     * @param[out] pose vector of poses at each time (MATLAB: 1-by-N)
     *
     * @note
     * Times before the lower bound of the domain return NaN in corresponding outputs.
     * Times after the upper bound of the domain return predicted poses in corresponding outputs.
     * Throws and exception if the output vector is not the same size as the input vector.
     */
    virtual void evaluate(const std::vector<WorldTime>& time, std::vector<Pose>& pose) = 0;

    /**
     * Evaluate a single trajectory and its time derivatives at multiple time instants.
     *
     * @param[in]  time        vector of time stamps (MATLAB: 1-by-N)
     * @param[out] tangentPose vector of tangent poses at each time (MATLAB: 1-by-N)
     *
     * @note
     * Times before the lower bound of the domain return NaN in corresponding outputs.
     * Times after the upper bound of the domain return predicted tangent poses in corresponding outputs.
     * Throws and exception if the output vector is not the same size as the input vector.
     */
    virtual void tangent(const std::vector<WorldTime>& time, std::vector<TangentPose>& tangentPose) = 0;
    
    /**
     * Virtual base class destructor.
     */
    virtual ~Trajectory(void)
    {}
  };
}

#endif
