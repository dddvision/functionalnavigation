#ifndef MATHMATRIX_H
#define MATHMATRIX_H

#include <Eigen/Dense>

namespace math
{
  typedef Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic, Eigen::ColMajor> matrix;
}

#endif
