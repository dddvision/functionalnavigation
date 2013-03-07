#ifndef ROTATION_H
#define ROTATION_H

#include <algorithm>
#include <cmath>

namespace tom
{
  /**
   * Convert between orientation representations.
   *
   * @note
   * v = axis angle such that the magnitude is the rotation angle in radians (MATLAB: 3-by-K)
   * y = Euler angle in radians [forward; right; down] (MATLAB: 3-by-K)
   * q = quaternion [scalar; vector] (MATLAB: 4-by-K)
   * r = rotation matrix that rotates a point from the body frame to the world frame (MATLAB: 3-by-3-by-K)
   * h = homogenous matrix that premuliplies a quaternion to rotate an inner gimbal axis (MATLAB: 4-by-4-by-K)
   */
  class Rotation
  {
  public:
    // Converts from axis angle to Euler angle.
    static void axisToEuler(const double& v0, const double& v1, const double& v2, double& y0, double& y1, double& y2)
    {
      double r00, r10, r20, r01, r11, r21, r02, r12, r22;
      tom::Rotation::axisToMatrix(v0, v1, v2, r00, r10, r20, r01, r11, r21, r02, r12, r22);
      tom::Rotation::matrixToEuler(r00, r10, r20, r01, r11, r21, r02, r12, r22, y0, y1, y2);
      return;
    }
    static inline void axisToEuler(const double (&v)[3], double& y0, double& y1, double& y2)
    {
      tom::Rotation::axisToEuler(v[0], v[1], v[2], y0, y1, y2);
      return;
    }
    static inline void axisToEuler(const double& v0, const double& v1, const double& v2, double (&y)[3])
    {
      tom::Rotation::axisToEuler(v0, v1, v2, y[0], y[1], y[2]);
      return;
    }
    static inline void axisToEuler(const double (&v)[3], double (&y)[3])
    {
      tom::Rotation::axisToEuler(v[0], v[1], v[2], y[0], y[1], y[2]);
      return;
    }
    
    /**
     * Converts from axis angle to rotation matrix.
     */
    static void axisToMatrix(const double& v0, const double& v1, const double& v2, double& r00, double& r10, double& r20, 
      double& r01, double& r11, double& r21, double& r02, double& r12, double& r22)
    {
      double vNorm0 = v0;
      double vNorm1 = v1;
      double vNorm2 = v2;
      double theta = sqrt(v0*v0+v1*v1+v2*v2);
      double c = cos(theta);
      double s = sin(theta);
      double a = 1.0-c;
      if(theta>EPS)
      {
        vNorm0 = vNorm0/theta;
        vNorm1 = vNorm1/theta;
        vNorm2 = vNorm2/theta;
      }
      // Rodrigues Formula (a form of exponential mapping)
      r00 = a*vNorm0*vNorm0+c;
      r10 = a*vNorm0*vNorm1+s*vNorm2;
      r20 = a*vNorm0*vNorm2-s*vNorm1;
      r01 = a*vNorm0*vNorm1-s*vNorm2;
      r11 = a*vNorm1*vNorm1+c;
      r21 = a*vNorm1*vNorm2+s*vNorm0;     
      r02 = a*vNorm0*vNorm2+s*vNorm1;
      r12 = a*vNorm1*vNorm2-s*vNorm0;
      r22 = a*vNorm2*vNorm2+c;
      return;
    }
    static inline void axisToMatrix(const double (&v)[3], double& r00, double& r10, double& r20, double& r01, 
      double& r11, double& r21, double& r02, double& r12, double& r22)
    {
      tom::Rotation::axisToMatrix(v[0], v[1], v[2], r00, r10, r20, r01, r11, r21, r02, r12, r22);
      return;
    }
    static inline void axisToMatrix(const double& v0, const double& v1, const double& v2, double (&r)[3][3])
    {
      tom::Rotation::axisToMatrix(v0, v1, v2, r[0][0], r[1][0], r[2][0], r[0][1], r[1][1], r[2][1], r[0][2], r[1][2], 
        r[2][2]);
      return;
    }
    static inline void axisToMatrix(const double (&v)[3], double (&r)[3][3])
    {
      tom::Rotation::axisToMatrix(v[0], v[1], v[2], r[0][0], r[1][0], r[2][0], r[0][1], r[1][1], r[2][1], r[0][2], 
        r[1][2], r[2][2]);
      return;
    }

