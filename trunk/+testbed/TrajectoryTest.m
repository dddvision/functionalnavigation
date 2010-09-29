classdef TrajectoryTest
  
  properties (Constant=true)
    tau=0.5+0.5*sin(pi/2*(-1:1/100:1)); % irregular time steps normalized in the range [0,1]
    infinity=1000; % (1000) maximum span of time domain when the upper bound is infinite
  end
  
  methods (Access=public)
    function this=TrajectoryTest(trajectory)   
      fprintf('\n\n*** Begin Trajectory Test ***\n');
      assert(isa(trajectory,'tom.Trajectory'));
      
      interval=trajectory.domain();
      interval.display();
      
      time=tom.WorldTime(interval.first+this.tau*(min(interval.second,interval.first+this.infinity)-interval.first));

      fprintf('\ntime = %f',double(time(1)));
      
      pose=trajectory.evaluate(time(1));
      assert(isa(pose,'tom.Pose'));
      pose.display(); 

      tangentPose=trajectory.tangent(time(1));
      assert(isa(tangentPose,'tom.TangentPose'));
      tangentPose.display();
      
      N=numel(time);
      p=zeros(3,N);
      q=zeros(4,N);
      r=zeros(3,N);
      s=zeros(4,N);
      for n=1:N
        pose=trajectory.evaluate(time(n));
        p(:,n)=pose.p;
        q(:,n)=pose.q;
        tangentPose=trajectory.tangent(time(n));
        r(:,n)=tangentPose.r;
        s(:,n)=tangentPose.s;
      end

      fprintf('\ntime = %f',double(time(end)));
      
      pose=trajectory.evaluate(time(end));
      assert(isa(pose,'tom.Pose'));
      pose.display(); 

      tangentPose=trajectory.tangent(time(end));
      assert(isa(tangentPose,'tom.TangentPose'));
      tangentPose.display();
      
      figure(1);
      for d=1:3
        subplot(7,2,2*d-1);
        cla;
        plot(time,p(d,:));
        ylabel(sprintf('p_%d',d));
      end
      for d=1:4
        subplot(7,2,5+2*d);
        cla;
        plot(time,q(d,:));
        ylabel(sprintf('q_%d',d));
      end
      for d=1:3
        subplot(7,2,2*d);
        cla;
        plot(time,r(d,:));
        ylabel(sprintf('r_%d',d));
      end
      for d=1:4
        subplot(7,2,6+2*d);
        cla;
        plot(time,s(d,:));
        ylabel(sprintf('s_%d',d));
      end
      drawnow;
      
      fprintf('\n*** End Trajectory Test ***');
    end
  end
  
end
