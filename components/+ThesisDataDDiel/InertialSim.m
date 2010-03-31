classdef InertialSim < InertialSixDoF
  
  properties (SetAccess=private,GetAccess=private)
    pFrame
    qFrame
    time
    ka
    kb
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
      this.ka=uint32(1);
      this.kb=uint32(N);
      this.ready=logical(N>0);
    end

    function refresh(this)
      assert(isa(this,'InertialSixDoF'));
    end
    
    function flag=hasData(this)
      flag=this.ready;
    end
    
    function ka=first(this)
      assert(this.ready)
      ka=this.ka;
    end

    function kb=last(this)
      assert(this.ready)
      kb=this.kb;
    end
    
    function time=getTime(this,k)
      assert(this.ready);
      assert(k>=this.ka);
      assert(k<=this.kb);
      time=this.time(k);      
    end
    
    function dt=getIntegrationTime(this)
      dt=this.time(2)-this.time(1);
    end
    
    function [p,q]=getFrame(this)
      p=this.pFrame;
      q=this.qFrame;
    end

    function specificForce=getSpecificForce(this,k,ax)
      assert(this.ready);
      assert(k>=this.ka);
      assert(k<=this.kb);
      specificForce=this.accel(ax+1,k);
    end
    
    function angularRate=getAngularRate(this,k,ax)
      assert(this.ready);
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
