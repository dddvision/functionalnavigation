% Generate instantaneous optical flow field based on camera projection
%
% INPUT
% deltap = change in position, double 1-by-3
% deltaEuler = change in Euler angles, double 1-by-3
% pix = points in pixel coordinates, double 2-by-P
% nA = data node at which to compute the image projection, uint32 scalar
%
% OUTPUT
% uvr = flow in pixel coordinates due to rotation, double 2-by-P
% uvt = flow in pixel coordinates due to translation, double 2-by-P
%
% NOTES
% Pixel coordinate interpretation:
%   See CameraArray.projection
% Algorithm is based on:
%   http://code.google.com/p/functionalnavigation/wiki/MotionInducedOpticalFlow
function [uvr,uvt]=generateFlowSparse(this,deltap,deltaEuler,pix,nA)
  % Put the pixel coordinates through the inverse camera projection to get ray vectors
  c=this.sensor.inverseProjection(pix,nA);

  % Compute the rotation matrix R that represents the camera frame at time tb
  % relative to the camera frame at time ta.
  s1=sin(deltaEuler(1));
  c1=cos(deltaEuler(1));
  s2=sin(deltaEuler(2));
  c2=cos(deltaEuler(2));
  s3=sin(deltaEuler(3));
  c3=cos(deltaEuler(3));
  R=[c3*c2,c3*s2*s1-s3*c1,s3*s1+c3*s2*c1; s3*c2,c3*c1+s3*s2*s1,s3*s2*c1-c3*s1; -s2,c2*s1,c2*c1];

  % Rotate the ray vectors by pre-multiplying by the transpose of the rotation matrix
  c_new=transpose(R)*c; 

  % Put the new rays through the forward camera projection to get new pixel coordinates
  pix_new=this.sensor.projection(c_new,nA);

  % The rotational flow field is the pixel coordinate difference
  uvr=pix_new-pix;
  
  % Convert NaN to zero
  uvr(isnan(uvr(:)))=0;

  % Normalize the translation vector to a length that is very small relative to a unit magnitude
  T_mag=sqrt(dot(deltap,deltap));
  if(T_mag<eps)
    T_norm=zeros(3,1);
  else
    T_norm=(1E-6)*deltap/T_mag;
  end

  % Translate the camera rays by the negative of the camera translation
  c_new=c-repmat(T_norm,[1,size(c,2)]);

  % Put the new rays through the forward camera projection to get new pixel coordinates
  pix_new=this.sensor.projection(c_new,nA);

  % The translational flow field is the pixel coordinate difference
  uvt=pix_new-pix;
  
  % Convert NaN to zero
  uvt(isnan(uvt(:)))=0;
end
