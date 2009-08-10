classdef trajectorystub < trajectory
  properties
    a
    b
    pose
  end
  methods
    function this=trajectorystub(v)
      fprintf('\n');
      fprintf('\n### trajectorystub constructor ###');
      if( nargin>0 )
        fprintf('\ndynamic seed = ');
        fprintf('%d',v);
        this.a=0;
        this.b=60;
        this.pose=[0;0;0;1;0;0;0];
      end
    end
  end  
end
