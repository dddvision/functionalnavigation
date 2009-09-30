classdef cameraSim1 < camera
  
  methods (Access=public)
    function this=cameraSim1
      global cameraSim1_singleton
      % TODO: consider alternatives to global hardware abstraction layer
      if( isempty(cameraSim1_singleton) )
        % REFERENCE
        % Middlebury College "Art" dataset
        % H. Hirschmuller and D. Scharstein. Evaluation of cost functions for 
        % stereo matching. In IEEE Computer Society Conference on Computer Vision 
        % and Pattern Recognition (CVPR 2007), Minneapolis, MN, June 2007.
        fps=3;
        ringsz=7;
        for k=1:ringsz
          cameraSim1_singleton.ring{k}.time=k/fps;
          cameraSim1_singleton.ring{k}.image=getMiddleburyArt(k-1);
        end
        cameraSim1_singleton.rho=1;
        cameraSim1_singleton.ringsz=uint32(ringsz);     
        cameraSim1_singleton.base=uint32(1);
        cameraSim1_singleton.a=uint32(3);
        cameraSim1_singleton.b=uint32(9);
        cameraSim1_singleton.size=size(cameraSim1_singleton.ring{1}.image);
      end
    end    
  end
  
end
