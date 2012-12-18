#ifndef HIDIFEATUREEXTRACTOR_H
#define HIDIFEATUREEXTRACTOR_H

#include <string>
#include "hidi.h"

namespace hidi
{
  class FeatureExtractor
  {
  public:
    /**
     * Get the number of features.
     *
     * @return number of features
     */
    virtual uint32_t numFeatures(void) = 0;

    /**
     * Get a feature label.
     *
     * @param[in] index zero-based feature index
     * return           feature name
     *
     * @note
     * Throws an error if the feature index is out of range.
     */
    virtual std::string getFeatureLabel(const uint32_t& index) = 0;

    /**
     * Get a feature value.
     *
     * @param[in] index zero-based feature index
     * @return          value of the feature or NAN if the feature cannot be computed
     *
     * @note
     * Throws an error if the feature index is out of range.
     */
    virtual double getFeatureValue(const uint32_t& index) = 0;
    
    /**
     * Virtual base class destructor.
     */
    virtual ~FeatureExtractor(void)
    {}
  };
}

#endif
