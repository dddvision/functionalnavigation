function [this,H,v,w]=step(this,H,v,w)
[H,c]=evaluate(H,v,w);
fprintf('\n');
fprintf('\ncost summary:');
fprintf('\n%f',c);
fprintf('\n');
end
