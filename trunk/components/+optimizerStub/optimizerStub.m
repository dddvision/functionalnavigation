classdef optimizerStub < optimizerStub.optimizerStubConfig & optimizer
  
  properties (GetAccess=private,SetAccess=private)
    F
    g
    bits
    cost
    bitsPerBlock
    blocksPerSecond
    numLogical
    numUint32
  end
  
  methods (Access=public)
    function this=optimizerStub
      fprintf('\n');
      fprintf('\noptimizerStub::optimizerStub');
   end
    
    function initialCost=defineProblem(this,dynamicModelName,measureNames,dataURI)
      fprintf('\n');
      fprintf('\noptimizerStub::defineProblem');
      
      % initialize dynamic models
      description=eval([dynamicModelName,'.',dynamicModelName,'.getBlockDescription']);
      this.numLogical=description.numLogical;
      this.numUint32=description.numUint32;
      this.bitsPerBlock=this.numLogical+32*this.numUint32;
      this.blocksPerSecond=eval([dynamicModelName,'.',dynamicModelName,'.getUpdateRate']);
      this.bits=logical(rand(this.popSizeDefault,this.bitsPerBlock*this.numBlocks)>0.5);
      blocks=bits2blocks(this,this.bits);
      for k=1:this.popSizeDefault
        this.F{k}=unwrapComponent(dynamicModelName,this.referenceTime);
        appendBlocks(this.F{k},blocks{k});
      end
      
      % initialize measures
      for k=1:numel(measureNames)
        this.g{k}=unwrapComponent(measureNames{k},dataURI);
      end
      
      % determine initial costs
      objective('put',this);
      initialCost=feval(@objective,this.bits);
      this.cost=initialCost;
    end
    
    function step(this)
      fprintf('\n');
      fprintf('\noptimizerStub::step');
      bad=find(this.cost>1.1*min(this.cost));
      this.bits(bad,:)=logical(rand(numel(bad),size(this.bits,2))>0.5);
      putBits(this,this.bits);
    end
    
    function [xEst,cEst]=getResults(this)
      xEst=cat(1,this.F{:});
      cEst=this.cost;
    end
  end
  
  methods (Access=private)
    function putBits(this,bits)
      blocks=bits2blocks(this,bits);
      for k=1:this.popSizeDefault
        replaceBlocks(this.F{k},0:(numel(blocks{k})-1),blocks{k});
      end
    end
    
    function blocks=bits2blocks(this,bits)
      blocks=cell(this.popSizeDefault,1);
      for k=1:this.popSizeDefault
        blocks{k}=processIndividual(this,bits(k,:));
      end
    end
      
    function blocks=processIndividual(this,bits)
      blocks=struct('logical',{},'uint32',{});
      for b=1:this.numBlocks
        blocks(b)=processBlock(this,bits((b-1)*this.bitsPerBlock+(1:this.bitsPerBlock)));
      end
    end
    
    function block=processBlock(this,bits)
      block=struct('logical',bits(1:this.numLogical),...
                   'uint32',bits2ints(this,bits((this.numLogical+1):end)));
    end
    
    function ints=bits2ints(this,bits)
      bits=reshape(bits,[this.numUint32,32]);
      pow=(2.^(31:-1:0))';
      ints=uint32(sum(bits*pow,2));
    end
  end
end

% Configurable objective function
function varargout=objective(varargin)
  persistent this
  bits=varargin{1};
  if(~ischar(bits))
    numIndividuals=numel(this.F);
    numGraphs=numel(this.g);
    putBits(this,bits);
    cost=zeros(numIndividuals,1);
    for graph=1:numGraphs
      [a,b]=findEdges(this.g{graph});
      numEdges=numel(a);
      for individual=1:numIndividuals
        if( ~isempty(a) )
          for edge=1:numEdges
            cost(individual)=cost(individual)+computeEdgeCost(this.g{graph},this.F{individual},a(1),b(1));
          end
        end
      end
    end
    varargout{1}=cost;
  elseif(strcmp(bits,'put'))
    this=varargin{2};
  else
    error('incorrect argument list');
  end
end
