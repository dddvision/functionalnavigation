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
     * Get a feature label.
     *
     * @param[in] index zero-based feature index
     * return           feature name
     */
    virtual std::string getLabel(const size_t& index) = 0;

    /**
     * Get a feature value.
     *
     * @param[in] index zero-based feature index
     * @return          feature value
     */
    virtual double getValue(const size_t& index) = 0;
  };
}

#endif
