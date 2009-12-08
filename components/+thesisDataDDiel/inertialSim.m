classdef inertialSim < inertialSixDOF
  
  properties (SetAccess=private,GetAccess=private)
    pFrame
    qFrame
    time
    ka
    kb
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
      this.ka=uint32(1);
      this.kb=uint32(numel(this.time));
    end

    function [ka,kb]=dataDomain(this)
      assert(this.isLocked);
      ka=this.ka;
      kb=this.kb;
    end
    
    function time=getTime(this,k)
      assert(this.isLocked);
      assert(k>=this.ka);
      assert(k<=this.kb);
      time=this.time(k);      
    end
    
    function isLocked=lock(this)
      this.isLocked=true;
      isLocked=this.isLocked;
    end

    function isUnlocked=unlock(this)
      this.isLocked=false;
      isUnlocked=~this.isLocked;
    end
    
    function dt=getIntegrationTime(this)
      dt=this.time(2)-this.time(1);
    end
    
    function [p,q]=getFrame(this)
      p=this.pFrame;
      q=this.qFrame;
    end

    function specificForce=getSpecificForce(this,k,ax)
      assert(this.isLocked);
      assert(k>=this.ka);
      assert(k<=this.kb);
      specificForce=this.accel(ax+1,k);
    end
    
    function angularRate=getAngularRate(this,k,ax)
      assert(this.isLocked);
      assert(k>=this.ka);
      assert(k<=this.kb);
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