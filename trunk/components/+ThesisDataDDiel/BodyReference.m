classdef BodyReference < Trajectory
  
  properties (SetAccess=private,GetAccess=private)
    T_imu
    x_imu
  end  
  
  methods (Access=public)
    function this=BodyReference(localCache,dataSetName)
      if(strcmp(dataSetName(1:6),'Gantry'))
        S=load(fullfile(localCache,'workspace.mat'),'INITIAL_BODY_STATE');
        [this.T_imu,this.x_imu]=ReadGantry(fullfile(localCache,'gantry_raw.dat'));
        N=size(this.x_imu,2);
        this.x_imu=[repmat(S.INITIAL_BODY_STATE(1:4),[1,N]);this.x_imu];
      else
        S=load(fullfile(localCache,'workspace.mat'),'T_imu','x_imu');
        this.x_imu=S.x_imu;
        N=size(S.x_imu,2);
        this.T_imu=S.T_imu;
      end
      
      % MIT laboratory location
      DTOR=pi/180;
      refLatitude=DTOR*42.3582722;
      refLongitude=DTOR*-71.0927417;
      
      % convert from tangent plane to ECEF
      Raxes=[0,0,-1;0,1,0;1,0,0];
      refR=Euler2Matrix([0;-refLatitude;refLongitude])*Raxes;
      refT=lolah2ecef([refLongitude;refLatitude;0]);
      refH=Quat2Homo(Euler2Quat(Matrix2Euler(refR)));
      this.x_imu(1:4,:)=refH*this.x_imu(1:4,:);
      this.x_imu(5:7,:)=refR*this.x_imu(5:7,:)+repmat(refT,[1,N]);
      
      % swap position and quaternion positions
      this.x_imu=this.x_imu([5,6,7,1,2,3,4],:);
    end
  
    function [a,b]=domain(this)
      a=this.T_imu(1);
      b=this.T_imu(end);
    end
  
    function [position,rotation,positionRate,rotationRate]=evaluate(this,t)
      [a,b]=domain(this);
      [pq,pqRate]=cardinalSpline(this.x_imu,this.T_imu,t);
      position=pq(1:3,:);
      rotation=pq(4:7,:);
      positionRate=pqRate(1:3,:);
      rotationRate=pqRate(4:7,:);
      rotation=quatNorm(rotation);
      bad=(t<a)|(t>b);
      position(:,bad)=NaN;
      rotation(:,bad)=NaN;
      positionRate(:,bad)=NaN;
      rotationRate(:,bad)=NaN;
    end
  end
  
end

