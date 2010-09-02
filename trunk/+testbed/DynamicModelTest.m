classdef DynamicModelTest
  properties (Constant=true)
    tau=0.5+0.5*sin(-pi/2:0.01:pi/2); % irregular time steps normalized in the range [0,1]
    infinity=1000; % (1000) replaces infinity as a time domain upper bound
  end
  
  properties (Access=private)
    dynamicModel
    nIL
    nIU
    nEL
    nEU
  end
  
  methods (Access=public)
    function this=DynamicModelTest(name,initialTime,uri)
      fprintf('\n\ninitialTime =');
      assert(isa(initialTime,'tom.WorldTime')); 
      fprintf(' %f',double(initialTime));

      fprintf('\nuri =');
      assert(isa(uri,'char'));
      fprintf(' ''%s''',uri);
      
      fprintf('\n\ntom.DynamicModel.description =');
      text=tom.DynamicModel.description(name);
      assert(isa(text,'char'));
      fprintf(' %s',text);

      fprintf('\n\ntom.DynamicModel.factory =');
      this.dynamicModel=tom.DynamicModel.factory(name,initialTime,uri);
      assert(isa(this.dynamicModel,'tom.DynamicModel'));
      fprintf(' ok');

      fprintf('\n\ndomain =');
      interval=this.dynamicModel.domain();
      assert(isa(interval,'tom.TimeInterval'));
      assert(interval.first==initialTime);
      fprintf(' ok');

      fprintf('\n\nnumInitialLogical =');
      this.nIL=this.dynamicModel.numInitialLogical();
      assert(isa(this.nIL,'uint32'));
      fprintf(' %d',this.nIL);

      fprintf('\nnumInitialUint32 =');
      this.nIU=this.dynamicModel.numInitialUint32();
      assert(isa(this.nIU,'uint32'));
      fprintf(' %d',this.nIU);  

      fprintf('\nnumExtensionLogical =');
      this.nEL=this.dynamicModel.numExtensionLogical();
      assert(isa(this.nEL,'uint32'));
      fprintf(' %d',this.nEL); 

      fprintf('\nnumExtensionUint32 =');
      this.nEU=this.dynamicModel.numExtensionUint32();
      assert(isa(this.nEU,'uint32'));
      fprintf(' %d',this.nEU);

      fprintf('\n\ngetInitialLogical = [');
      vIL=false(this.nIL,1);
      for p=uint32(1):this.nIL
        v=this.dynamicModel.getInitialLogical(p-uint32(1));
        assert(isa(v,'logical'));
        if(p~=uint32(1))
          fprintf(',');
        end
        fprintf('%d',v);
        vIL(p)=v;
      end
      fprintf(']');

      fprintf('\ngetInitialUint32 = [');
      vIU=zeros(this.nIU,1,'uint32');
      for p=uint32(1):this.nIU
        v=this.dynamicModel.getInitialUint32(p-uint32(1));
        assert(isa(v,'uint32'));
        if(p~=uint32(1))
          fprintf(',');
        end
        fprintf('%d',v);
        vIU(p)=v;
      end
      fprintf(']');
      
      DMTTrajectory(this);
      for b=uint32(0:2)
        fprintf('\nextend');
        this.dynamicModel.extend();
        
        fprintf('\nnumBlocks =');
        numBlocks=this.dynamicModel.numExtensionBlocks();
        assert(isa(numBlocks,'uint32'));
        fprintf(' %d',numBlocks);
        
        fprintf('\n\ngetExtensionLogical(%d) = [',b);
        vEL=false(this.nEL,1);
        for p=uint32(1):this.nEL
          v=this.dynamicModel.getExtensionLogical(b,p-uint32(1));
          assert(isa(v,'logical'));
          if(p~=uint32(1))
            fprintf(',');
          end
          fprintf('%d',v);
          vEL(p)=v;
        end
        fprintf(']');

        fprintf('\ngetExtensionUint32(%d) = [',b);
        vEU=zeros(this.nEU,1,'uint32');
        for p=uint32(1):this.nEU
          v=this.dynamicModel.getExtensionUint32(b,p-uint32(1));
          assert(isa(v,'uint32'));
          if(p~=uint32(1))
            fprintf(',');
          end
          fprintf('%d',v);
          vEU(p)=v;
        end
        fprintf(']');
        
        DMTTrajectory(this);
      end
    end
  end
  
  methods (Access=private)
    function DMTTrajectory(this)   
      interval=this.dynamicModel.domain();
      interval.display();
      
      time=tom.WorldTime(interval.first+this.tau*(min(interval.second,this.infinity)-interval.first));

      fprintf('\ntime = %f',double(time(1)));
      
      pose=this.dynamicModel.evaluate(time(1));
      assert(isa(pose,'tom.Pose'));
      pose.display(); 

      tangentPose=this.dynamicModel.tangent(time(1));
      assert(isa(tangentPose,'tom.TangentPose'));
      tangentPose.display();
      
      N=numel(time);
      p=zeros(3,N);
      q=zeros(4,N);
      r=zeros(3,N);
      s=zeros(4,N);
      for n=1:N
        pose=this.dynamicModel.evaluate(time(n));
        p(:,n)=pose.p;
        q(:,n)=pose.q;
        tangentPose=this.dynamicModel.tangent(time(n));
        r(:,n)=tangentPose.r;
        s(:,n)=tangentPose.s;
      end

      fprintf('\ntime = %f',double(time(end)));
      
      pose=this.dynamicModel.evaluate(time(end));
      assert(isa(pose,'tom.Pose'));
      pose.display(); 

      tangentPose=this.dynamicModel.tangent(time(end));
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
      
    end
  end
end
