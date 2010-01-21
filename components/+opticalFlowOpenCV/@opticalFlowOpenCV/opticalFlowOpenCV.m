classdef opticalFlowOpenCV < opticalFlowOpenCV.opticalFlowOpenCVConfig & measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
    diagonal
    ready
  end
  
  methods (Access=public)
    function this=opticalFlowOpenCV(uri)
      this=this@measure(uri);
      fprintf('\n');
      fprintf('\nopticalFlowOpenCV::opticalFlowOpenCV');
      
      if(~exist('mexOpticalFlowOpenCV','file'))
        fprintf('\nCompiling mex wrapper for OpenCV...');
        savedir=cd;
        basedir=fileparts(mfilename('fullpath'));
        cd(fullfile(basedir,'private'));
        try
          if(ispc)
            libdir=fileparts(which('cv200.lib'));
            mex('mexOpticalFlowOpenCV.cpp',['-L"',libdir,'"'],'-lcv200','-lcxcore200');
          else
            mex('mexOpticalFlowOpenCV.cpp','-lcv','-lcxcore');
          end
        catch err
          details=err.message;
          details=[details,' Failed to compile against local OpenCV libraries.'];
          details=[details,' Please see the Readme file distributed with OpenCV.'];
          details=[details,' The following files must be in the Matlab and System paths:'];
          if(ispc)
            details=[details,' cv200.lib cv200.dll cxcore200.lib cxcore200.dll'];
          else
            details=[details,' libcv.so libcxcore.so'];
          end
          cd(savedir);
          error(details);
        end
        cd(savedir);
        fprintf('done');
      end
      	                     
      this.ready=false;
      [scheme,resource]=strtok(uri,':');
      switch(scheme)
        case 'matlab'
          container=eval(resource(2:end));
          list=listSensors(container,'camera');
          if(~isempty(list))
            this.sensor=getSensor(container,list(1));
            this.diagonal=false;
            this.ready=true;
          end
        otherwise
          error('failed to parse URI');
      end                  
    end
    
    function time=getTime(this,k)
      assert(this.ready);
      time=getTime(this.sensor,k);
    end
    
    function status=refresh(this)
      assert(this.ready);
      status=refresh(this.sensor);
    end
    
    function flag=isDiagonal(this)
      flag=this.diagonal;
    end
    
    function [a,b]=findEdges(this)
      fprintf('\n');
      fprintf('\nopticalFlowOpenCV::findEdges');
      a=[];
      b=[];      
      if(this.ready)
        ka=first(this.sensor);
        kb=last(this.sensor);
        if(kb>ka)
          a=ka:(kb-1);
          b=(ka+1):kb;
        end
        % HACK: limit this measure to 20 graph edges
        a=a(1:min(end,20));
        b=b(1:min(end,20));
      end
    end
    
    function cost=computeEdgeCost(this,x,a,b)
      fprintf('\n');
      fprintf('\nopticalFlowOpenCV::computeEdgeCost');
      assert(this.ready);
      
      ka=first(this.sensor);
      kb=last(this.sensor);
      assert((b>a)&&(a>=ka)&&(b<=kb));

      data=computeIntermediateDataCache(this,a,b);
      
      u=transpose(data.pixA(:,1)-data.pixB(:,1));
	    v=transpose(data.pixA(:,2)-data.pixB(:,2));
      
      ta=getTime(this.sensor,a);
      tb=getTime(this.sensor,b);
      
      [pa,qa]=evaluate(x,ta);
      [pb,qb]=evaluate(x,tb);      
            
      Ea=Quat2Euler(qa);
      Eb=Quat2Euler(qb);
      
 	    translation(1)=pb(1)-pa(1);
      translation(2)=pb(2)-pa(2);
      translation(3)=pb(3)-pa(3);
      rotation(1)=Eb(1)-Ea(1);
      rotation(2)=Eb(2)-Ea(2);
      rotation(3)=Eb(3)-Ea(3);
      [uvr,uvt]=generateFlowSparse(this,translation,rotation,data.pixA);
           
      cost=computeCost(u,v,uvr,uvt);
      fprintf('\ncost = %f',cost);      
    end  
  end
  
end