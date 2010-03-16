classdef opticalFlowOpenCV < opticalFlowOpenCV.opticalFlowOpenCVConfig & measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
  end
  
  methods (Access=public)
    function this=opticalFlowOpenCV(uri)
      this=this@measure(uri);
      fprintf('\n');
      fprintf('\nopticalFlowOpenCV::opticalFlowOpenCV');
      
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
        switch(scheme)
          case 'matlab'
            container=eval(resource(2:end));
            list=listSensors(container,'camera');
            this.sensor=getSensor(container,list(1));
          otherwise
            error('Unrecognized resource identifier in URI');
        end
      catch err
        error('Failed to open data resource: %s',err.message);
      end                  
    end
    
    function status=refresh(this)
      status=refresh(this.sensor);
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
      kaMin=max([first(this.sensor),kaMin,kbMin-uint32(1)]);
      kaMax=last(this.sensor)-1;
      if(isempty(kaMin)||isempty(kaMax))
        a=uint32([]);
        b=uint32([]);
      else
        a=kaMin:kaMax;
        b=a+uint32(1);
      end
    end
    
    function cost=computeEdgeCost(this,x,a,b)
      ka=first(this.sensor);
      kb=last(this.sensor);
      assert((b>a)&&(a>=ka)&&(b<=kb));
      
      ta=getTime(this.sensor,a);
      tb=getTime(this.sensor,b);
      
      [pa,qa]=evaluate(x,ta);
      [pb,qb]=evaluate(x,tb);  

      data=computeIntermediateDataCache(this,a,b);
      
      u=transpose(data.pixB(:,1)-data.pixA(:,1));
	    v=transpose(data.pixB(:,2)-data.pixA(:,2));
      
      Ea=Quat2Euler(qa);
      Eb=Quat2Euler(qb);
      
 	    translation=[pb(1)-pa(1);
                   pb(2)-pa(2);
                   pb(3)-pa(3)];
      rotation=[Eb(1)-Ea(1);
                Eb(2)-Ea(2);
                Eb(3)-Ea(3)];
      [uvr,uvt]=generateFlowSparse(this,translation,rotation,transpose(data.pixA));
           
      cost=computeCost(u,v,uvr,uvt);     
    end  
  end
  
end