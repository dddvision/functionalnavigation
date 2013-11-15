#ifndef HIDICAMERA_H
#define HIDICAMERA_H

#include "Sensor.h"

namespace hidi
{
  /**
   * This class represents a single camera.
   */
  class Camera : public virtual Sensor
  {
  private:
    /**
     * Prevents deep copying.
     */
    Camera(const Camera&);

    /**
     * Prevents assignment.
     */
    Camera& operator=(const Camera&);

  protected:
    /**
     * Protected constructor.
     */
    Camera(void)
    {}

  public:
    /**
     * Interpret image layers.
     *
     * @return character sequence describing the image layers
     *   'r' red
     *   'g' green
     *   'b' blue
     *   'h' hue
     *   's' saturation
     *   'v' grayscale value
     *   'i' short wave infrared
     *   't' thermal infrared
     *   'd' distance from the sensor origin to the scene (meters)
     *
     * @note
     * The number of characters returned is equal to the number of image layers.
     * Repeated characters may be used to indicate multiple views that share a projection model as in 'rgbrgb'.
     */
    virtual std::string interpretLayers(void) = 0;
    
    /**
     * Get number of pixels in the non-contiguous dimension of each image.
     *
     * @return number of strides
     */
    virtual uint32_t numStrides(void) = 0;

    /**
     * Get number of pixels in the contiguous dimension of each image.
     *
     * @return number of steps
     */
    virtual uint32_t numSteps(void) = 0;
    
    /**
     * Get index of first stride within the bounding box of the valid data region.
     *
     * @param[in] node node index
     * @return         stride index
     *
     * @note
     * Throws an exception if node index is out of range.
     */
    virtual uint32_t strideMin(const uint32_t& node) = 0;
    
    /**
     * Get index of last stride within the bounding box of the valid data region.
     *
     * @param[in] node node index
     * @return         stride index
     *
     * @note
     * Throws an exception if node index is out of range.
     */
    virtual uint32_t strideMax(const uint32_t& node) = 0;
    
    /**
     * Get index of first step within the bounding box of the valid data region.
     *
     * @param[in] node node index
     * @return         step index
     *
     * @note
     * Throws an exception if node index is out of range.
     */
    virtual uint32_t stepMin(const uint32_t& node) = 0;
    
    /**
     * Get index of last step within the bounding box of the valid data region.
     *
     * @param[in] node node index
     * @return         step index
     *
     * @note
     * Throws an exception if node index is out of range.
     */
    virtual uint32_t stepMax(const uint32_t& node) = 0;
    
    /**
     * Project unit magnitude ray vectors in the camera frame to points in the image.
     *
     * @param[in]  forward forward component of the ray (MATLAB: M-by-N)
     * @param[in]  right   right component of the ray (MATLAB: M-by-N)
     * @param[in]  down    down component of the ray (MATLAB: M-by-N)
     * @param[out] stride  coordinate in the non-contiguous image dimension associated with the ray (MATLAB: M-by-N)
     * @param[out] step    coordinate in the contiguous image dimension associated with the ray (MATLAB: M-by-N)
     *
     * @note
     * Invalid regions are identified by NAN outputs.
     */
    virtual void projection(const double& forward, const double& right, const double& down, double& stride, 
      double& step) = 0;

    /**
     * Project points in the image to unit magnitude ray vectors in the camera frame.
     *
     * @param[in]  stride  coordinate in the non-contiguous image dimension (MATLAB: M-by-N)
     * @param[in]  step    coordinate in the contiguous image dimension (MATLAB: M-by-N)
     * @param[out] forward forward component of the ray associated with the image coordinate (MATLAB: M-by-N)
     * @param[out] right   right component of the ray associated with the image coordinate (MATLAB: M-by-N)
     * @param[out] down    down component of the ray associated with the image coordinate (MATLAB: M-by-N)
     *
     * @note
     * Invalid regions are identified by NAN outputs.
     */
    virtual void inverseProjection(const double& stride, const double& step, double& forward, double& right, 
      double& down) = 0;
    
    /**
     * Get an unsigned 8-bit image over a bounded region.
     *
     * @param[in]      node  node index
     * @param[in]      layer layer index
     * @param[in, out] img   image values
     *
     * @note
     * Output values are normalized and truncated to fit the bit depth.
     * The output will be resized to numStrides()*numSteps() and filled within the bounded region.
     * Invalid pixels within the bounded region are filled with 0.
     * Throws an exception if any index is out of range.
     */
    virtual void getImageUInt8(const uint32_t& node, const uint32_t& layer, std::vector<uint8_t>& img) = 0;
    
    /**
     * Get a real image over a bounded region.
     *
     * @param[in]      node  node index
     * @param[in]      layer layer index
     * @param[in, out] img   image values
     *
     * @note
     * Output values are either normalized to the range [0, 1] or given in meters.
     * The output will be resized to numStrides()*numSteps() and filled within the bounded region.
     * Invalid pixels within the bounded region are filled with NAN.
     * Throws an exception if any index is out of range.
     */
    virtual void getImageDouble(const uint32_t& node, const uint32_t& layer, std::vector<double>& img) = 0;
    
    /**
     * Virtual base class destructor.
     */
    virtual ~Camera(void)
    {}
  };
}

#endif
