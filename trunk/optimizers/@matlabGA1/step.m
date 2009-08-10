function [M,H,v,w]=step(M,H,v,w)
problem=ga_fitness_wrapper('put',H,v,w);
[junk1,junk2,junk3,junk4,population,score]=ga(problem);
[H,v,w,c]=ga_fitness_wrapper('get',population,score);
fprintf('\n');
fprintf('\ncost summary:');
fprintf('\n%f',c);
fprintf('\n');
end
