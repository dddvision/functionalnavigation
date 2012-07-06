classdef DynamicModelTest
  methods (Access = public)
    function this = DynamicModelTest(name, initialTime, uri)
      fprintf('\n\n*** Begin DynamicModel Test ***\n');
      
      fprintf('\ninitialTime =');
      assert(isa(initialTime, 'double')); 
      fprintf(' %f', double(initialTime));

      fprintf('\nuri =');
      assert(isa(uri, 'char'));
      fprintf(' ''%s''', uri);
      
      fprintf('\n\ntom.DynamicModel.description =');
      text = tom.DynamicModel.description(name);
      assert(isa(text, 'char'));
      fprintf(' %s', text);

      fprintf('\n\ntom.DynamicModel.create =');
      dynamicModel = tom.DynamicModel.create(name, initialTime, uri);
      assert(isa(dynamicModel, 'tom.DynamicModel'));
      fprintf(' ok');

      fprintf('\n\ndomain =');
      interval = dynamicModel.domain();
      assert(isa(interval, 'hidi.TimeInterval'));
      assert(interval.first==initialTime);
      fprintf(' ok');

      fprintf('\nnumInitial =');
      nIU = dynamicModel.numInitial();
      assert(isa(nIU, 'uint32'));
      fprintf(' %u', nIU);  

      fprintf('\nnumExtension =');
      nEU = dynamicModel.numExtension();
      assert(isa(nEU, 'uint32'));
      fprintf(' %u', nEU);

      fprintf('\ngetInitial = [');
      vIU = zeros(nIU, 1, 'uint32');
      for p = uint32(1):nIU
        v = dynamicModel.getInitial(p-uint32(1));
        assert(isa(v, 'uint32'));
        if(p~=uint32(1))
          fprintf(', ');
        end
        fprintf('%u', v);
        vIU(p) = v;
      end
      fprintf(']');
      
      tom.TrajectoryTest(dynamicModel);
      
      for b = uint32(0:2)
        fprintf('\n\nextend');
        dynamicModel.extend();
        
        fprintf('\nnumBlocks =');
        numBlocks = dynamicModel.numBlocks();
        assert(isa(numBlocks, 'uint32'));
        fprintf(' %u', numBlocks);

        fprintf('\ngetExtension(%u) = [', b);
        vEU = zeros(nEU, 1, 'uint32');
        for p = uint32(1):nEU
          v = dynamicModel.getExtension(b, p-uint32(1));
          assert(isa(v, 'uint32'));
          if(p~=uint32(1))
            fprintf(', ');
          end
          fprintf('%u', v);
          vEU(p) = v;
        end
        fprintf(']');
        
        tom.TrajectoryTest(dynamicModel);
      end
      
      for b = uint32(0:2)   
        fprintf('\nsetExtension(%u) = [', b);
        v = intmax('uint32');
        for p = uint32(1):nEU
          dynamicModel.setExtension(b, p-uint32(1), v);
          if(p~=uint32(1))
            fprintf(', ');
          end
          fprintf('%u', v);
        end
        fprintf(']');

        tom.TrajectoryTest(dynamicModel);
      end
      
      fprintf('\n\ncopy = ');
      interval = dynamicModel.domain();
      pose = dynamicModel.evaluate(interval.second);
      tangentPose = dynamicModel.tangent(interval.second);
      otherDynamicModel = dynamicModel.copy();
      otherInterval = otherDynamicModel.domain();
      otherPose = otherDynamicModel.evaluate(otherInterval.second);
      otherTangentPose = otherDynamicModel.tangent(otherInterval.second);      
      assert(otherInterval.first==interval.first);
      assert(otherInterval.second==interval.second);
      assert(all(otherPose.p==pose.p));
      assert(all(otherPose.q==pose.q));
      assert(all(otherTangentPose.p==tangentPose.p));
      assert(all(otherTangentPose.q==tangentPose.q));
      assert(all(otherTangentPose.r==tangentPose.r));
      assert(all(otherTangentPose.s==tangentPose.s));
      fprintf(' ok');
      
      fprintf('\n\n*** End DynamicModel Test ***');
    end
  end
end
