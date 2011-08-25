#ifndef POSE_H
#define POSE_H

#include <math.h>
#ifndef NAN
static const double NAN = sqrt(static_cast<double>(-1));
#endif

namespace tom
{
  /**
   * This class represents the position and orientation of a body frame relative to a world frame.
   *
   * @note
   * Using SI units (meters, radians, seconds).
   * Using an Earth Centered Earth Fixed (ECEF) convention for the world frame:
   *   World Axis 1 goes through the equator at the prime meridian;
   *   World Axis 2 completes the frame using the right-hand-rule;
   *   World Axis 3 goes through the north pole.
   * Using a Forward-Right-Down (FRD) convention for the body frame:
   *   Body Axis 1 points forward;
   *   Body Axis 2 points right;
   *   Body Axis 3 points down relative to the body (not gravity).
   * The initial undefined pose is represented by NaN values for all parameters.
   */
  class Pose
  {
  public:
    double p[3]; /**< position of the body frame */
    double q[4]; /**< orientation of the body frame as a quaternion with a non-negative scalar first element */

    /**
     * Construct a pose initialized to NaN.
     */
    Pose(void)
    {
      p[0] = NAN;
      p[1] = NAN;
      p[2] = NAN;
      q[0] = NAN;
      q[1] = NAN;
      q[2] = NAN;
      q[3] = NAN;
    }

    /**
     * Copy a pose.
     */
    Pose(const Pose& pose)
    {
      Pose::operator=(pose);
      return;
    }

    /**
     * Assign a pose.
     */
    Pose& operator=(const Pose& pose)
    {
      this->p[0] = pose.p[0];
      this->p[1] = pose.p[1];
      this->p[2] = pose.p[2];
      this->q[0] = pose.q[0];
      this->q[1] = pose.q[1];
      this->q[2] = pose.q[2];
      this->q[3] = pose.q[3];
      return (*this);
    }
  };
}

#endif