    /**
     * Converts from axis angle to quaternion.
     */
    static void axisToQuat(const double& v0, const double& v1, const double& v2, double& q0, double& q1, double& q2, 
      double& q3)
    {
      double vNorm0 = v0;
      double vNorm1 = v1;
      double vNorm2 = v2;
      double theta = sqrt(v0*v0+v1*v1+v2*v2);
      double theta2 = theta/2.0;
      double c = cos(theta2);
      double s = sin(theta2);
      double qRaw0, qRaw1, qRaw2, qRaw3;
      if(theta>EPS)
      {
        vNorm0 = vNorm0/theta;
        vNorm1 = vNorm1/theta;
        vNorm2 = vNorm2/theta;
      }
      qRaw0 = c;
      qRaw1 = s*vNorm0;
      qRaw2 = s*vNorm1;
      qRaw3 = s*vNorm2;
      tom::Rotation::quatNorm(qRaw0, qRaw1, qRaw2, qRaw3, q0, q1, q2, q3);
      return;
    }
    static inline void axisToQuat(const double (&v)[3], double& q0, double& q1, double& q2, double& q3)
    {
      tom::Rotation::axisToQuat(v[0], v[1], v[2], q0, q1, q2, q3);
      return;
    }
    static inline void axisToQuat(const double& v0, const double& v1, const double& v2, double (&q)[4])
    {
      tom::Rotation::axisToQuat(v0, v1, v2, q[0], q[1], q[2], q[3]);
      return;
    }
    static inline void axisToQuat(const double (&v)[3], double (&q)[4])
    {
      tom::Rotation::axisToQuat(v[0], v[1], v[2], q[0], q[1], q[2], q[3]);
      return;
    }
    
    /**
     * Converts from Euler angle to axis angle.
     */
    static void eulerToAxis(const double& y0, const double& y1, const double& y2, double& v0, double& v1, double& v2)
    {
      double q0, q1, q2, q3;
      tom::Rotation::eulerToQuat(y0, y1, y2, q0, q1, q2, q3);
      tom::Rotation::quatToAxis(q0, q1, q2, q3, v0, v1, v2);
      return;
    }
    static inline void eulerToAxis(const double (&y)[3], double& v0, double& v1, double& v2)
    {
      tom::Rotation::eulerToAxis(y[0], y[1], y[2], v0, v1, v2);
      return;
    }
    static inline void eulerToAxis(const double& y0, const double& y1, const double& y2, double (&v)[3])
    {
      tom::Rotation::eulerToAxis(y0, y1, y2, v[0], v[1], v[2]);
      return;
    }
    static inline void eulerToAxis(const double (&y)[3], double (&v)[3])
    {
      tom::Rotation::eulerToAxis(y[0], y[1], y[2], v[0], v[1], v[2]);
      return;
    }
    
    /**
     * Converts from Euler angle to rotation matrix.
     */
    static void eulerToMatrix(const double& y0, const double& y1, const double& y2, double& r00, double& r10, double& r20, 
      double& r01, double& r11, double& r21, double& r02, double& r12, double& r22)
    {
      double c0 = cos(y0);
      double c1 = cos(y1);
      double c2 = cos(y2);
      double s0 = sin(y0);
      double s1 = sin(y1);
      double s2 = sin(y2);
      r00 = c2*c1;
      r10 = s2*c1;      
      r20 = -s1;
      r01 = c2*s1*s0-s2*c0;
      r11 = c2*c0+s2*s1*s0;
      r21 = c1*s0;      
      r02 = s2*s0+c2*s1*c0;
      r12 = s2*s1*c0-c2*s0;
      r22 = c1*c0;
      return;
    }
    static inline void eulerToMatrix(const double (&y)[3], double& r00, double& r10, double& r20, double& r01, 
      double& r11, double& r21, double& r02, double& r12, double& r22)
    {
      tom::Rotation::eulerToMatrix(y[0], y[1], y[2], r00, r10, r20, r01, r11, r21, r02, r12, r22);
      return;
    }
    static inline void eulerToMatrix(const double& y0, const double& y1, const double& y2, double (&r)[3][3])
    {
      tom::Rotation::eulerToMatrix(y0, y1, y2, r[0][0], r[1][0], r[2][0], r[0][1], r[1][1], r[2][1], r[0][2], r[1][2], 
        r[2][2]);
      return;
    }
    static inline void eulerToMatrix(const double (&y)[3], double (&r)[3][3])
    {
      tom::Rotation::eulerToMatrix(y[0], y[1], y[2], r[0][0], r[1][0], r[2][0], r[0][1], r[1][1], r[2][1], r[0][2], 
        r[1][2], r[2][2]);
      return;
    }
    
