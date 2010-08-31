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
   * This class defines a 6-DOF body trajectory in the vicinity of Earth
   */
  class Trajectory
  {
  public:
    /**
     * Return the upper and lower bounds of the time domain of a trajectory
     *
     * @return time domain bounds
     */
    virtual TimeInterval domain(void) = 0;

    /**
     * Evaluate a single trajectory at multiple instants
     *
     * @param[in]     time vector of time stamps (MATLAB: 1-by-N)
     * @param[in,out] pose vector of poses at each time (MATLAB: 1-by-N)
     *
     * NOTES
     * Evaluation outside of the domain returns NaN in corresponding outputs
     */
    virtual void evaluate(const std::vector<WorldTime>& time,std::vector<Pose>& pose) = 0;
    
    /**
     * Evaluate a single trajectory and its time derivatives at multiple time instants
     *
     * @param[in]     time        vector of time stamps (MATLAB: 1-by-N)
     * @param[in,out] tangentPose vector of tangent poses at each time (MATLAB: 1-by-N)
     *
     * NOTES
     * Evaluation outside of the domain returns NaN in corresponding outputs
     */
    virtual void tangent(const std::vector<WorldTime>& time,std::vector<TangentPose>& tangentPose) = 0;
  };
}

#endif
