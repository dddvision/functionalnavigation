#ifndef HIDIFEATUREEXTRACTORCOMPOSITE_H
#define HIDIFEATUREEXTRACTORCOMPOSITE_H

#include <utility>
#include <vector>
#include "FeatureExtractor.h"

namespace hidi
{
  class FeatureExtractorComposite : FeatureExtractor
  {
  public:
    size_t numFeatures(void)
    {
      return (lookup.size());
    }

    std::string getFeatureLabel(const size_t& index)
    {
      size_t extractorIndex;
      size_t featureIndex;
      if(index>=numFeatures())
      {
        throw("FeatureExtractorComposite: Feature index is out of range.");
      }
      extractorIndex = lookup[index].first;
      featureIndex = lookup[index].second;
      return (extractors[extractorIndex]->getFeatureLabel(featureIndex));
    }

    double getFeatureValue(const size_t& index)
    {
      size_t extractorIndex;
      size_t featureIndex;
      if(index>=numFeatures())
      {
        throw("FeatureExtractorComposite: Feature index is out of range.");
      }
      extractorIndex = lookup[index].first;
      featureIndex = lookup[index].second;
      return (extractors[extractorIndex]->getFeatureValue(featureIndex));
    }

    /**
     * Append a feature extractor to the composite.
     */
    void append(FeatureExtractor* featureExtractor)
    {
      std::pair<size_t, size_t> item(extractors.size(), 0);
      size_t N = featureExtractor->numFeatures();
      size_t n;
      for(n = 0; n<N; ++n)
      {
        item.second = n;
        lookup.push_back(item);
      }
      extractors.push_back(featureExtractor);
      return;
    }
    
    /**
     * Virtual base class destructor.
     */
    virtual ~FeatureExtractorComposite(void)
    {}
    
  private:
    typedef std::pair<size_t, size_t> ExtractorFeaturePair;
    std::vector<ExtractorFeaturePair> lookup;
    std::vector<FeatureExtractor*> extractors;
  };
}

#endif
