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
    size_t size(void)
    {
      return (pLookup()->size());
    }

    std::string getName(size_t index)
    {
      size_t extractorIndex;
      size_t featureIndex;
      if(index>=size())
      {
        throw("Feature index is out of range.");
      }
      extractorIndex = (*pLookup())[index].first;
      featureIndex = (*pLookup())[index].second;
      return ((*pExtractors())[extractorIndex]->getName(featureIndex));
    }

    double getValue(size_t index)
    {
      size_t extractorIndex;
      size_t featureIndex;
      if(index>=size())
      {
        throw("Feature index is out of range.");
      }
      extractorIndex = (*pLookup())[index].first;
      featureIndex = (*pLookup())[index].second;
      return ((*pExtractors())[extractorIndex]->getValue(featureIndex));
    }

    static void connect(FeatureExtractor* featureExtractor)
    {
      std::pair<size_t, size_t> item(pExtractors()->size(), 0);
      size_t N = featureExtractor->size();
      size_t n;
      for(n = 0; n<N; ++n)
      {
        item.second = n;
        pLookup()->push_back(item);
      }
      pExtractors()->push_back(featureExtractor);
      return;
    }

  protected:
    typedef std::pair<size_t, size_t> ExtractorFeaturePair;
    static std::vector<ExtractorFeaturePair>* pLookup(void)
    {
      static std::vector<ExtractorFeaturePair> lookup;
      return (&lookup);
    }

    static std::vector<FeatureExtractor*>* pExtractors(void)
    {
      static std::vector<FeatureExtractor*> extractors;
      return (&extractors);
    }
  };
}

#endif
