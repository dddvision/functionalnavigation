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
        cameraSim1_singleton.ring{1}.gray=file2gray('view2.png');
        cameraSim1_singleton.ring{1}.rho=100;
        cameraSim1_singleton.ring{2}.time=1.2;
        cameraSim1_singleton.ring{2}.gray=file2gray('view0.png');
        cameraSim1_singleton.ring{2}.rho=100;
        cameraSim1_singleton.ring{3}.time=1.4;
        cameraSim1_singleton.ring{3}.gray=file2gray('view1.png');
        cameraSim1_singleton.ring{3}.rho=100;
        cameraSim1_singleton.ringsz=3;     
        cameraSim1_singleton.base=2;
        cameraSim1_singleton.a=3;
        cameraSim1_singleton.b=5;
      end 
    end
  end
end