function [t,x]=ReadGantry(filename)
  [tg,xg,yg,zg]=textread(filename,'%f %f %f %f');
  t=tg'-tg(1);
  s=sin(25*pi/180);
  c=cos(25*pi/180);
  N=yg*c-xg*s;
  E=-yg*s-xg*c;
  D=-zg;
  x=[N';E';D'];
end

% Cardinal Spline interpolation function
%
% INPUT
% t = time index of pts, double 1-by-N
% pts = points in M dimensions to be interpolated, double M-by-N
% test_t = times at which to interpolate, double 1-by-K
% c = (default 0) tension parameter, double scalar
%
% NOTES
% The default tension parameter yields a Catman Hull spline
function [pos,posdot]=cardinalSpline(pts,t,test_t,c)
  if(nargin<4)
    c=0;
  end
  pts=pts';
  D=size(pts,2);
  Ntest=numel(test_t);
  pos=zeros(D,Ntest);
  posdot=zeros(D,Ntest);
  if(Ntest==0)
    return;
  end
  Npts = size(pts,1);
  if(Npts<2)
    error('At least two points required to interpolate');
  end
  % Compute the slopes at each point
  wt = (1-c)./2;
  m = zeros(size(pts));
  for dim = 1:size(pts,2)
    for indx = 2:(Npts-1)
      m(indx,:) = wt*(pts(indx+1,:)-pts(indx-1,:));
    end
  end
  m(1,:) = 2*wt*(pts(2,:)-pts(1,:));
  m(end,:) = 2*wt*(pts(end,:)-pts(end-1,:));
  % Find the t indices between which the current test_t lies
  for indx = 1:Ntest
    t_indx = find(test_t(indx) >= t);
    t_indx = t_indx(end);
    if( (isempty(t_indx)) || (t_indx==1) )
      t_indx = 1;
    end
    if( t_indx==Npts )
      t_indx = Npts-1;
    end
    t_range = t(t_indx+1)-t(t_indx);
    curr_t = (test_t(indx)-t(t_indx))./t_range;
    h00 = 2*curr_t.^3-3*curr_t.^2+1;
    h10 = curr_t.^3-2*curr_t^2+curr_t;
    h01 = -2*curr_t.^3+3*curr_t.^2;
    h11 = curr_t.^3-curr_t.^2;
    h00dot = 6*curr_t.^2-6*curr_t;
    h10dot = 3*curr_t.^2-4*curr_t;
    h01dot = -6*curr_t.^2-6*curr_t;
    h11dot = 3*curr_t.^2-2*curr_t;
    pos(:,indx) = (h00.*pts(t_indx,:) + h10.*m(t_indx,:) + ...
      h01.*pts(t_indx+1,:) + h11.*m(t_indx+1,:))';
    posdot(:,indx) = (h00dot.*pts(t_indx,:) + h10dot.*m(t_indx,:) + ...
      h01dot.*pts(t_indx+1,:) + h11dot.*m(t_indx+1,:))';
  end
end

function Y=Matrix2Euler(R)
  Y=zeros(3,1); 
  Y(1)=atan2(R(3,2),R(3,3));
  Y(2)=asin(-R(3,1));
  Y(3)=atan2(R(2,1),R(1,1));
end

function Q=Euler2Quat(E)
  a=E(1,:);
  b=E(2,:);
  c=E(3,:);
  c1=cos(a/2);
  c2=cos(b/2);
  c3=cos(c/2);
  s1=sin(a/2);
  s2=sin(b/2);
  s3=sin(c/2);
  Q(1,:) = c3.*c2.*c1 + s3.*s2.*s1;
  Q(2,:) = c3.*c2.*s1 - s3.*s2.*c1;
  Q(3,:) = c3.*s2.*c1 + s3.*c2.*s1;
  Q(4,:) = s3.*c2.*c1 - c3.*s2.*s1;
end

function M=Euler2Matrix(Y)
  Y1=Y(1);
  Y2=Y(2);
  Y3=Y(3);
  c1=cos(Y1);
  c2=cos(Y2);
  c3=cos(Y3);
  s1=sin(Y1);
  s2=sin(Y2);
  s3=sin(Y3);
  M=zeros(3);
  M(1,1)=c3.*c2;
  M(1,2)=c3.*s2.*s1-s3.*c1;
  M(1,3)=s3.*s1+c3.*s2.*c1;
  M(2,1)=s3.*c2;
  M(2,2)=c3.*c1+s3.*s2.*s1;
  M(2,3)=s3.*s2.*c1-c3.*s1;
  M(3,1)=-s2;
  M(3,2)=c2.*s1;
  M(3,3)=c2.*c1;
end

function h=Quat2Homo(q)
  q1=q(1);
  q2=q(2);
  q3=q(3);
  q4=q(4);
  h=[[q1,-q2,-q3,-q4]
     [q2, q1,-q4, q3]
     [q3, q4, q1,-q2]
     [q4,-q3, q2, q1]];
end

% Quaternion normalization
%
% INPUT/OUTPUT
% q = quaternions, 4-by-N
%
% NOTES
% Assumes that the magnitude of the input vectors is nonzero
% Does not modify quaternion sign
function q=quatNorm(q)
  qnorm=sqrt(q(1,:).*q(1,:)+q(2,:).*q(2,:)+q(3,:).*q(3,:)+q(4,:).*q(4,:));
  q=q./repmat(qnorm,[4,1]);
end

function ecef=lolah2ecef(lolah)
  lon = lolah(1,:);
  lat = lolah(2,:);
  alt = lolah(3,:);
  a = 6378137;
  finv = 298.257223563;
  b = a-a/finv;
  a2 = a.*a;
  b2 = b.*b;
  e = sqrt((a2-b2)./a2);
  slat = sin(lat);
  clat = cos(lat);
  N = a./sqrt(1-(e*e)*(slat.*slat));
  ecef = [(alt+N).*clat.*cos(lon);
          (alt+N).*clat.*sin(lon);
          ((b2./a2)*N+alt).*slat];
end
