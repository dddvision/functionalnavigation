#ifndef FEATUREEXTRACTOR_H
#define FEATUREEXTRACTOR_H

#include <string>
#include <utility>
#include <vector>
#include "SensorPackage.h"

class FeatureExtractor
{
public:  
  /**
   * Get number of features available from the extract function.
   *
   * @return number of features
   */ 
  virtual uint32_t numFeatures(void) = 0; 

  /**
   * Get the name of a feature.
   *
   * @param[in] index feature index
   * return           feature name
   */
  virtual std::string getName(uint32_t index) = 0;
  
  /**
   * Extract a feature.
   *
   * @param[in] index feature index
   * @return          feature value
   */
  virtual double extract(uint32_t index) = 0;
  
  static void connect(FeatureExtractor* featureExtractor)
  {
    std::pair<size_t, uint32_t> item(pExtractors()->size(), 0);
    uint32_t N = featureExtractor->numFeatures();
    uint32_t n;
    for(n = 0; n<N; ++n)
    {
      item.second = n;
      pLookup()->push_back(item);
    }
    pExtractors()->push_back(featureExtractor);
    return;
  }

protected:
  typedef std::pair<size_t, uint32_t> ExtractorFeaturePair;
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

class FeatureExtractorComposite : public FeatureExtractor
{
public:  
  uint32_t numFeatures(void)
  {
    return (FeatureExtractor::pLookup()->size());
  }
  
  std::string getName(uint32_t index)
  {
    size_t extractorIndex;
    uint32_t featureIndex;
    if(index>=numFeatures())
    {
      throw("Feature index is out of range.");
    }
    extractorIndex = (*FeatureExtractor::pLookup())[index].first;
    featureIndex = (*FeatureExtractor::pLookup())[index].second;
    return ((*FeatureExtractor::pExtractors())[extractorIndex]->getName(featureIndex));
  }
  
  double extract(uint32_t index)
  {
    size_t extractorIndex;
    uint32_t featureIndex;
    if(index>=numFeatures())
    {
      throw("Feature index is out of range.");
    }
    extractorIndex = (*FeatureExtractor::pLookup())[index].first;
    featureIndex = (*FeatureExtractor::pLookup())[index].second;
    return ((*FeatureExtractor::pExtractors())[extractorIndex]->extract(featureIndex));
  }
};

#endif
