classdef PointBasedMeasure < PointBasedMeasure.PointBasedMeasureConfig & tom.Measure
  
  properties (SetAccess=private,GetAccess=public)
    sensor
  end
  
  methods (Static=true,Access=public)
    function initialize(name)
      function text=componentDescription
        text=['Visual measure that employs the five-point algorithm. ',...
          'In a calibrated framework, the algorithm first finds SURF point correspondence ',...
          'between two images of a scene and then uses the five point algorithm to find ',...
          'the essential matrix. Consequently the essential matrix is decomposed to ',...
          'obtain the camera rotation and translation. The camera pose is then employed ',...
          'to triangulate the point correspondences in order to obtain the 3D structure ',...
          'of the scene. This measure is not defined when the camera translation is small ',...
          'or when the features are nearly aligned in a plane. Requires OpenCV, SBA, and LAPACK.'];
      end
      tom.Measure.connect(name,@componentDescription,@PointBasedMeasure.PointBasedMeasure);
    end
  end
    
  methods (Access=public)
    function this=PointBasedMeasure(initialTime, uri)
      this=this@tom.Measure(initialTime, uri);
                
      if(~exist([fileparts(mfilename('fullpath')),filesep,'private',filesep,'MEXSURF.',mexext],'file')&&PointBasedMeasure.PointBasedMeasureConfig.MatchingAlgo==1)
        fprintf('\nPointBasedMeasure::Mexing SURF....');
        userPath = path;            
        if(ispc)
          libdir=fileparts(which('cv110.lib'));
        elseif(ismac)
          libdir=fileparts(which('libcv.dylib'));
        else
          libdir=fileparts(which('libcv.so'));
        end
        path(userPath);
        userDirectory = pwd;
        cd([fullfile(fileparts(mfilename('fullpath'))),filesep,'private']);  
        try
          if(ispc)    
            mex('MEXSURF.cpp',['-L"',libdir,'"'],'-lcv110','-lcxcore110', '-lhighgui110', '-lcvaux110');
          elseif(ismac)
            mex('MEXSURF.cpp',['-L"',libdir,'"'],'-lcv','-lcxcore', '-lhighgui', '-lcvaux');
          else
            mex('MEXSURF.cpp',['-L"',libdir,'"'],'-lcv','-lcxcore', '-lhighgui', '-lcvaux');
          end
        catch err
          cd(userDirectory);
          error(err.message);
        end
        cd(userDirectory);     
        fprintf('Done\n');
      end     
      % SBA 1.6
