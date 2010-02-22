 classdef matlabGA1 < matlabGA1.matlabGA1Config & optimizer
  
  properties (GetAccess=private,SetAccess=private)
    F
    g
    bits
    cost
    bitsPerBlock
    blocksPerSecond
    numLogical
    numUint32
    defaultOptions
    stepGAhandle
  end
  
  methods (Access=public)
    function this=matlabGA1
      fprintf('\n');
      fprintf('\nmatlabGA1::matlabGA1');
      if(this.hasLicense)
        if(~license('test','gads_toolbox'))
          error('Requires license for GADS toolbox -- see matlabGA1 configuration options');
        end
        this.defaultOptions = gaoptimset;
        this.defaultOptions.PopulationType = 'bitstring';
        this.defaultOptions.PopInitRange = [0;1];
        this.defaultOptions.CrossoverFraction = this.crossoverFraction;
        this.defaultOptions.MigrationDirection = 'forward';
        this.defaultOptions.MigrationInterval = inf;
        this.defaultOptions.MigrationFraction = 0;
        this.defaultOptions.Generations = 1;
        this.defaultOptions.TimeLimit = inf;
        this.defaultOptions.FitnessLimit = -inf;
        this.defaultOptions.StallGenLimit = inf;
        this.defaultOptions.StallTimeLimit = inf;
        this.defaultOptions.TolFun = 0;
        this.defaultOptions.TolCon = 0;
        this.defaultOptions.CreationFcn = @gacreationuniform;
        this.defaultOptions.CreationFcnArgs = {};
        this.defaultOptions.FitnessScalingFcn = @fitscalingprop;
        this.defaultOptions.FitnessScalingFcnArgs = {};
        this.defaultOptions.SelectionFcn = @selectionstochunif;
        this.defaultOptions.SelectionFcnArgs = {};
        this.defaultOptions.CrossoverFcn = @crossoversinglepoint;
        this.defaultOptions.CrossoverFcnArgs = {};
        this.defaultOptions.MutationFcn = @mutationuniform;
        this.defaultOptions.MutationFcnArgs = {this.mutationRatio};
        this.defaultOptions.Vectorized = 'on';
        this.defaultOptions.LinearConstr.type = 'unconstrained';
        this.defaultOptions.PopulationSize=this.popSizeDefault;
        this.defaultOptions.EliteCount=1+floor(this.popSizeDefault/12);

        % workaround to access stepGA from the gads toolbox
        userPath=pwd;
        cd(fullfile(fileparts(which('ga')),'private'));
        temp=@stepGA;
        cd(userPath);
        this.stepGAhandle=temp;
      end  
    end
    
    function initialCost=defineProblem(this,dynamicModelName,measureNames,dataURI)
      % initialize dynamic models
      description=eval([dynamicModelName,'.',dynamicModelName,'.getBlockDescription']);
      this.numLogical=description.numLogical;
      this.numUint32=description.numUint32;
      this.bitsPerBlock=this.numLogical+32*this.numUint32;
      this.blocksPerSecond=eval([dynamicModelName,'.',dynamicModelName,'.getUpdateRate']);
      this.bits=logical(rand(this.popSizeDefault,this.bitsPerBlock*this.numBlocks)>0.5);
      blocks=bits2blocks(this,this.bits);
      for k=1:this.popSizeDefault
        this.F{k}=unwrapComponent(dynamicModelName,dataURI,this.referenceTime);
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
      if(this.hasLicense)
        nvars=size(this.bits,2);
        nullstate=struct('FunEval',0);
        [this.cost,this.bits]=feval(this.stepGAhandle,this.cost,this.bits,this.defaultOptions,nullstate,nvars,@objective);
        putBits(this,this.bits);
      else
        bad=find(this.cost>1.1*min(this.cost));
        this.bits(bad,:)=logical(rand(numel(bad),size(this.bits,2))>0.5);
        putBits(this,this.bits);
      end
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

% Objective function that stores an objective object instance
function varargout=objective(varargin)
  persistent this
  bits=varargin{1};
  if(~ischar(bits))
    numIndividuals=numel(this.F);
    numGraphs=numel(this.g);
    putBits(this,bits);
    cost=zeros(numIndividuals,1);
    for graph=1:numGraphs
      [a,b]=findEdges(this.g{graph},uint32(0),last(this.g{graph})-this.dMax);
      numEdges=numel(a);
      for individual=1:numIndividuals
        if( ~isempty(a) )
          for edge=1:numEdges
            cost(individual)=cost(individual)+computeEdgeCost(this.g{graph},this.F{individual},a(edge),b(edge));
          end
        end
      end
    end
    varargout{1}=cost/numEdges;
  elseif(strcmp(bits,'put'))
    this=varargin{2};
  elseif(strcmp(bits,'get'))
    varargout{1}=this;
  else
    error('incorrect argument list');
  end
end
