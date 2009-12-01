% Builds a tree of cache data indexed by pairs of indices
% This creates a single cache store shared among all instances
function data=opticalFlow1_cache(this,ka,kb)

persistent cache

kastr=['a',num2str(ka,'%d')];
kbstr=['b',num2str(kb,'%d')];

if( isfield(cache,kastr) && isfield(cache.(kastr),kbstr) )
    data=cache.(kastr).(kbstr);
else
  ia=getImage(this.sensor,ka);
  ib=getImage(this.sensor,kb);
  
  switch( interpretLayers(this.sensor) )
    case {'rgb','rgbi'}
      ia=rgb2gray(ia(:,:,1:3));
      ib=rgb2gray(ib(:,:,1:3));
    case {'hsv','hsvi'}
      ia=ia(:,:,3);
      ib=ib(:,:,3);
    otherwise
      % do nothing
  end
  
  [Vx_OF,Vy_OF]=computeOF(ia,ib);
  data.Vx_OF=Vx_OF;
  data.Vy_OF=Vy_OF;
  cache.(kastr).(kbstr)=data;
end

end