%       if(~exist([fileparts(mfilename('fullpath')),'sba.',mexext],'file'))
%             fprintf('\nPointBasedMeasure::Mexing SBA....');
%             userPath = path;                
%             if(ispc)
%               libdir=fileparts(which('blas.lib'));
%             elseif(ismac)
%               libdir=fileparts(which('blas.dylib'));
%             else
%               libdir=fileparts(which('blas.so'));
%             end
%             path(userPath);
%             userDirectory = pwd;
%             cd([fullfile(fileparts(mfilename('fullpath'))) filesep  'private'] );   
%             libdir
%             try
%                 mex('sba.c',  ['-L"',libdir, '"'], '-lsba', '-lblas', '-llapack', '-lf2c', '-ltmglib','-largeArrayDims');
%             catch err
%                details =['mex fail' err.message];
%                cd(userDirectory);
%                error(details);
%             end
%             cd(userDirectory);              
%       end     
                  
      try
        [scheme,resource]=strtok(uri,':');
        resource=resource(2:end);
        switch(scheme)
          case 'antbed'
            container=antbed.DataContainer.create(resource, initialTime);
            list=listSensors(container,'antbed.Camera');
            this.sensor=getSensor(container,list(1));
          otherwise
            error('Unrecognized resource identifier in URI');
        end
      catch err
        error('Failed to open data resource: %s',err.message);
      end                     
    end
        
    function refresh(this,x)
      assert(isa(x,'tom.Trajectory'));      
      refresh(this.sensor,x);
    end
    
    function flag=hasData(this)
      flag=hasData(this.sensor);
    end
    
    function ka=first(this)
      ka=first(this.sensor);
    end
    
    function kb=last(this)
      kb=last(this.sensor);
    end
    
    function time=getTime(this,k)
      time=getTime(this.sensor,k);
    end
        
    % 
    function edgeList=findEdges(this, naMin, naMax, nbMin, nbMax)
      if(this.DisplayTestTrajectory)
        fprintf('\nPointBasedMeasure::findEdges\n');
      end
      currentLast = -1;
      firstRun = 1;
      while firstRun == 1 || currentLast < this.sensor.last()
        firstRun = 0;
        currentLast = 1+currentLast;
        refresh(this.sensor,antbed.TrajectoryPerturbation([0,0,0],antbed.getCurrentTime()));   %tom.DynamicModel.create('XDynamics',antbed.getCurrentTime(),'antbed:MiddleburyData'));
      end
      edgeList = repmat(tom.GraphEdge, [0, 1]);
      if(hasData(this.sensor))
        nMin = max([naMin, this.sensor.first(), nbMin-uint32(1)]);
        nMax = min([naMax+uint32(1), this.sensor.last(), nbMax]);
        if(this.DisplayTestTrajectory)
            fprintf('graph range: %d - %d',nMin,nMax);
        end
        if nMax - nMin > 15
            fprintf('\nWarning: you may want to consider evaluating a smaller portions of the graph,\n         this measure evaluates all image pairs and as a result may inpact preformance.');
        end
        if(nMax > nMin)
            nList = nMin:nMax;
            [nb, na] = ndgrid(nList, nList);
            keep = nb(:) > na(:);  

            for ka = nMin:(nMax-uint32(1))
              for kb = (ka+uint32(1):nMax)
                fprintf('\n[%d,%d]: Testing...', ka, kb);
                use = false;
                try
                  use = computeIntermediateDataCache(this, ka, kb);
                catch err
                  fprintf('%s',err.message);
                end
                if(use)
                  if(this.DisplayTestTrajectory)
                    fprintf('.Used');  
                  end
                else
                  keep(ka*(nMax-nMin+uint32(1))+kb) = false;
                  if(this.DisplayTestTrajectory)
                    fprintf('.Thrown Out');   
                  end
                end
              end
            end
            na = na(keep);
            nb = nb(keep);
            if(~isempty(na))
              edgeList = tom.GraphEdge(na, nb);
            end
        end          
      end
    end
    
    function cost=computeEdgeCost(this,x,edge)        
      if(this.DisplayTestTrajectory)
        fprintf('\nPointBasedMeasure::computeEdgeCost\n');
      end
      
      assert(numel(x)==1);
      assert(numel(edge)==1);
      assert(hasData(this.sensor));      
      ka=first(this.sensor);
      kb=last(this.sensor);
      a=edge.first;
      b=edge.second;
      
%      fprintf('\n a = %d, b = %d, ka = %d, kb = %d \n',a,b,ka,kb);
      
      assert((b>a)&&(a>=ka)&&(b<=kb));
            
      ta=getTime(this.sensor,a);
      tb=getTime(this.sensor,b);
      
      poseA=evaluate(x,ta);
      poseB=evaluate(x,tb);      
          
                  
      Ea=tom.Rotation.quatToEuler(poseA.q);
      Eb=tom.Rotation.quatToEuler(poseB.q);
      
      testTrajectory.Translation = [poseB.p(1)-poseA.p(1);
                                    poseB.p(2)-poseA.p(2);
                                    poseB.p(3)-poseA.p(3)];
      testTrajectory.Rotation = [Eb(1)-Ea(1),Eb(2)-Ea(2),Eb(3)-Ea(3)];
      
      if(this.DisplayTestTrajectory)
          fprintf('\n   PoseA(%d) = < ',a);
          fprintf('%f ',poseA.p);
          fprintf('>');     
          fprintf('   PoseB(%d) = < ',b);
          fprintf('%f ',poseB.p);
          fprintf('>');
          fprintf('\ntranslation(%d:%d) = < ',b,a);
          fprintf('%f ',testTrajectory.Translation);
          fprintf('>');      
      end  
      
      data = computeDataCache(this,a,b);

      cost = ComputeCost(data, testTrajectory, this.ErrorType, this.DisplayTestTrajectory);
    end
  end

end
