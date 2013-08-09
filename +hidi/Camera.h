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
     * Interpret image layers.
     *
     * @return character sequence describing the image layers
     *   'r' red
     *   'g' green
     *   'b' blue
     *   'h' hue
     *   's' saturation
     *   'v' grayscale value
     *   'd' distance from the sensor origin to the scene (meters)
     *
     * @note
     * The number of characters returned is equal to the number of image layers.
     * Repeated characters may be used to indicate multiple views that share a projection model as in 'rgbrgb'.
     */
    virtual std::string interpretLayers(void) = 0;

    /**
     * Project unit magnitude ray vectors in the camera frame to points in the image.
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
     * Project points in the image to unit magnitude ray vectors in the camera frame.
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
     * Get index of first stride within the bounding box of the valid data region.
     *
     * @param[in] n node index
     * @return      stride index
     *
     * @note
     * Throws an exception if node index is out of range.
     */
    virtual uint32_t strideMin(const uint32_t& n) = 0;
    
    /**
     * Get index of last stride within the bounding box of the valid data region.
     *
     * @param[in] n node index
     * @return      stride index
     *
     * @note
     * Throws an exception if node index is out of range.
     */
    virtual uint32_t strideMax(const uint32_t& n) = 0;
    
    /**
     * Get index of first step within the bounding box of the valid data region.
     *
     * @param[in] n node index
     * @return      step index
     *
     * @note
     * Throws an exception if node index is out of range.
     */
    virtual uint32_t stepMin(const uint32_t& n) = 0;
    
    /**
     * Get index of last step within the bounding box of the valid data region.
     *
     * @param[in] n node index
     * @return      step index
     *
     * @note
     * Throws an exception if node index is out of range.
     */
    virtual uint32_t stepMax(const uint32_t& n) = 0;
    
    /**
     * Get an unsigned 8-bit image over a bounded region.
     *
     * @param[in]  n     node index
     * @param[in]  layer layer index
     * @param[out] image values
     *
     * @note
     * Output values are normalized and truncated to fit the bit depth.
     * The output will be resized to numStrides()*numSteps() and filled within the bounded region.
     * Invalid pixels within the bounded region are filled with NAN.
     * Throws an exception if any index is out of range.
     */
    virtual void getImageUInt8(const uint32_t& n, const uint32_t& layer, std::vector<uint8_t>& image) = 0;
    
    /**
     * Get a real image over a bounded region.
     *
     * @param[in]  n     node index
     * @param[in]  layer layer index
     * @param[out] image values
     *
     * @note
     * Output values are either normalized to the range [0, 1] or given in meters.
     * The output will be resized to numStrides()*numSteps() and filled within the bounded region.
     * Invalid pixels within the bounded region are filled with NAN.
     * Throws an exception if any index is out of range.
     */
    virtual void getImageDouble(const uint32_t& n, const uint32_t& layer, std::vector<double>& image) = 0;
    
    /**
     * Virtual base class destructor.
     */
    virtual ~Camera(void)
    {}
  };
}

#endif
