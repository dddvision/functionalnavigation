#ifndef HIDIDEPTHCAMERA_H
#define HIDIDEPTHCAMERA_H

#include "Sensor.h"

namespace hidi
{
  /**
   * This class represents a single depth camera.
   */
  class DepthCamera : public virtual Sensor
  {
  private:
    /**
     * Prevents deep copying.
     */
    DepthCamera(const DepthCamera&);

    /**
     * Prevents assignment.
     */
    DepthCamera& operator=(const DepthCamera&);

  protected:
    /**
     * Protected constructor.
     */
    DepthCamera(void)
    {}

  public:
   /**
    * Get number of pixels in the contiguous dimension of each depth image.
    *
    * @return number of steps
    */
    virtual uint32_t numSteps(void) = 0;
    
   /**
    * Get number of pixels in the non-contiguous dimension of each depth image.
    *
    * @return number of strides
    */
    virtual uint32_t numStrides(void) = 0;
    
   /**
    * Project unit magnitude ray vectors in the camera frame to points in the depth image.
    *
    * @param[in]  f      forward component of the ray
    * @param[in]  r      right component of the ray
    * @param[in]  d      down component of the ray
    * @param[out] stride coordinate in the non-contiguous image dimension associated with the ray
    * @param[out] step   coordinate in the contiguous image dimension associated with the ray
    *
    * @note
    * Invalid regions are identified by NAN outputs.
    */
    virtual void projection(const double& f, const double& r, const double& d, double& stride, double& step) = 0;
    
   /**
    * Project points in the depth image to unit magnitude ray vectors in the camera frame.
    *
    * @param[in]  stride coordinate in the non-contiguous image dimension
    * @param[in]  step   coordinate in the contiguous image dimension
    * @param[out] f      forward component of the ray associated with the image coordinate
    * @param[out] r      right component of the ray associated with the image coordinate
    * @param[out] d      down component of the ray associated with the image coordinate
    *
    * @note
    * Invalid regions are identified by NAN outputs.
    */
    virtual void inverseProjection(const double& stride, const double& step, double& f, double& r, double& d) = 0;
    
    /**
     * Get depth image over a bounded region.
     *
     * @param[in]  node      data index
     * @param[in]  strideMin index of first stride within bounded region
     * @param[in]  strideMax index of last stride within bounded region
     * @param[in]  stepMin   index of first step within bounded region
     * @param[in]  stepMax   index of last step within bounded region
     * @param[out] depth     distance from the sensor origin to the scene
     *
     * @note
     * The output will be resized to numStrides()*numSteps() and filled within the bounded region.
     * Invalid pixels within the bounded region are filled with NAN.
     * Throws an exception if any index is out of range.
     */
    virtual void getDepth(const uint32_t& node, const uint32_t& strideMin, const uint32_t& strideMax, 
      const uint32_t& stepMin, const uint32_t& stepMax, std::vector<double>& data) = 0;
    
    /**
     * Virtual base class destructor.
     */
    virtual ~DepthCamera(void)
    {}
  };
}

#endif
