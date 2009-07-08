% Constructs an optimizer object


function m=optimizer()

m.popsize=10;
m.vbits=12;
m.wbits=8;

m=class(m,'optimizer');

return;
