classdef sensorstub < sensor
  properties
    cache=[];
  end
  methods
    function this=sensorstub
      fprintf('\n');
      fprintf('\n### sensorstub constructor ###');
    end
    function this=updatecache(this,data)
      this.cache=data;
    end
  end
end