    /**
     * Converts from Euler angle to quaternion.
     */
    static void eulerToQuat(const double& y0, const double& y1, const double& y2, double& q0, double& q1, double& q2, 
      double& q3)
    {
      double z0 = y0/2.0;
      double z1 = y1/2.0;
      double z2 = y2/2.0;      
      double c0 = cos(z0);
      double c1 = cos(z1);
      double c2 = cos(z2);
      double s0 = sin(z0);
      double s1 = sin(z1);
      double s2 = sin(z2);
      double qRaw0 = c2*c1*c0+s2*s1*s0;
      double qRaw1 = c2*c1*s0-s2*s1*c0;
      double qRaw2 = c2*s1*c0+s2*c1*s0;
      double qRaw3 = s2*c1*c0-c2*s1*s0;
      tom::Rotation::quatNorm(qRaw0, qRaw1, qRaw2, qRaw3, q0, q1, q2, q3);
      return;
    }
    static inline void eulerToQuat(const double (&y)[3], double& q0, double& q1, double& q2, double& q3)
    {
      tom::Rotation::eulerToQuat(y[0], y[1], y[2], q0, q1, q2, q3);
      return;
    }
    static inline void eulerToQuat(const double& y0, const double& y1, const double& y2, double (&q)[4])
    {
      tom::Rotation::eulerToQuat(y0, y1, y2, q[0], q[1], q[2], q[3]);
      return;
    }
    static inline void eulerToQuat(const double (&y)[3], double (&q)[4])
    {
      tom::Rotation::eulerToQuat(y[0], y[1], y[2], q[0], q[1], q[2], q[3]);
      return;
    }

    /**
     * Converts from rotation matrix to axis angle.
     */
    static void matrixToAxis(const double& r00, const double& r10, const double& r20, const double& r01, const double& r11, 
      const double& r21, const double& r02, const double& r12, const double& r22, double& v0, double& v1, double& v2)
    {
      double q0, q1, q2, q3;
      tom::Rotation::matrixToQuat(r00, r10, r20, r01, r11, r21, r02, r12, r22, q0, q1, q2, q3);
      tom::Rotation::quatToAxis(q0, q1, q2, q3, v0, v1, v2);
      return;
    }
    static inline void matrixToAxis(const double (&r)[3][3], double& v0, double& v1, double& v2)
    {
      tom::Rotation::matrixToAxis(r[0][0], r[1][0], r[2][0], r[0][1], r[1][1], r[2][1], r[0][2], r[1][2], r[2][2], 
        v0, v1, v2);
      return;
    }
    static inline void matrixToAxis(const double& r00, const double& r10, const double& r20, const double& r01, 
      const double& r11, const double& r21, const double& r02, const double& r12, const double& r22, double (&v)[3])
    {
      tom::Rotation::matrixToAxis(r00, r10, r20, r01, r11, r21, r02, r12, r22, v[0], v[1], v[2]);
      return;
    }
    static inline void matrixToAxis(const double (&r)[3][3], double (&v)[3])
    {
      tom::Rotation::matrixToAxis(r[0][0], r[1][0], r[2][0], r[0][1], r[1][1], r[2][1], r[0][2], r[1][2], r[2][2], 
        v[0], v[1], v[2]);
      return;
    }
    
