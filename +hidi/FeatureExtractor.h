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
    virtual size_t size(void) = 0; 

    /**
     * Get the name of a feature.
     *
     * @param[in] index feature index
     * return           feature name
     */
    virtual std::string getName(size_t index) = 0;

    /**
     * Get the value of a feature.
     *
     * @param[in] index feature index
     * @return          feature value
     */
    virtual double getValue(size_t index) = 0;
  };
}

#endif
