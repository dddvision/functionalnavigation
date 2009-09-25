% Builds a tree of cache data indexed by pairs of indices
% This creates a single cache store for all objects of this type

function data=cameraOpticalFlow1_cache(this,ka,kb)

persistent cache

kastr=['a',num2str(ka,'%d')];
kbstr=['b',num2str(kb,'%d')];

if( isfield(cache,kastr) && isfield(cache.(kastr),kbstr) )
    data=cache.(kastr).(kbstr);
else
  % REFERENCE
  % Middlebury College "Art" dataset
  % H. Hirschmuller and D. Scharstein. Evaluation of cost functions for 
  % stereo matching. In IEEE Computer Society Conference on Computer Vision 
  % and Pattern Recognition (CVPR 2007), Minneapolis, MN, June 2007.

  % TODO: get data from sensor or simulator instead of indexing files
  iastr=num2str(find(this.index==ka,1)-1,'%d');
  ibstr=num2str(find(this.index==kb,1)-1,'%d');
  ia=rgb2gray(imread(['view',iastr,'.png']));
  ib=rgb2gray(imread(['view',ibstr,'.png']));

  [Vx_OF,Vy_OF]=computeOF(ia,ib);
  [FIELD_Y,FIELD_X]=size(Vx_OF);
  data.Vx_OF=Vx_OF;
  data.Vy_OF=Vy_OF;
  data.costPotential=(FIELD_X.*FIELD_Y.*2); % TODO: check this calculation
  cache.(kastr).(kbstr)=data;
end

end
