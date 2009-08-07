% Gets data associated with a sensor event index

function data=getdata(g,k)
data=g.gray(:,:,find(g.index==k));
end