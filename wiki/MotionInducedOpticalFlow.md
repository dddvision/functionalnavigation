### Introduction ###

As a camera moves, light rays from the environment slice through a theoretical unit sphere centered at the camera's focus, resulting in patterns of light that appear to flow around the sphere.  Given the camera projection equations and a hypothetical body trajectory, one can predict the induced rotation field and the direction of the translation field.  This section describes how to compute the rotation field and the direction, but not the magnitude, of the translation field.

### Algorithm: Compute Camera Rays ###

<img src='https://github.com/dddvision/functionalnavigation/blob/master/wiki/StandardPerspectiveRays.png'>

<ul><li>Get an image from the camera.<br>
</li><li>Query the image size.<br>
</li><li>Generate coordinates <code>x</code> for each pixel (ex. using <code>ndgrid</code>).<br>
<pre><code>x = [ 0 0 0 0 0 1 1 1 1 1 2 2 2 2 2 ... ]<br>
    [ 0 1 2 3 4 0 1 2 3 4 0 1 2 3 4 ... ]<br>
</code></pre>
</li><li>Put the pixel coordinates through the inverse camera projection to get ray vectors <code>c</code>.</li></ul>

<h3>Algorithm: Compute Rotation Field</h3>

<img src='https://github.com/dddvision/functionalnavigation/blob/master/wiki/StandardPerspectiveRotation.png'>

<ul><li>Get hypothetical body poses at two time instants <code>ta</code> and <code>tb</code>.<br>
</li><li>Compute the rotation matrix <code>R</code> that represents the camera frame at time <code>tb</code> relative to the camera frame at time <code>ta</code>.<br>
</li><li>Rotate the ray vectors by pre-multiplying by the transpose of the rotation matrix (ie. <code>c_new=transpose(R)*c</code>).<br>
</li><li>Put the new rays <code>c_new</code> through the forward camera projection to get new pixel coordinates <code>x_new</code>.<br>
</li><li>The rotational flow field is the pixel coordinate difference <code>u=x_new-x</code>.</li></ul>

<h3>Algorithm: Compute Translation Field</h3>

<img src='https://github.com/dddvision/functionalnavigation/blob/master/wiki/StandardPerspectiveTranslationNormalized.png'>

<ul><li>Get hypothetical body poses at two time instants <code>ta</code> and <code>tb</code>.<br>
</li><li>Compute the translation vector <code>T</code> that represents the position of the camera frame origin at time <code>tb</code> relative to the camera frame origin at time <code>ta</code>.<br>
</li><li>Normalize the translation vector to a length that is very small relative to a unit magnitude (ie. <code>T_norm=1E-6*T/sqrt(dot(T,T))</code>).<br>
</li><li>Translate the camera rays by the negative of the camera translation (ie. <code>c_new=c-T_norm</code>).<br>
</li><li>Put the new rays <code>c_new</code> through the forward camera projection to get new pixel coordinates <code>x_new</code>.<br>
</li><li>The translational flow field is the pixel coordinate difference <code>u=x_new-x</code>, where each flow vector can be normalized to an arbitrary magnitude, taking care not to divide by zero.
