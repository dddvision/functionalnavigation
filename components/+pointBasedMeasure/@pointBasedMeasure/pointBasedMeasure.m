classdef pointBasedMeasure < pointBasedMeasure.pointBasedMeasureConfig & measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
    diagonal
    ready
  end
  
  methods (Access=public)
    function this=pointBasedMeasure(uri)
      this=this@measure(uri);
      fprintf('\n');
      fprintf('\npointBasedMeasure::pointBasedMeasure');
      
      localDir=fileparts(mfilename('fullpath'));
      localDir=[localDir '\private'];
      
      % David Lowe's SIFT Code
      siftCode=this.siftCode;
      siftCodeRepository=this.siftCodeRepository;
      siftCodeAgreeToLicense=this.siftCodeAgreeToLicense;     
      localCache=fullfile(localDir,siftCode);
      if(~exist(localCache,'dir'))
      	fprintf('\n%s%s.zip',siftCodeRepository,siftCode);
        user_input=input('\nDo you agree to the license associated with the above URL (Y/N)? ','s');
        if(user_input=='Y'||user_input=='y')
          siftCodeAgreeToLicense=true;
        end
        if(siftCodeAgreeToLicense)
          zipName=[siftCode,'.zip'];
          localZip=[localDir,'\',zipName];
          url=[siftCodeRepository,zipName];
          fprintf('\ncaching: %s',url);
          urlwrite(url,localZip);
          fprintf('\nunzipping: %s',localZip);
          unzip(localZip,localDir);
          delete(localZip);  
          movefile(fullfile([localCache '\appendimages.m']), localDir);
          movefile(fullfile([localCache '\siftWin32.exe']), localDir);
          movefile(fullfile([localCache '\sift.m']), localDir);
          % Modifying sift.m to adapt to the framework
          %fid = fopen([localDir '\sift.m'],'wt');                  
          %while 1
		  %  tline = fgets(fid);
          %  if(strcmp(tline,'function [image, descriptors, locs] = sift(imageFile)'))
          %    fprintf(fid,'function [image, descriptors, locs] = sift(image)');
          %  end
          %  if(strcmp(tline,'image = imread(imageFile)'))
          %    fprintf(fid,'\%image = imread(imageFile)');
          %    break;
          %  end  
  		  %end	  
          %fclose(fid);
        end
      end
	  
      % Vincent's SFM Toolbox
      vincentToolbox=this.vincentToolbox;
      vincentToolboxRepository=this.vincentToolboxRepository;
      vincentToolboxAgreeToLicense=this.vincentToolboxAgreeToLicense;   
      localCache=fullfile(localDir,'sfm');
      if(~exist(localCache,'dir'))
      	fprintf('\n%s%s.zip',vincentToolboxRepository,vincentToolbox);
        user_input=input('\nDo you agree to the license associated with the above URL (Y/N)? ','s');
        if(user_input=='Y'||user_input=='y')
          vincentToolboxAgreeToLicense=true;
        end
        if(vincentToolboxAgreeToLicense)
          zipName=[vincentToolbox,'.zip'];
          localZip=[localDir,'\',zipName];
          url=[vincentToolboxRepository,zipName];
          fprintf('\ncaching: %s',url);
          urlwrite(url,localZip);
          fprintf('\nunzipping: %s',localZip);
          unzip(localZip,localDir);
          delete(localZip);                      
          movefile(fullfile([localDir '\linearAlgebra' '\skew.m']), localDir);
          movefile(fullfile([localDir '\linearAlgebra' '\rq.m']), localDir);
          movefile(fullfile([localDir '\external\sba\matlab' '\blas_win32.dll']), localDir);
          movefile(fullfile([localDir '\external\sba\matlab' '\lapack_win32.dll']), localDir);
          movefile(fullfile([localCache '\bundleAdjustment.m']), localDir);
          movefile(fullfile([localCache '\extractFromP.m']), localDir);
          movefile(fullfile([localCache '\private']), localDir);
        end
      end
      
      % Piotr's Image and Video Toolbox
      pdollarToolbox=this.pdollarToolbox;
      pdollarToolboxRepository=this.pdollarToolboxRepository;
      pdollarToolboxAgreeToLicense=this.pdollarToolboxAgreeToLicense;   
      localCache=fullfile(localDir,'toolbox');
      if(~exist(localCache,'dir'))
      	fprintf('\n%s%s.zip',pdollarToolboxRepository,pdollarToolbox);
        user_input=input('\nDo you agree to the license associated with the above URL (Y/N)? ','s');
        if(user_input=='Y'||user_input=='y')
          pdollarToolboxAgreeToLicense=true;
        end
        if(pdollarToolboxAgreeToLicense)
          zipName=[pdollarToolbox,'.zip'];
          localZip=[localDir,'\',zipName];
          url=[pdollarToolboxRepository,zipName];
          fprintf('\ncaching: %s',url);
          urlwrite(url,localZip);
          fprintf('\nunzipping: %s',localZip);
          unzip(localZip,localDir);
          delete(localZip);     
          movefile(fullfile([localCache '\matlab' '\getPrmDflt.m']), localDir);       
          movefile(fullfile([localCache '\matlab' '\rotationMatrix.m']), localDir);       
        end
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
      fprintf('\npointBasedMeasure::findEdges');
      a=[];
      b=[];      
      if(this.ready)
        ka=first(this.sensor);
        kb=last(this.sensor);
        if(kb>=ka)
          a=ka;
          b=kb;
        end
      end
    end
    
    function cost=computeEdgeCost(this,x,a,b)
      fprintf('\n');
      fprintf('\npointBasedMeasure::computeEdgeCost');
      assert(this.ready);
      
      ka=first(this.sensor);
      kb=last(this.sensor);
      assert((b>a)&&(a>=ka)&&(b<=kb));
      
      ta=getTime(this.sensor,a);
      tb=getTime(this.sensor,b);
      [pa,qa]=evaluate(x,ta);
      fprintf('\nx(%f) = < ',ta);
      fprintf('%f ',[pa;qa]);
      fprintf('>');
      [pb,qb]=evaluate(x,tb);      
      fprintf('\nx(%f) = < ',tb);
      fprintf('%f ',[pb;qb]);
      fprintf('>');
      
      im1=getImage(this.sensor,a); 
      im2=getImage(this.sensor,b); 
      if( strcmp(interpretLayers(this.sensor),'rgb') )
        im1=rgb2gray(im1); 
        im2=rgb2gray(im2); 
      end
            
      Ea=Quat2Euler(qa);
      Eb=Quat2Euler(qb);
      
      testTrajectory.Translation = [pb(1)-pa(1),pb(2)-pa(2),pb(3)-pa(3)];
      testTrajectory.Rotation = [Eb(1)-Ea(1),Eb(2)-Ea(2),Eb(3)-Ea(3)];
      
      cost = EvaluateTrajectory_SFM(im1,im2,testTrajectory);
      fprintf('\ncost = %f',cost);      
    end
  end

end