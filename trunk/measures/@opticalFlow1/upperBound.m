function costPotential=upperBound(this,tmin)

% arbitrarily select the first and last events
[ka,kb]=domain(this.u);

% get optical flow from cache
data=opticalFlow1_cache(this,ka,kb);
costPotential=data.costPotential;

end
