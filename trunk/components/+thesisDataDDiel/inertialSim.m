classdef inertialSim < inertialSixDOF
  
  properties (SetAccess=private,GetAccess=private)
    pFrame
    qFrame
    time
    gyro
    accel
    isLocked
  end
  
  methods (Access=public)
    function this=inertialSim(localCache)
      this.pFrame=[0;0;0];
      this.qFrame=[1;0;0;0];
      [this.time,this.gyro,this.accel]=ReadIMUdat(localCache,'inertia.dat');
      this.isLocked=false;
    end

    function lock(this)
      this.isLocked=true;
    end
    
    function unlock(this)
      this.isLocked=false;
    end
    
    function dt=getIntegrationTime(this)
      dt=this.time(2)-this.time(1);
    end
    
    function [p,q]=getFrame(this)
      p=this.pFrame;
      q=this.qFrame;
    end
    
    function [ka,kb]=domain(this)
      assert(this.isLocked);
      ka=uint32(1);
      kb=uint32(numel(this.time));
    end
    
    function time=getTime(this,k)
      assert(isa(k,'uint32'));
      assert(this.isLocked);
      time=this.time(k);      
    end

    function specificForce=getSpecificForce(this,k,ax)
      assert(isa(k,'uint32'));
      assert(this.isLocked);
      specificForce=this.accel(ax+1,k);
    end
    
    function angularRate=getAngularRate(this,k,ax)
      assert(isa(k,'uint32'));
      assert(this.isLocked);
      angularRate=this.gyro(ax+1,k);
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