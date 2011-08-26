% This subclass defines an inertial sensor with the following features:
%   three orthogonal axes
%   one accelerometer and one gyroscope on each axis
%   shared time stamps
%   shared origin
classdef InertialSixDoF < antbed.AccelerometerArray & antbed.GyroscopeArray

  methods (Access=public, Static=true)
    function this = InertialSixDoF(initialTime)
      this = this@antbed.AccelerometerArray(initialTime);
      this = this@antbed.GyroscopeArray(initialTime);
    end
  end
  
  methods (Abstract=true)
    % Get sensor frame position and orientation relative to the body frame
    %
    % OUTPUT
    % pose = position and orientation of sensor origin in the body frame, Pose scalar
    pose=getFrame(this);
  end
  
  methods (Access=public)
    % This subclass provides exactly three axes
    function num=numAxes(this)
      assert(isa(this,'InertialSixDoF'));
      num=uint32(3);
    end
    
    % This subclass defines the axis order and orientation
    function [offset,direction]=getAxis(this,ax)
      assert(isa(ax,'uint32'));
      pose=getFrame(this);
      offset=pose.p;
      q=pose.q;
      q11=q(1)*q(1);
      q22=q(2)*q(2);
      q33=q(3)*q(3);
      q44=q(4)*q(4);
      q12=q(1)*q(2);
      q23=q(2)*q(3);
      q34=q(3)*q(4);
      q14=q(1)*q(4);
      q13=q(1)*q(3);
      q24=q(2)*q(4);
      switch ax
        case uint32(0)
          direction = [ q11+q22-q33-q44 ; 2*(q23+q14) ; 2*(q24-q13) ];
        case uint32(1)
          direction = [ 2*(q23-q14) ; q11-q22+q33-q44 ; 2*(q34+q12) ];
        case uint32(2)
          direction = [ 2*(q24+q13) ; 2*(q34-q12) ; q11-q22-q33+q44 ];
        otherwise
          error('invalid axis requested');
      end
    end
  end
end
