#ifndef HIDIFEATUREEXTRACTORCOMPOSITE_H
#define HIDIFEATUREEXTRACTORCOMPOSITE_H

#include <utility>
#include <vector>
#include "FeatureExtractor.h"

namespace hidi
{
  /**
   * This class is a FeatureExtractor composed of multiple FeatureExtractors.
   */
  class FeatureExtractorComposite : public virtual FeatureExtractor
  {
  public:
    uint32_t numFeatures(void)
    {
      return (lookup.size());
    }

    std::string getFeatureLabel(const uint32_t& index)
    {
      uint32_t extractorIndex;
      uint32_t featureIndex;
      if(index>=numFeatures())
      {
        throw("FeatureExtractorComposite: Feature label index is out of range.");
      }
      extractorIndex = lookup[index].first;
      featureIndex = lookup[index].second;
      return (extractors[extractorIndex]->getFeatureLabel(featureIndex));
    }

    double getFeatureValue(const uint32_t& index)
    {
      uint32_t extractorIndex;
      uint32_t featureIndex;
      if(index>=numFeatures())
      {
        throw("FeatureExtractorComposite: Feature value index is out of range.");
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
      std::pair<uint32_t, uint32_t> item(extractors.size(), 0);
      uint32_t N = featureExtractor->numFeatures();
      uint32_t n;
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
    typedef std::pair<uint32_t, uint32_t> ExtractorFeaturePair;
    std::vector<ExtractorFeaturePair> lookup;
    std::vector<FeatureExtractor*> extractors;
  };
}

#endif
