#ifndef FEATUREEXTRACTORCOMPOSITE_H
#define FEATUREEXTRACTORCOMPOSITE_H

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

    std::string getLabel(const size_t& index)
    {
      size_t extractorIndex;
      size_t featureIndex;
      if(index>=numFeatures())
      {
        throw("Feature index is out of range.");
      }
      extractorIndex = lookup[index].first;
      featureIndex = lookup[index].second;
      return (extractors[extractorIndex]->getLabel(featureIndex));
    }

    double getValue(const size_t& index)
    {
      size_t extractorIndex;
      size_t featureIndex;
      if(index>=numFeatures())
      {
        throw("Feature index is out of range.");
      }
      extractorIndex = lookup[index].first;
      featureIndex = lookup[index].second;
      return (extractors[extractorIndex]->getValue(featureIndex));
    }

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

  private:
    typedef std::pair<size_t, size_t> ExtractorFeaturePair;
    std::vector<ExtractorFeaturePair> lookup;
    std::vector<FeatureExtractor*> extractors;
  };
}

#endif