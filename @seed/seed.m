classdef seed
  methods (Access=protected)
    function this=seed
    end
  end
  methods (Abstract=true,Access=public)
    
    % Set the static seed of the derived class
    %
    % INPUT
    % newStaticSeed = bitset of static parameters
    %
    % NOTE
    % This operation may drastically change the derived class
    this=setStaticSeed(this,newStaticSeed);
    
    % Get the static seed of the derived class
    %
    % OUTPUT
    % staticSeed = bitset of static parameters
    staticSeed=getStaticSeed(this);
    
    % Get a portion of the dynamic seed of the derived class
    %
    % INPUT
    % tmin = time lower bound
    % tmax = time upper bound
    %
    % OUTPUT
    % subSeed = bitset segment of dynamic parameters
    subSeed=getDynamicSubSeed(this,tmin,tmax);

    % Set a portion of the dynamic seed of the derived class
    % 
    % INPUT
    % newSubSeed = bitset segment of dynamic parameters to splice in
    % tmin = time lower bound
    % tmax = time upper bound
    % 
    % NOTE
    % This operation may drastically change the derived class
    this=setDynamicSubSeed(this,newSubSeed,tmin,tmax);

  end
end
