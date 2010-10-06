classdef TrajectoryTest
  
  properties (Constant = true, GetAccess = private)
    tau = 0.5+0.5*sin(pi/2*(-1:1/100:1)); % irregular time steps normalized in the range [0,1]
    taup = 1.1.^(0:0.02:1); % irregular time steps in the range [1,1.1]
    infinity = 1000; % (1000) maximum span of time domain when the upper bound is infinite
  end
  
  methods (Access = private, Static = true)
    function handle = figureHandle
      persistent h
      if(isempty(h))
        h=figure;
        set(h,'Units','normalized','Position',[0,0,1,1]);
        set(h, 'Name', 'Trajectory history (blue) and prediction (red)');
      end
      handle = h;
    end        
  end
  
  methods (Access = public, Static = true)
    function this = TrajectoryTest(trajectory)   
      fprintf('\n\n*** Begin Trajectory Test ***\n');
      assert(isa(trajectory, 'tom.Trajectory'));
      
      interval = trajectory.domain();
      interval.display();
      
      time = tom.WorldTime(interval.first+this.tau*(min(interval.second, ...
        interval.first+this.infinity)-interval.first));
      timep = tom.WorldTime(interval.first+this.taup*(min(interval.second, ...
        interval.first+this.infinity)-interval.first));

      fprintf('\ntime = %f', double(time(1)));
      
      pose = trajectory.evaluate(time(1));
      assert(isa(pose, 'tom.Pose'));
      pose.display();
      assert(~any(isnan(pose.p)));
      assert(~any(isnan(pose.q)));

      tangentPose = trajectory.tangent(time(1));
      assert(isa(tangentPose, 'tom.TangentPose'));
      tangentPose.display();
      assert(~any(isnan(tangentPose.p)));
      assert(~any(isnan(tangentPose.q)));
      assert(~any(isnan(tangentPose.r)));
      assert(~any(isnan(tangentPose.s)));
      
      N = numel(time);
      p = zeros(3, N);
      q = zeros(4, N);
      r = zeros(3, N);
      s = zeros(4, N);
      for n = 1:N
        pose = trajectory.evaluate(time(n));
        p(:, n) = pose.p;
        q(:, n) = pose.q;
        tangentPose = trajectory.tangent(time(n));
        r(:, n) = tangentPose.r;
        s(:, n) = tangentPose.s;
      end

      fprintf('\ntime = %f', double(time(end)));
      
      pose = trajectory.evaluate(time(end));
      assert(isa(pose, 'tom.Pose'));
      pose.display();
      assert(~any(isnan(pose.p)));
      assert(~any(isnan(pose.q)));

      tangentPose = trajectory.tangent(time(end));
      assert(isa(tangentPose, 'tom.TangentPose'));
      tangentPose.display();
      assert(~any(isnan(tangentPose.p)));
      assert(~any(isnan(tangentPose.q)));
      assert(~any(isnan(tangentPose.r)));
      assert(~any(isnan(tangentPose.s)));
      
      Np = numel(timep);
      pp = zeros(3, Np);
      qp = zeros(4, Np);
      rp = zeros(3, Np);
      sp = zeros(4, Np);
      for n = 1:Np
        pose = trajectory.evaluate(timep(n));
        pp(:, n) = pose.p;
        qp(:, n) = pose.q;
        tangentPose = trajectory.tangent(timep(n));
        rp(:, n) = tangentPose.r;
        sp(:, n) = tangentPose.s;
      end
      
      fprintf('\ntime = %f', double(timep(end)));
      
      pose = trajectory.evaluate(timep(end));
      assert(isa(pose, 'tom.Pose'));
      pose.display();
      assert(~any(isnan(pose.p)));
      assert(~any(isnan(pose.q)));

      tangentPose = trajectory.tangent(timep(end));
      assert(isa(tangentPose, 'tom.TangentPose'));
      tangentPose.display();
      assert(~any(isnan(tangentPose.p)));
      assert(~any(isnan(tangentPose.q)));
      assert(~any(isnan(tangentPose.r)));
      assert(~any(isnan(tangentPose.s)));
      
      figure(this.figureHandle);
      for d = 1:3
        subplot(7, 2, 2*d-1);
        cla;
        plot(time, p(d,:), 'b');
        hold('on');
        plot(timep, pp(d, :), 'r');
        ylabel(sprintf('p_%d', d));
      end
      for d = 1:4
        subplot(7, 2, 5+2*d);
        cla;
        plot(time, q(d, :), 'b');
        hold('on');
        plot(timep, qp(d, :), 'r');
        ylabel(sprintf('q_%d', d));
      end
      for d = 1:3
        subplot(7, 2, 2*d);
        cla;
        plot(time, r(d, :), 'b');
        hold('on');
        plot(timep, rp(d, :), 'r');
        ylabel(sprintf('r_%d', d));
      end
      for d = 1:4
        subplot(7, 2, 6+2*d);
        cla;
        plot(time, s(d, :), 'b');
        hold('on');
        plot(timep, sp(d, :), 'r');
        ylabel(sprintf('s_%d', d));
      end
      drawnow;
      
      fprintf('\n*** End Trajectory Test ***');
    end
  end
  
end
