#ifndef FEATUREEXTRACTOR_H
#define FEATUREEXTRACTOR_H

#include <string>

namespace hidi
{
  class FeatureExtractor
  {
  public:
    /**
     * Get the number of features available.
     *
     * @return number of features
     */
    virtual size_t numFeatures(void) = 0;

    /**
     * Get the name of a feature.
     *
     * @param[in] index zero-based feature index
     * return           feature name
     */
    virtual std::string getName(const size_t& index) = 0;

    /**
     * Get the value of a feature.
     *
     * @param[in] index zero-based feature index
     * @return          feature value
     */
    virtual double getValue(const size_t& index) = 0;
  };
}

#endif
