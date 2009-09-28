% Builds a tree of cache data indexed by pairs of indices
% This creates a single cache store for all objects of this type

function data=opticalFlow1_cache(this,ka,kb)

persistent cache

kastr=['a',num2str(ka,'%d')];
kbstr=['b',num2str(kb,'%d')];

if( isfield(cache,kastr) && isfield(cache.(kastr),kbstr) )
    data=cache.(kastr).(kbstr);
else
  ia=getGray(this.u,ka);
  ib=getGray(this.u,kb);  
  
  [Vx_OF,Vy_OF]=computeOF(ia,ib);
  [FIELD_Y,FIELD_X]=size(Vx_OF);
  data.Vx_OF=Vx_OF;
  data.Vy_OF=Vy_OF;
  data.costPotential=(FIELD_X.*FIELD_Y.*2); % TODO: check this calculation
  cache.(kastr).(kbstr)=data;
end

end
