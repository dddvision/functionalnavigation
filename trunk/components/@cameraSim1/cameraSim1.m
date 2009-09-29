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
        cameraSim1_singleton.ring{1}.time=1.6;
        cameraSim1_singleton.ring{1}.image=file2rgb('view2.png');
        cameraSim1_singleton.ring{1}.rho=1;
        cameraSim1_singleton.ring{2}.time=1.2;
        cameraSim1_singleton.ring{2}.image=file2rgb('view0.png');
        cameraSim1_singleton.ring{2}.rho=1;
        cameraSim1_singleton.ring{3}.time=1.4;
        cameraSim1_singleton.ring{3}.image=file2rgb('view1.png');
        cameraSim1_singleton.ring{3}.rho=1;
        cameraSim1_singleton.ringsz=uint32(3);     
        cameraSim1_singleton.base=uint32(2);
        cameraSim1_singleton.a=uint32(3);
        cameraSim1_singleton.b=uint32(5);
        cameraSim1_singleton.size=size(cameraSim1_singleton.ring{1}.image);
      end
    end    
  end
  
end
