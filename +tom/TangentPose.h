#ifndef TANGENTPOSE_H
#define TANGENTPOSE_H

#include "Pose.h"

namespace tom
{
  /**
   * This class represents a pose and its time derivatives.
   *
   * @note
   * The initial undefined tangent pose is represented by NaN values for all parameters.
   */
  class TangentPose : public Pose
  {
  public:
    double r[3]; /**< time derivative of body position */
    double s[3]; /**< angular rate vector (2*conjugate(q)*dq/dt) */

    /**
     * Construct a tangent pose initialized to NaN.
     */
    TangentPose(void)
    {
      r[0] = NAN;
      r[1] = NAN;
      r[2] = NAN;
      s[0] = NAN;
      s[1] = NAN;
      s[2] = NAN;
    }

    /**
     * Copy a tangent pose.
     */
    TangentPose(const TangentPose& tangentPose)
    {
      TangentPose::operator=(tangentPose);
      return;
    }

    /**
     * Assign a tangent pose.
     */
    TangentPose& operator=(const TangentPose& tangentPose)
    {
      Pose::operator=(tangentPose);
      this->r[0] = tangentPose.r[0];
      this->r[1] = tangentPose.r[1];
      this->r[2] = tangentPose.r[2];
      this->s[0] = tangentPose.s[0];
      this->s[1] = tangentPose.s[1];
      this->s[2] = tangentPose.s[2];
      return (*this);
    }
  };
}

#endif
