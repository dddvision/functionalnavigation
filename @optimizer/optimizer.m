% Constructs an optimizer object


% TODO: enable swappable optimization methods
function [M,v,w]=optimizer(H)

[v,w]=init(H);

%if( license('test','optimization_toolbox') )
if( 0 )
  M.optimizer='matlabga';
  M.options=gaoptimset('PopulationType','bitstring',...
    'Generations',1,...
    'StallTimeLimit',90,...
    'MigrationInterval',Inf,...
    'CrossoverFraction',0.5,...
    'CrossoverFcn',@crossovertwopoint,...
    'SelectionFcn',@selectionroulette,...
    'MutationFcn',{@mutationuniform,0.02});
else
  M.optimizer='none';
  M.options=[];
end

M=class(M,'optimizer');

end
