classdef linearKalmanOptimizer < linearKalmanOptimizer.linearKalmanOptimizerConfig & optimizer
  
 properties (GetAccess=private,SetAccess=private)
    F
    g
    state
    covariance
    cost
    initialBlockDescription
    extensionBlockDescription
  end
  
  methods (Access=public)
    function this=linearKalmanOptimizer
      % do nothing
    end
    
    function initialCost=defineProblem(this,dynamicModelName,measureName,dataURI)
      % process dynamic model input description
      this.initialBlockDescription=eval([dynamicModelName,'.',dynamicModelName,'.getInitialBlockDescription']);
      this.extensionBlockDescription=eval([dynamicModelName,'.',dynamicModelName,'.getExtensionBlockDescription']);
      blocksPerSecond=eval([dynamicModelName,'.',dynamicModelName,'.getUpdateRate']);
      
      % warnings and error cases
      fprintf('\nWarning: The linear Kalman optimizer optimizes over the final on-diagonal measure only.');
      if((this.initialBlockDescription.numLogical>0)||(this.extensionBlockDescription.numLogical>0))
        fprintf('\nWarning: The linear Kalman optimizer sets all logical parameters to false.');
      end
      if(blocksPerSecond~=0)
        error('The linear Kalman optimizer does not yet handle dynamic models with nonzero update rates.');
      end
      
      % set initial state
      this.state=this.initialState;
      
      % initialize the measure (assuming a single measure)
      this.g=unwrapComponent(measureName{1},dataURI);
           
      % initialize the dynamic model
      initialBlock=state2initialBlock(this,this.state);
      this.F=unwrapComponent(dynamicModelName,dataURI,this.referenceTime,initialBlock);

      % extend dynamic model domain
      extensionBlocks=struct('logical',[],'uint32',[]);
      appendExtensionBlocks(this.F,extensionBlocks);
      
      % compute initial cost and covariance
      [unused,jacobian,hessian]=computePriorModel(this);
      this.covariance=hessian^(-1);
      this.cost=0.5*trace(this.covariance);
      initialCost=this.cost;
    end
    
    function step(this)      
      % update the sensor
      refresh(this.g);
      
      % compute measurement distribution model
      [unused,jacobian,hessian]=computeMeasureModel(this);
      
      % linear least squares update
      priorState=this.state;
      priorCovariance=this.covariance;
      I=eye(numel(priorState));
      partialGain=(priorCovariance^(-1)+hessian)^(-1);
      kalmanGain=partialGain*hessian;
      posteriorState=priorState-partialGain*jacobian;
      posteriorCovariance=(I-kalmanGain)*priorCovariance;
      
      % clamp state within valid range
      posteriorState(posteriorState<0)=0;
      posteriorState(posteriorState>1)=1;

      % set new state and covariance
      this.state=posteriorState;
      this.covariance=posteriorCovariance;

      % plot distributions
      if(this.plotDistributions)
        plotNormalDistributions(priorState,priorCovariance,posteriorState,posteriorCovariance,hessian,jacobian);
      end
        
      % compute current trajectory and approximate cost
      initialBlock=state2initialBlock(this,this.state);
      replaceInitialBlock(this.F,initialBlock);
      this.cost=0.5*trace(this.covariance);
    end
    
    function [xEst,cEst]=getResults(this)
      xEst=this.F;
      cEst=this.cost;
    end
  end
  
  methods (Access=private)
    % compute second order model of prior distribution
    function [cost,jacobian,hessian]=computePriorModel(this)
      scale=4294967295; % double(intmax('uint32'))
      h=floor(sqrt(scale)); % carefully chosen integer for discrete derivative
      xo=round(this.state*scale);
      xoMax=scale-h;
      xo(xo<h)=h;
      xo(xo>xoMax)=xoMax;
      ym=computeInitialBlockCost(this.F,param2initialBlock(this,uint32(xo-h)));
      cost=computeInitialBlockCost(this.F,param2initialBlock(this,uint32(xo)));
      yp=computeInitialBlockCost(this.F,param2initialBlock(this,uint32(xo+h)));
      sh=scale/h;
      jacobian=(yp-ym)*sh/2;
      hessian=(yp-2*cost+ym)*sh*sh;
    end
    
    % compute second order model of measurement distribution
    function [cost,jacobian,hessian]=computeMeasureModel(this)
      scale=4294967295; % double(intmax('uint32'))
      h=floor(sqrt(scale)); % carefully chosen integer for discrete derivative
      xo=round(this.state*scale);
      xoMax=scale-h;
      xo(xo<h)=h;
      xo(xo>xoMax)=xoMax; 
      node=last(this.g);
      replaceInitialBlock(this.F,param2initialBlock(this,xo-h));
      ym=computeEdgeCost(this.g,this.F,node,node);
      replaceInitialBlock(this.F,param2initialBlock(this,xo));
      cost=computeEdgeCost(this.g,this.F,node,node);
      replaceInitialBlock(this.F,param2initialBlock(this,xo+h));
      yp=computeEdgeCost(this.g,this.F,node,node);
      sh=scale/h;
      jacobian=(yp-ym)*sh/2;
      hessian=(yp-2*cost+ym)*sh*sh;
    end
    
    function block=param2initialBlock(this,param)
      block=struct('logical',false(1,this.initialBlockDescription.numLogical),'uint32',param);
    end

    function block=state2initialBlock(this,state)
      scale=4294967295; % double(intmax('uint32'))
      block=param2initialBlock(this,uint32(round(state*scale)));
    end  
  end
end

function plotNormalDistributions(muPrior,sigmaPrior,muPosterior,sigmaPosterior,hessian,jacobian)
  persistent hfigure x
  if(numel(muPrior)==1)
    if(isempty(hfigure))
      hfigure=figure;
      set(hfigure,'Color',[1,1,1]);
      set(hfigure,'Position',[650,0,400,300]);
      xlabel('parameter');
      ylabel('likelihood');
      hold('on');
      x=(0:0.001:1)';
    else
      figure(hfigure);
      cla;
    end
    muMeas=muPrior-hessian\jacobian;
    sigmaMeas=hessian^(-1);
    plotNormalDistribution(x,muPrior,sigmaPrior,'k--');
    plotNormalDistribution(x,muMeas,sigmaMeas,'r');
    plotNormalDistribution(x,muPosterior,sigmaPosterior,'k');
    legend({'prior','measurement','posterior'});
  end
end

function plotNormalDistribution(x,mu,sigma,varargin)
  dx=x-mu;
  px=1/((2*pi)^(numel(mu)/2)*sqrt(det(sigma)))*exp(-dx.*dx*sigma^(-1));
  plot(x,px,varargin{:});
end
