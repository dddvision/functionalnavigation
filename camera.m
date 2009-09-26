classdef camera < sensor

  methods (Access=public)
    function this=camera
      global HAL
      % TODO: consider alternatives to global hardware abstraction layer
      if( ~isfield(HAL,'camera') )
        % REFERENCE
        % Middlebury College "Art" dataset
        % H. Hirschmuller and D. Scharstein. Evaluation of cost functions for 
        % stereo matching. In IEEE Computer Society Conference on Computer Vision 
        % and Pattern Recognition (CVPR 2007), Minneapolis, MN, June 2007.
        HAL.camera.ring{1}.time=1.6;
        HAL.camera.ring{1}.gray=rgb2gray(imread('view2.png'));
        HAL.camera.ring{2}.time=1.2;
        HAL.camera.ring{2}.gray=rgb2gray(imread('view0.png'));
        HAL.camera.ring{3}.time=1.4;
        HAL.camera.ring{3}.gray=rgb2gray(imread('view1.png'));
        HAL.camera.ringsz=3;     
        HAL.camera.base=2;
        HAL.camera.a=3;
        HAL.camera.b=5;
      end
      
    end
  end
  
  methods (Access=public,Abstract=false)
    function gray=getgray(this,k)
      global HAL
      if( (k<HAL.camera.a)||(k>HAL.camera.b) )
        gray=NaN;
      else
        gray=HAL.camera.ring{ktor(this,k)}.gray;
      end
    end
  
    function [a,b]=domain(this)
      global HAL
      a=HAL.camera.a;
      b=HAL.camera.b;
    end
     
    function time=gettime(this,k)
      global HAL
      if(numel(k)~=1)
        error('only scalar queries are supported');
      end
      time=HAL.camera.ring{ktor(this,k)}.time;
    end
  end
  
  methods (Access=private,Abstract=false)
    function r=ktor(this,k)
      global HAL
      r=mod(HAL.camera.base+k-HAL.camera.a-1,HAL.camera.ringsz)+1;
    end
  end  
  
end
