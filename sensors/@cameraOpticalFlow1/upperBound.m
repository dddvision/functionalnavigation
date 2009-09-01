function costPotential=upperBound(this,tmin)

% get sensor event indices
[ka,kb]=domain(this);
k=ka:kb;

% identify sensor events within time domain bounds
t=gettime(this,k);
inside=find(t>=tmin);

% check whether at least two events occurred
if( numel(inside)<2 )
  costPotential=0;
  return;
end

% arbitrarily select the first and last events
k=k(inside);
ka=k(1);
kb=k(end);

% get optical flow from cache
data=cameraOpticalFlow1_cache(this,ka,kb);
costPotential=data.costPotential;

end
