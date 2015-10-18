#ifndef MATHVECTOR_H
#define MATHVECTOR_H

#include <Eigen/Dense>

namespace math
{
  typedef Eigen::Matrix<double, Eigen::Dynamic, 1, Eigen::ColMajor> vector;
}

#endif