    /**
     * Converts from rotation matrix to Euler angle.
     */
    static void matrixToEuler(const double& r00, const double& r10, const double& r20, const double& r01, const double& r11, 
      const double& r21, const double& r02, const double& r12, const double& r22, double& y0, double& y1, double& y2)
    {
      y0 = atan2(r21, r22);
      y1 = asin(-r20);
      y2 = atan2(r10, r00);
      return;
    }
    static inline void matrixToEuler(const double (&r)[3][3], double& y0, double& y1, double& y2)
    {
      tom::Rotation::matrixToEuler(r[0][0], r[1][0], r[2][0], r[0][1], r[1][1], r[2][1], r[0][2], r[1][2], r[2][2], 
        y0, y1, y2);
      return;
    }
    static inline void matrixToEuler(const double& r00, const double& r10, const double& r20, const double& r01, 
      const double& r11, const double& r21, const double& r02, const double& r12, const double& r22, double (&y)[3])
    {
      tom::Rotation::matrixToEuler(r00, r10, r20, r01, r11, r21, r02, r12, r22, y[0], y[1], y[2]);
      return;
    }
    static inline void matrixToEuler(const double (&r)[3][3], double (&y)[3])
    {
      tom::Rotation::matrixToEuler(r[0][0], r[1][0], r[2][0], r[0][1], r[1][1], r[2][1], r[0][2], r[1][2], r[2][2], 
        y[0], y[1], y[2]);
      return;
    }
    
    /**
     * Converts from rotation matrix to quaternion.
     */
    static void matrixToQuat(const double& r00, const double& r10, const double& r20, const double& r01, const double& r11, 
      const double& r21, const double& r02, const double& r12, const double& r22, double& q0, double& q1, double& q2, 
      double& q3)
    {
      double y0, y1, y2;
      tom::Rotation::matrixToEuler(r00, r10, r20, r01, r11, r21, r02, r12, r22, y0, y1, y2);
      tom::Rotation::eulerToQuat(y0, y1, y2, q0, q1, q2, q3);
      return;
    }
    static inline void matrixToQuat(const double (&r)[3][3], double& q0, double& q1, double& q2, double& q3)
    {
      tom::Rotation::matrixToQuat(r[0][0], r[1][0], r[2][0], r[0][1], r[1][1], r[2][1], r[0][2], r[1][2], r[2][2], q0, 
        q1, q2, q3);
      return;
    }
    static inline void matrixToQuat(const double& r00, const double& r10, const double& r20, const double& r01, 
      const double& r11, const double& r21, const double& r02, const double& r12, const double& r22, double (&q)[4])
    {
      tom::Rotation::matrixToQuat(r00, r10, r20, r01, r11, r21, r02, r12, r22, q[0], q[1], q[2], q[3]);
      return;
    }
    static inline void matrixToQuat(const double (&r)[3][3], double (&q)[4])
    {
      tom::Rotation::matrixToQuat(r[0][0], r[1][0], r[2][0], r[0][1], r[1][1], r[2][1], r[0][2], r[1][2], r[2][2], q[0], 
        q[1], q[2], q[3]);
      return;
    }

    /**
     * Converts from quaternion to axis angle.
     */
    static void quatToAxis(const double& q0, const double& q1, const double& q2, const double& q3, double& v0, double& v1, 
      double& v2)
    {
      double qNorm0, qNorm1, qNorm2, qNorm3;
      double n;
      double theta;
      tom::Rotation::quatNorm(q0, q1, q2, q3, qNorm0, qNorm1, qNorm2, qNorm3);
      n = sqrt(qNorm1*qNorm1+qNorm2*qNorm2+qNorm3*qNorm3);
      if(n>EPS)
      {
        qNorm1 = qNorm1/n;
        qNorm2 = qNorm2/n;
        qNorm3 = qNorm3/n;
      }
      theta = 2.0*acos(qNorm0);
      v0 = theta*qNorm1;
      v1 = theta*qNorm2;
      v2 = theta*qNorm3;
      return;
    }
    static inline void quatToAxis(const double (&q)[4], double& v0, double& v1, double& v2)
    {
      tom::Rotation::quatToAxis(q[0], q[1], q[2], q[3], v0, v1, v2);
      return;
    }
    static inline void quatToAxis(const double& q0, const double& q1, const double& q2, const double& q3, 
      double (&v)[3])
    {
      tom::Rotation::quatToAxis(q0, q1, q2, q3, v[0], v[1], v[2]);
      return;
    }
    static inline void quatToAxis(const double (&q)[4], double (&v)[3])
    {
      tom::Rotation::quatToAxis(q[0], q[1], q[2], q[3], v[0], v[1], v[2]);
      return;
    }
    
