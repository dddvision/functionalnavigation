% Return quaternion pose representation at several time instants


function qt=evaluateQuaternion(this,t)
pqt=evaluate(this,t);
qt=pqt(4:7,:);
return;
