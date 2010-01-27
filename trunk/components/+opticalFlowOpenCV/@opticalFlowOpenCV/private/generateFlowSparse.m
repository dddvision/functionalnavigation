% Generate instantaneous optical flow field based on camera projection
%
% INPUT
% deltap = change in position, double 1-by-3
% deltaq = change in Euler angles, double 1-by-3
%
% OUTPUT
%
% TODO: check these equations
function [uvr,uvt]=generateFlowSparse(this,deltap,deltaq,points)
  s1=sin(deltaq(1));
  c1=cos(deltaq(1));
  s2=sin(deltaq(2));
  c2=cos(deltaq(2));
  s3=sin(deltaq(3));
  c3=cos(deltaq(3));
  invR=[c3*c2,s3*c2,-s2;c3*s2*s1-s3*c1,c3*c1+s3*s2*s1,c2*s1;s3*s1+c3*s2*c1,s3*s2*c1-c3*s1,c2*c1];
  pix(1,:)=points(:,1);
  pix(2,:)=points(:,2);
  ray=inverseProjection(this.sensor,pix);
  ray_new=invR*ray; 
  x_new=projection(this.sensor,ray_new);
  uvr(1,:)=pix(1,:)-x_new(1,:);
  uvr(2,:)=pix(2,:)-x_new(2,:);
  T_mag=sqrt(dot(deltap,deltap));
  if(T_mag<eps)
    T_norm=zeros(1:3);
  else
    T_norm=(1E-8)*deltap/T_mag;
  end
  ray_new(1,:)=ray(1,:)-T_norm(3);
  ray_new(2,:)=ray(2,:)-T_norm(1);
  ray_new(3,:)=ray(3,:)-T_norm(2);
  x_new=projection(this.sensor,ray_new);
  uvt(1,:)=pix(1,:)-x_new(1,:);
  uvt(2,:)=pix(2,:)-x_new(2,:);
  uvr(isnan(uvr(:,:)))=0;
  uvt(isnan(uvt(:,:)))=0;     
end
