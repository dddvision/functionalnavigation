% Return trajectory position components at several time instants


function pt=evalPosition(this,t)
pqt=eval(this,t);
pt=pqt(1:3,:);
return;