    /**
     * Converts from quaternion to Euler angle.
     */
    static void quatToEuler(const double& q0, const double& q1, const double& q2, const double& q3, double& y0, double& y1, 
      double& y2)
    {
      double qNorm0, qNorm1, qNorm2, qNorm3;
      double q00, q11, q22, q33, q01, q12, q23, q03, q02, q13;
      tom::Rotation::quatNorm(q0, q1, q2, q3, qNorm0, qNorm1, qNorm2, qNorm3);
      q00 = qNorm0*qNorm0;
      q11 = qNorm1*qNorm1;
      q22 = qNorm2*qNorm2;
      q33 = qNorm3*qNorm3;
      q01 = qNorm0*qNorm1;
      q12 = qNorm1*qNorm2;
      q23 = qNorm2*qNorm3;
      q03 = qNorm0*qNorm3;
      q02 = qNorm0*qNorm2;
      q13 = qNorm1*qNorm3;
      y0 = atan2(2.0*(q23+q01), q00-q11-q22+q33);
      y1 = asin(std::min(std::max(-2.0*(q13-q02), -1.0), 1.0));
      y2 = atan2(2.0*(q12+q03), q00+q11-q22-q33);
      return;
    }
    static inline void quatToEuler(const double (&q)[4], double& y0, double& y1, double& y2)
    {
      tom::Rotation::quatToEuler(q[0], q[1], q[2], q[3], y0, y1, y2);
      return;
    }
    static inline void quatToEuler(const double& q0, const double& q1, const double& q2, const double& q3, 
      double (&y)[3])
    {
      tom::Rotation::quatToEuler(q0, q1, q2, q3, y[0], y[1], y[2]);
      return;
    }
    static inline void quatToEuler(const double (&q)[4], double (&y)[3])
    {
      tom::Rotation::quatToEuler(q[0], q[1], q[2], q[3], y[0], y[1], y[2]);
      return;
    }
    
    /**
     * Converts from quaternion to rotation matrix.
     */
    static void quatToMatrix(const double& q0, const double& q1, const double& q2, const double& q3, double& r00, double& r10, 
      double& r20, double& r01, double& r11, double& r21, double& r02, double& r12, double& r22)
    {
      double qNorm0, qNorm1, qNorm2, qNorm3;
      double q00, q11, q22, q33, q01, q12, q23, q03, q02, q13;
      tom::Rotation::quatNorm(q0, q1, q2, q3, qNorm0, qNorm1, qNorm2, qNorm3);
      q00 = qNorm0*qNorm0;
      q11 = qNorm1*qNorm1;
      q22 = qNorm2*qNorm2;
      q33 = qNorm3*qNorm3;
      q01 = qNorm0*qNorm1;
      q12 = qNorm1*qNorm2;
      q23 = qNorm2*qNorm3;
      q03 = qNorm0*qNorm3;
      q02 = qNorm0*qNorm2;
      q13 = qNorm1*qNorm3;
      r00 = q00+q11-q22-q33;
      r10 = 2.0*(q12+q03);
      r20 = 2.0*(q13-q02);
      r01 = 2.0*(q12-q03);
      r11 = q00-q11+q22-q33;
      r21 = 2.0*(q23+q01);
      r02 = 2.0*(q13+q02);
      r12 = 2.0*(q23-q01);
      r22 = q00-q11-q22+q33;
      return;
    }
    static inline void quatToMatrix(const double (&q)[4], double& r00, double& r10, double& r20, double& r01, 
      double& r11, double& r21, double& r02, double& r12, double& r22)
    {
      tom::Rotation::quatToMatrix(q[0], q[1], q[2], q[3], r00, r10, r20, r01, r11, r21, r02, r12, r22);
      return;
    }
    static inline void quatToMatrix(const double& q0, const double& q1, const double& q2, const double& q3, 
      double (&r)[3][3])
    {
      tom::Rotation::quatToMatrix(q0, q1, q2, q3, r[0][0], r[1][0], r[2][0], r[0][1], r[1][1], r[2][1], r[0][2], 
        r[1][2], r[2][2]);
      return;
    }
    static inline void quatToMatrix(const double (&q)[4], double (&r)[3][3])
    {
      tom::Rotation::quatToMatrix(q[0], q[1], q[2], q[3], r[0][0], r[1][0], r[2][0], r[0][1], r[1][1], r[2][1], r[0][2], 
        r[1][2], r[2][2]);
      return;
    }
    
