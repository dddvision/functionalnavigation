classdef cameraOpticalFlow1 < sensor
  properties
    gray=gray_image_init;
    index=[3,4,5];
    time=[1.2,1.4,1.6];
    focal=100;  % TODO: derive focal length from sensor data
  end
    methods
    function this=cameraOpticalFlow1
      fprintf('\n');
      fprintf('\n### cameraOpticalFlow1 constructor ###');
    end
  end
end
