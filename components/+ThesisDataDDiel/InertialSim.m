classdef InertialSim < InertialSixDoF
  
  properties (SetAccess=private,GetAccess=private)
    pFrame
    qFrame
    time
    na
    nb
    gyro
    accel
    ready
  end
  
  methods (Access=public)
    function this=InertialSim(localCache)
      this.pFrame=[0;0;0];
      this.qFrame=[1;0;0;0];
      [this.time,this.gyro,this.accel]=ReadIMUdat(localCache,'inertia.dat');
      N=numel(this.time);
      this.na=uint32(1);
      this.nb=uint32(N);
      this.ready=logical(N>0);
    end

    function refresh(this)
      assert(this.ready);
    end
    
    function flag=hasData(this)
      flag=this.ready;
    end
    
    function na=first(this)
      assert(this.ready)
      na=this.na;
    end

    function nb=last(this)
      assert(this.ready)
      nb=this.nb;
    end
    
    function time=getTime(this,n)
      assert(this.ready);
      assert(n>=this.na);
      assert(n<=this.nb);
      time=WorldTime(this.time(n));      
    end
    
    function [p,q]=getFrame(this)
      p=this.pFrame;
      q=this.qFrame;
    end

    function specificForce=getSpecificForce(this,n,ax)
      assert(this.ready);
      assert(n>=this.na);
      assert(n<=this.nb);
      specificForce=this.accel(ax+1,n);
    end
    
    function angularRate=getAngularRate(this,n,ax)
      assert(this.ready);
      assert(n>=this.na);
      assert(n<=this.nb);
      angularRate=this.gyro(ax+1,n);
    end
  end
end

% Reads inertial state files that were written by WriteIMUdat()
%
% INPUT
% path = directory for inertial data
% imufile = data file name
% 
% OUTPUT
% time = time stamp vector (1-by-(n+1))
% gyro = gyroscope output (3-by-n)
% accel = accelerometer output (3-by-n)
function [time,gyro,accel]=ReadIMUdat(path,imufile)
  fn=fullfile(path,imufile);
  [a,b,c,d,e,f,g]=textread(fn,'%f\t%f\t%f\t%f\t%f\t%f\t%f');
  time=a';
  gyro=[b';c';d'];
  accel=[e';f';g'];
end