    /**
     * Converts from quaternion to homogenous matrix.
     */
    static void quatToHomo(const double& q0, const double& q1, const double& q2, const double& q3, double (&h)[4][4])
    {
      h[0][0] = q0;
      h[1][0] = q1;
      h[2][0] = q2;
      h[3][0] = q3;      
      h[0][1] = -q1;
      h[1][1] = q0;
      h[2][1] = q3;
      h[3][1] = -q2;
      h[0][2] = -q2;
      h[1][2] = -q3;
      h[2][2] = q0;
      h[3][2] = q1;
      h[0][3] = -q3;
      h[1][3] = q2;
      h[2][3] = -q1;
      h[3][3] = q0;
      return;
    }
    static inline void quatToHomo(const double (&q)[4], double (&h)[4][4])
    {
      tom::Rotation::quatToHomo(q[0], q[1], q[2], q[3], h);
      return;
    }
    
    /**
     * Converts from homogenous matrix to quaternion.
     */
    static void homoToQuat(const double (&h)[4][4], double& q0, double& q1, double& q2, double& q3)
    {
      q0 = h[0][0];
      q1 = h[1][0];
      q2 = h[2][0];
      q3 = h[3][0];
      return;
    }
    static inline void homoToQuat(const double (&h)[4][4], double (&q)[4])
    {
      tom::Rotation::homoToQuat(h, q[0], q[1], q[2], q[3]);
      return;
    }
    
    /**
     * Normalizes a quaternion to enforce unit magnitude and a non-negative first element.
     *
     * @note
     * Input and output are allowed to alias.
     */
    static void quatNorm(const double q0, const double q1, const double q2, const double q3, double& qNorm0, 
      double& qNorm1, double& qNorm2, double& qNorm3)
    {
      double n;
      qNorm0 = q0;
      qNorm1 = q1;
      qNorm2 = q2;
      qNorm3 = q3;
      n = sqrt(q0*q0+q1*q1+q2*q2+q3*q3);
      if(n<EPS)
      {
        qNorm0 = 1.0;
        qNorm1 = 0.0;
        qNorm2 = 0.0;
        qNorm3 = 0.0;
        n = 1.0;
      }
      if(qNorm0<0.0)
      {
        n = -n;
      }
      qNorm0 = qNorm0/n;
      qNorm1 = qNorm1/n;
      qNorm2 = qNorm2/n;
      qNorm3 = qNorm3/n;
      return;
    }
    static inline void quatNorm(const double (&q)[4], double& qNorm0, double& qNorm1, double& qNorm2, double& qNorm3)
    {
      tom::Rotation::quatNorm(q[0], q[1], q[2], q[3], qNorm0, qNorm1, qNorm2, qNorm3);
      return;
    }
    static inline void quatNorm(const double& q0, const double& q1, const double& q2, const double& q3, 
      double (&qNorm)[4])
    {
      tom::Rotation::quatNorm(q0, q1, q2, q3, qNorm[0], qNorm[1], qNorm[2], qNorm[3]);
      return;
    }
    static inline void quatNorm(const double (&q)[4], double (&qNorm)[4])
    {
      tom::Rotation::quatNorm(q[0], q[1], q[2], q[3], qNorm[0], qNorm[1], qNorm[2], qNorm[3]);
      return;
    }
    
    /**
     * Inverts a quaternion.
     */
    static void quatInv(const double& q0, const double& q1, const double& q2, const double& q3, double& qInv0, double& qInv1, 
      double& qInv2, double& qInv3)
    {
      qInv0 = q0;
      qInv1 = -q1;
      qInv2 = -q2;
      qInv3 = -q3;
      return;
    }
    static inline void quatInv(const double (&q)[4], double& qInv0, double& qInv1, double& qInv2, double& qInv3)
    {
      tom::Rotation::quatInv(q[0], q[1], q[2], q[3], qInv0, qInv1, qInv2, qInv3);
      return;
    }
    static inline void quatInv(const double& q0, const double& q1, const double& q2, const double& q3, 
      double (&qInv)[4])
    {
      tom::Rotation::quatInv(q0, q1, q2, q3, qInv[0], qInv[1], qInv[2], qInv[3]);
      return;
    }
    static inline void quatInv(const double (&q)[4], double (&qInv)[4])
    {
      tom::Rotation::quatInv(q[0], q[1], q[2], q[3], qInv[0], qInv[1], qInv[2], qInv[3]);
      return;
    }
    
