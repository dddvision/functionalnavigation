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
      fprintf('\n\nDynamicModel.description =');
      text=DynamicModel.description(name);
      assert(isa(text,'char'));
      fprintf(' %s',text);

      fprintf('\n\nDynamicModel.factory =');
      this.dynamicModel=DynamicModel.factory(name,initialTime,uri);
      assert(isa(this.dynamicModel,'DynamicModel'));
      fprintf(' ok');

      fprintf('\n\ndomain =');
      interval=domain(this.dynamicModel);
      assert(isa(interval,'TimeInterval'));
      assert(interval.first==initialTime);
      fprintf(' ok');

      fprintf('\n\nnumInitialLogical =');
      this.nIL=numInitialLogical(this.dynamicModel);
      assert(isa(this.nIL,'uint32'));
      fprintf(' %d',this.nIL);

      fprintf('\nnumInitialUint32 =');
      this.nIU=numInitialUint32(this.dynamicModel);
      assert(isa(this.nIU,'uint32'));
      fprintf(' %d',this.nIU);  

      fprintf('\nnumExtensionLogical =');
      this.nEL=numExtensionLogical(this.dynamicModel);
      assert(isa(this.nEL,'uint32'));
      fprintf(' %d',this.nEL); 

      fprintf('\nnumExtensionUint32 =');
      this.nEU=numExtensionUint32(this.dynamicModel);
      assert(isa(this.nEU,'uint32'));
      fprintf(' %d',this.nEU);

      fprintf('\n\ngetInitialLogical = [');
      vIL=false(this.nIL,1);
      for p=uint32(1):this.nIL
        v=getInitialLogical(this.dynamicModel,p-uint32(1));
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
        v=getInitialUint32(this.dynamicModel,p-uint32(1));
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
        extend(this.dynamicModel);
        
        fprintf('\nnumBlocks =');
        numBlocks=numExtensionBlocks(this.dynamicModel);
        assert(isa(numBlocks,'uint32'));
        fprintf(' %d',numBlocks);
        
        fprintf('\n\ngetExtensionLogical(%d) = [',b);
        vEL=false(this.nEL,1);
        for p=uint32(1):this.nEL
          v=getExtensionLogical(this.dynamicModel,b,p-uint32(1));
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
          v=getExtensionUint32(this.dynamicModel,b,p-uint32(1));
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
      interval=domain(this.dynamicModel);
      display(interval);
      
      time=WorldTime(interval.first+this.tau*(min(interval.second,this.infinity)-interval.first));

      fprintf('\ntime = %f',double(time(1)));
      
      pose=evaluate(this.dynamicModel,time(1));
      assert(isa(pose,'Pose'));
      display(pose); 

      tangentPose=tangent(this.dynamicModel,time(1));
      assert(isa(tangentPose,'TangentPose'));
      display(tangentPose);
      
      N=numel(time);
      p=zeros(3,N);
      q=zeros(4,N);
      r=zeros(3,N);
      s=zeros(4,N);
      for n=1:N
        pose=evaluate(this.dynamicModel,time(n));
        p(:,n)=pose.p;
        q(:,n)=pose.q;
        tangentPose=tangent(this.dynamicModel,time(n));
        r(:,n)=tangentPose.r;
        s(:,n)=tangentPose.s;
      end

      fprintf('\ntime = %f',double(time(end)));
      
      pose=evaluate(this.dynamicModel,time(end));
      assert(isa(pose,'Pose'));
      display(pose); 

      tangentPose=tangent(this.dynamicModel,time(end));
      assert(isa(tangentPose,'TangentPose'));
      display(tangentPose);
      
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
