function varargout=ga_fitness_wrapper(varargin)

persistent H vsize wsize

if( nargin==2 )
  switch( varargin{1} )
    case 'put'
      H=varargin{2};
      v=varargin{3};
      w=varargin{4};      
      
      vsize=size(v,1);
      wsize=size(w,1);
      popsize=size(v,2);
      nvars=vsize+wsize;
      options=gaoptimset(M.gaoptions,'InitialPopulation',[v;w],'PopulationSize',popsize,'EliteCount',round(1+popsize/10));

      varargout={@ga_fitness_wrapper,nvars,[],[],[],[],[],[],[],options};
      
    case 'get'
      population=varargin{2};
      score=varargin{3};
      v=population(1:vsize,:);
      w=population(1+vsize+(1:wsize),:);
      c=1-score;
      varargout={H,v,w,c};
    otherwise
      error('unrecognized action');
  end
else
  vw=varargin{1};
  v=reshape(vw(1:vsize),[vsize,1]);
  w=reshape(vw(1+vsize+(1:wsize)),[wsize,1]);
  [H,c]=evaluate(H,v,w);
  varargout{1}=1-c;
end

end