    /**
     * Multiplies two quaternions.
     *
     * @param[in]  a outer frame
     * @param[in]  b inner frame
     * @param[out] c resulting frame
     * 
     * @note
     * c = quatToHomo(a)*b;
     * Input and output are allowed to alias.
     */
    static void quatMult(const double a0, const double a1, const double a2, const double a3, const double b0, 
      const double b1, const double b2, const double b3, double& c0, double& c1, double& c2, double& c3)
    {
      c0 = b0*a0-b1*a1-b2*a2-b3*a3;
      c1 = b0*a1+b1*a0-b2*a3+b3*a2;
      c2 = b0*a2+b1*a3+b2*a0-b3*a1;
      c3 = b0*a3-b1*a2+b2*a1+b3*a0;
      return;
    }
    static inline void quatMult(const double (&a)[4], const double (&b)[4], double& c0, double& c1, double& c2, 
      double& c3)
    {
      tom::Rotation::quatMult(a[0], a[1], a[2], a[3], b[0], b[1], b[2], b[3], c0, c1, c2, c3);
      return;
    }
    static inline void quatMult(const double& a0, const double& a1, const double& a2, const double& a3, 
      const double& b0, const double& b1, const double& b2, const double& b3, double (&c)[4])
    {
      tom::Rotation::quatMult(a0, a1, a2, a3, b0, b1, b2, b3, c[0], c[1], c[2], c[3]);
      return;
    }
    static inline void quatMult(const double (&a)[4], const double (&b)[4], double (&c)[4])
    {
      tom::Rotation::quatMult(a[0], a[1], a[2], a[3], b[0], b[1], b[2], b[3], c[0], c[1], c[2], c[3]);
      return;
    }
    
    /**
     * Multiplies two 3x3 matrices.
     *
     * @note
     * Input and output are allowed to alias.
     */
    static void mtimes(const double (&a)[3][3], const double (&b)[3][3], double (&c)[3][3])
    {
      double c00 = a[0][0]*b[0][0]+a[0][1]*b[1][0]+a[0][2]*b[2][0];
      double c10 = a[1][0]*b[0][0]+a[1][1]*b[1][0]+a[1][2]*b[2][0];      
      double c20 = a[2][0]*b[0][0]+a[2][1]*b[1][0]+a[2][2]*b[2][0];
      double c01 = a[0][0]*b[0][1]+a[0][1]*b[1][1]+a[0][2]*b[2][1];
      double c11 = a[1][0]*b[0][1]+a[1][1]*b[1][1]+a[1][2]*b[2][1];
      double c21 = a[2][0]*b[0][1]+a[2][1]*b[1][1]+a[2][2]*b[2][1];
      double c02 = a[0][0]*b[0][2]+a[0][1]*b[1][2]+a[0][2]*b[2][2];
      double c12 = a[1][0]*b[0][2]+a[1][1]*b[1][2]+a[1][2]*b[2][2];
      double c22 = a[2][0]*b[0][2]+a[2][1]*b[1][2]+a[2][2]*b[2][2];
      c[0][0] = c00;
      c[1][0] = c10;
      c[2][0] = c20;
      c[0][1] = c01;
      c[1][1] = c11;
      c[2][1] = c21;
      c[0][2] = c02;
      c[1][2] = c12;
      c[2][2] = c22;
      return;
    }
    
