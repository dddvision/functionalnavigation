% Return quaternion pose representation at several time instants


function qt=evalQuaternion(this,t)
pqt=eval(this,t);
qt=pqt(4:7,:);
return;
