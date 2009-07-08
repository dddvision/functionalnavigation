% Get time stamp associated with sensor event index


function time=gettime(g,k)
time=g.time(find(g.index==k));
return;
