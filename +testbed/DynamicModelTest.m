classdef DynamicModelTest
  
  methods (Access=public)
    function this=DynamicModelTest(name,initialTime,uri)
      fprintf('\n\n*** Begin DynamicModel Test ***\n');
      
      fprintf('\ninitialTime =');
      assert(isa(initialTime,'tom.WorldTime')); 
      fprintf(' %f',double(initialTime));

      fprintf('\nuri =');
      assert(isa(uri,'char'));
      fprintf(' ''%s''',uri);
      
      fprintf('\n\ntom.DynamicModel.description =');
      text=tom.DynamicModel.description(name);
      assert(isa(text,'char'));
      fprintf(' %s',text);

      fprintf('\n\ntom.DynamicModel.create =');
      dynamicModel=tom.DynamicModel.create(name,initialTime,uri);
      assert(isa(dynamicModel,'tom.DynamicModel'));
      fprintf(' ok');

      fprintf('\n\ndomain =');
      interval=dynamicModel.domain();
      assert(isa(interval,'tom.TimeInterval'));
      assert(interval.first==initialTime);
      fprintf(' ok');

      fprintf('\n\nnumInitialLogical =');
      nIL=dynamicModel.numInitialLogical();
      assert(isa(nIL,'uint32'));
      fprintf(' %d',nIL);

      fprintf('\nnumInitialUint32 =');
      nIU=dynamicModel.numInitialUint32();
      assert(isa(nIU,'uint32'));
      fprintf(' %d',nIU);  

      fprintf('\nnumExtensionLogical =');
      nEL=dynamicModel.numExtensionLogical();
      assert(isa(nEL,'uint32'));
      fprintf(' %d',nEL); 

      fprintf('\nnumExtensionUint32 =');
      nEU=dynamicModel.numExtensionUint32();
      assert(isa(nEU,'uint32'));
      fprintf(' %d',nEU);

      fprintf('\n\ngetInitialLogical = [');
      vIL=false(nIL,1);
      for p=uint32(1):nIL
        v=dynamicModel.getInitialLogical(p-uint32(1));
        assert(isa(v,'logical'));
        if(p~=uint32(1))
          fprintf(', ');
        end
        fprintf('%d',v);
        vIL(p)=v;
      end
      fprintf(']');

      fprintf('\ngetInitialUint32 = [');
      vIU=zeros(nIU,1,'uint32');
      for p=uint32(1):nIU
        v=dynamicModel.getInitialUint32(p-uint32(1));
        assert(isa(v,'uint32'));
        if(p~=uint32(1))
          fprintf(', ');
        end
        fprintf('%d',v);
        vIU(p)=v;
      end
      fprintf(']');
      
      testbed.TrajectoryTest(dynamicModel);
      
      for b=uint32(0:2)
        fprintf('\n\nextend');
        dynamicModel.extend();
        
        fprintf('\nnumBlocks =');
        numBlocks=dynamicModel.numExtensionBlocks();
        assert(isa(numBlocks,'uint32'));
        fprintf(' %d',numBlocks);
        
        fprintf('\n\ngetExtensionLogical(%d) = [',b);
        vEL=false(nEL,1);
        for p=uint32(1):nEL
          v=dynamicModel.getExtensionLogical(b,p-uint32(1));
          assert(isa(v,'logical'));
          if(p~=uint32(1))
            fprintf(',');
          end
          fprintf('%d',v);
          vEL(p)=v;
        end
        fprintf(']');

        fprintf('\ngetExtensionUint32(%d) = [',b);
        vEU=zeros(nEU,1,'uint32');
        for p=uint32(1):nEU
          v=dynamicModel.getExtensionUint32(b,p-uint32(1));
          assert(isa(v,'uint32'));
          if(p~=uint32(1))
            fprintf(',');
          end
          fprintf('%d',v);
          vEU(p)=v;
        end
        fprintf(']');
        
        testbed.TrajectoryTest(dynamicModel);
      end
      
      fprintf('\n\n*** End DynamicModel Test ***');
    end
  end

end
