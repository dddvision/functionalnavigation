classdef objective
  properties
    popsize
    vbits
    wbits
    tmin
    tmax
    xclass
    gclass
  end
  methods
    function this=objective(config)
      this.popsize=10;
      this.vbits=30;
      this.wbits=8;
      this.tmin=0;
      this.tmax=1.5;
      this.xclass=config.trajectory;
      this.gclass=config.sensor;
    end
  end
end


