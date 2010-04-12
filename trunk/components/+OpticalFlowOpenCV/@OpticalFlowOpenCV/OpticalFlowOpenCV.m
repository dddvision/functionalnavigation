classdef OpticalFlowOpenCV < OpticalFlowOpenCV.OpticalFlowOpenCVConfig & Measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
  end
  
  methods (Access=public)
    function this=OpticalFlowOpenCV(uri)
      this=this@Measure(uri);
      fprintf('\n');
      fprintf('\nOpticalFlowOpenCV::OpticalFlowOpenCV');
      
      if(~exist('mexOpticalFlowOpenCV','file'))
        fprintf('\nCompiling mex wrapper for OpenCV...');
        
        % Locate openCV libraries
        userPath=path;
        userWarnState=warning('off','all'); % see MATLAB Solution ID 1-5JUPSQ
        addpath(getenv('PATH'));
        warning(userWarnState);
        if(ispc)
          libdir=fileparts(which('cv200.lib'));
        elseif(ismac)
          libdir=fileparts(which('libcv.dylib'));
        else
          libdir=fileparts(which('libcv.so'));
        end
        path(userPath);
        
        % Compile and link against OpenCV libraries
        userDirectory=pwd;
        cd(fullfile(fileparts(mfilename('fullpath')),'private'));
        try
          if(ispc)
            mex('mexOpticalFlowOpenCV.cpp',['-L"',libdir,'"'],'-lcv200','-lcxcore200');
          elseif(ismac)
            mex('mexOpticalFlowOpenCV.cpp',['-L"',libdir,'"'],'-lcv','-lcxcore');
          else
            mex('mexOpticalFlowOpenCV.cpp',['-L"',libdir,'"'],'-lcv','-lcxcore');
          end
        catch err
          details=err.message;
          details=[details,' Failed to compile against local OpenCV libraries.'];
          details=[details,' Please see the Readme file distributed with OpenCV.'];
          details=[details,' The following files must be in the system path:'];
          if(ispc)
            details=[details,' cv200.lib cv200.dll cxcore200.lib cxcore200.dll'];
          elseif(ismac)
            details=[details,' libcv.dylib libcxcore.dylib'];           
          else
            details=[details,' libcv.so libcxcore.so'];
          end
          cd(userDirectory);
          error(details);
        end
        cd(userDirectory);
        fprintf('done');
      end
      
      try
        [scheme,resource]=strtok(uri,':');
        resource=resource(2:end);
        switch(scheme)
          case 'matlab'
            container=DataContainer.factory(resource);
            list=listSensors(container,'Camera');
            this.sensor=getSensor(container,list(1));
          otherwise
            error('Unrecognized resource identifier in URI');
        end
      catch err
        error('Failed to open data resource: %s',err.message);
      end                  
    end
    
    function refresh(this)
      refresh(this.sensor);
    end
    
    function flag=hasData(this)
      flag=hasData(this.sensor);
    end
    
    function ka=first(this)
      ka=first(this.sensor);
    end
    
    function ka=last(this)
      ka=last(this.sensor);
    end
    
    function time=getTime(this,k)
      time=getTime(this.sensor,k);
    end
    
    function [a,b]=findEdges(this,kaMin,kbMin)
      assert(isa(kaMin,'uint32'));
      assert(isa(kbMin,'uint32'));
      assert(numel(kaMin)==1);
      assert(numel(kbMin)==1);
      if(hasData(this.sensor))
        kaMin=max([first(this.sensor),kaMin,kbMin-uint32(1)]);
        kaMax=last(this.sensor)-uint32(1);
        a=kaMin:kaMax;
        b=a+uint32(1);
      else
        a=uint32([]);
        b=uint32([]);
      end
    end
    
    function cost=computeEdgeCost(this,x,a,b)
      assert(isa(x,'Trajectory'));
      assert(isa(a,'uint32'));
      assert(isa(b,'uint32'));
      assert(numel(x)==1);
      assert(numel(a)==1);
      assert(numel(b)==1);
      assert(hasData(this.sensor));
      ka=first(this.sensor);
      kb=last(this.sensor);
      assert((b>a)&&(a>=ka)&&(b<=kb));
      
      ta=getTime(this.sensor,a);
      tb=getTime(this.sensor,b);
      
      poseA=evaluate(x,ta);
      poseB=evaluate(x,tb);

      data=computeIntermediateDataCache(this,a,b);
      
      u=transpose(data.pixB(:,1)-data.pixA(:,1));
	    v=transpose(data.pixB(:,2)-data.pixA(:,2));
      
      Ea=Quat2Euler(poseA.q);
      Eb=Quat2Euler(poseB.q);
      
 	    translation=[poseB.p(1)-poseA.p(1);
                   poseB.p(2)-poseA.p(2);
                   poseB.p(3)-poseA.p(3)];
      rotation=[Eb(1)-Ea(1);
                Eb(2)-Ea(2);
                Eb(3)-Ea(3)];
      [uvr,uvt]=generateFlowSparse(this,translation,rotation,transpose(data.pixA));
           
      cost=computeCost(u,v,uvr,uvt);     
    end  
  end
  
end