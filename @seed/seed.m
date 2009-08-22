classdef seed
  methods (Access=protected)
    function this=seed
    end
  end
  methods (Abstract=true,Access=public)

    % Extract static parameters from the derived class
    %
    % OUTPUT
    % staticSeed = bitset of static parameters
    staticSeed=getStaticSeed(this);
    
    % Replace static parameters held by the derived class
    %
    % INPUT
    % newStaticSeed = bitset of static parameters
    %
    % NOTE
    % This operation will change the derived class behaviour
    this=setStaticSeed(this,newStaticSeed);
    
    % Extract a contiguous subset of dynamic parameters from the derived class
    %
    % INPUT
    % tmin = time lower bound
    % tmax = time upper bound
    %
    % OUTPUT
    % subSeed = bitset segment of dynamic parameters
    subSeed=getDynamicSubSeed(this,tmin,tmax);

    % Replace a contiguous subset of dynamic parameters held by the derived class
    % 
    % INPUT
    % newSubSeed = bitset segment of dynamic parameters to splice in
    % tmin = time lower bound
    % tmax = time upper bound
    % 
    % NOTE
    % This operation will change the derived class behaviour
    this=setDynamicSubSeed(this,newSubSeed,tmin,tmax);

  end
end
