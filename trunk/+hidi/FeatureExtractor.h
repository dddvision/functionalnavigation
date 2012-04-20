#ifndef FEATUREEXTRACTOR_H
#define FEATUREEXTRACTOR_H

#include <vector>

namespace hidi
{
  class FeatureExtractor
  {
  private:
    FeatureExtractor(void)
    {}
  
  public:
    FeatureExtractor(double Fs)
    {}

    virtual void extract(const std::vector<double>& data, std::vector<double>& features) = 0;
  };
}

#endif
