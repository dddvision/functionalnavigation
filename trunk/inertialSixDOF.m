% This subclass defines an inertial sensor characterized by:
%   three orthogonal axes
%   one accelerometer and one gyroscope on each axis
%   shared time stamps
%   shared origin
classdef inertialSixDOF < accelerometerArray & gyroscopeArray

  methods (Abstract=true)
    % Get sensor frame position and orientation relative to the body frame
    %
    % INPUT
    % k = data index, uint32 scalar
    %
    % OUTPUT
    % p = position of sensor origin in the body frame, double 3-by-1
    % q = orientation of sensor frame in the body frame as a quaternion, double 4-by-1
    [p,q]=getFrame(this);
  end
  
  methods (Access=public)
    % This subclass provides exactly three axes
    function num=numAxes(this)
      assert(isa(this,'inertialSixDOF'));
      num=uint32(3);
    end
    
    % This subclass defines the axis order and orientation
    function [offset,direction]=getAxis(this,ax)
      assert(isa(ax,'uint32'));
      [offset,q]=getFrame(this);
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
