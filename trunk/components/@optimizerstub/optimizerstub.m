classdef optimizerstub < optimizer
  properties
    cache=[];
  end
  methods
    function this=optimizerstub
      fprintf('\n');
      fprintf('\n### optimizerstub constructor ###');
    end
    function this=updatecache(this,data)
      this.cache=data;
    end
  end
end