    /**
     * Multiplies two 4x4 matrices.
     *
     * @note
     * Input and output are allowed to alias.
     */
    static void mtimes(const double (&a)[4][4], const double (&b)[4][4], double (&c)[4][4])
    {
      double c00 = a[0][0]*b[0][0]+a[0][1]*b[1][0]+a[0][2]*b[2][0]+a[0][3]*b[3][0];
      double c10 = a[1][0]*b[0][0]+a[1][1]*b[1][0]+a[1][2]*b[2][0]+a[1][3]*b[3][0];
      double c20 = a[2][0]*b[0][0]+a[2][1]*b[1][0]+a[2][2]*b[2][0]+a[2][3]*b[3][0];
      double c30 = a[3][0]*b[0][0]+a[3][1]*b[1][0]+a[3][2]*b[2][0]+a[3][3]*b[3][0];
      double c01 = a[0][0]*b[0][1]+a[0][1]*b[1][1]+a[0][2]*b[2][1]+a[0][3]*b[3][1];
      double c11 = a[1][0]*b[0][1]+a[1][1]*b[1][1]+a[1][2]*b[2][1]+a[1][3]*b[3][1];
      double c21 = a[2][0]*b[0][1]+a[2][1]*b[1][1]+a[2][2]*b[2][1]+a[2][3]*b[3][1];
      double c31 = a[3][0]*b[0][1]+a[3][1]*b[1][1]+a[3][2]*b[2][1]+a[3][3]*b[3][1];
      double c02 = a[0][0]*b[0][2]+a[0][1]*b[1][2]+a[0][2]*b[2][2]+a[0][3]*b[3][2];
      double c12 = a[1][0]*b[0][2]+a[1][1]*b[1][2]+a[1][2]*b[2][2]+a[1][3]*b[3][2];
      double c22 = a[2][0]*b[0][2]+a[2][1]*b[1][2]+a[2][2]*b[2][2]+a[2][3]*b[3][2];
      double c32 = a[3][0]*b[0][2]+a[3][1]*b[1][2]+a[3][2]*b[2][2]+a[3][3]*b[3][2];
      double c03 = a[0][0]*b[0][3]+a[0][1]*b[1][3]+a[0][2]*b[2][3]+a[0][3]*b[3][3];
      double c13 = a[1][0]*b[0][3]+a[1][1]*b[1][3]+a[1][2]*b[2][3]+a[1][3]*b[3][3];
      double c23 = a[2][0]*b[0][3]+a[2][1]*b[1][3]+a[2][2]*b[2][3]+a[2][3]*b[3][3];
      double c33 = a[3][0]*b[0][3]+a[3][1]*b[1][3]+a[3][2]*b[2][3]+a[3][3]*b[3][3];
      c[0][0] = c00;
      c[1][0] = c10;
      c[2][0] = c20;
      c[3][0] = c30;
      c[0][1] = c01;
      c[1][1] = c11;
      c[2][1] = c21;
      c[3][1] = c31;
      c[0][2] = c02;
      c[1][2] = c12;
      c[2][2] = c22;
      c[3][2] = c32;
      c[0][3] = c03;
      c[1][3] = c13;
      c[2][3] = c23;
      c[3][3] = c33;
      return;
    }
    
    /**
     * Multiplies a 3x3 matrix with a 3x1 vector.
     *
     * @note
     * Input and output are allowed to alias.
     */
    static void mtimes(const double (&a)[3][3], const double (&b)[3], double (&c)[3])
    {
      double c0 = a[0][0]*b[0]+a[0][1]*b[1]+a[0][2]*b[2];
      double c1 = a[1][0]*b[0]+a[1][1]*b[1]+a[1][2]*b[2];
      double c2 = a[2][0]*b[0]+a[2][1]*b[1]+a[2][2]*b[2];
      c[0] = c0;
      c[1] = c1;
      c[2] = c2;
      return;
    }
    
    /**
     * Multiplies a 4x4 matrix with a 4x1 vector.
     *
     * @note
     * Input and output are allowed to alias.
     */
    static void mtimes(const double (&a)[4][4], const double (&b)[4], double (&c)[4])
    {
      double c0 = a[0][0]*b[0]+a[0][1]*b[1]+a[0][2]*b[2]+a[0][3]*b[3];
      double c1 = a[1][0]*b[0]+a[1][1]*b[1]+a[1][2]*b[2]+a[1][3]*b[3];
      double c2 = a[2][0]*b[0]+a[2][1]*b[1]+a[2][2]*b[2]+a[2][3]*b[3];
      double c3 = a[3][0]*b[0]+a[3][1]*b[1]+a[3][2]*b[2]+a[3][3]*b[3];
      c[0] = c0;
      c[1] = c1;
      c[2] = c2;
      c[3] = c3;
      return;
    }
  };
}

#endif
