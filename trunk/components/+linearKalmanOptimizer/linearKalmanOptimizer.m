classdef linearKalmanOptimizer < linearKalmanOptimizer.linearKalmanOptimizerConfig & optimizer
  
 properties (GetAccess=private,SetAccess=private)
    F
    g
    state
    Pinv
    cost
    hfigure
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
      
      % set initial state in the middle of its range
      this.state=0.5;
      
      % initialize the measure (assuming a single measure)
      this.g=unwrapComponent(measureName{1},dataURI);
           
      % initialize the dynamic model
      initialBlock=state2initialBlock(this,this.state);
      this.F=unwrapComponent(dynamicModelName,dataURI,this.referenceTime,initialBlock);

      % extend dynamic model domain
      extensionBlocks=struct('logical',[],'uint32',[]);
      appendExtensionBlocks(this.F,extensionBlocks);
      
      % compute initial cost and covariance
      [this.cost,jacobian,this.Pinv]=computePriorModel(this);
      
      % set output
      initialCost=this.cost;
    end
    
    function step(this)      
      % update the sensor
      refresh(this.g);
      
      % compute measurement distribution model
      [partialCost,jacobian,Qinv]=computeMeasureModel(this);
      
      % compute residual
      residual=Qinv\jacobian; % A\B=inv(A)*B
      
      % plot prior distributions
      if(this.plotDistributions)
        if(isempty(this.hfigure))
          this.hfigure=figure;
        end
        figure(this.hfigure);
        plotNormal(this.state,this.Pinv,'k--');
        hold('on');
        plotNormal(this.state-residual,Qinv,'m');
      end
  
      % update the state and covariance
      kalmanGain=(this.Pinv+Qinv)\Qinv; % A\B=inv(A)*B
      this.state=this.state-kalmanGain*residual;
      this.Pinv=inv((eye(1)-kalmanGain)/this.Pinv);
      
      % clamp state within valid range
      this.state(this.state<0)=0;
      this.state(this.state>1)=1;

      % plot posterior distribution
      if(this.plotDistributions)
        plotNormal(this.state,this.Pinv,'k');
        legend({'prior','measurement','posterior'});
        xlabel('parameter');
        ylabel('likelihood');
        hold('off');
      end
         
      % compute current trajectory and cost
      initialBlock=state2initialBlock(this,this.state);
      replaceInitialBlock(this.F,initialBlock);
      this.cost=computeInitialBlockCost(this.F,initialBlock);
      for node=first(this.g):last(this.g)
        this.cost=this.cost+computeEdgeCost(this.g,this.F,node,node);
      end
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

function plotNormal(mu,sigmaInverse,varargin)
  dim=1;
  x=(0:0.001:1)';
  dx=x-mu;
  px=(2*pi)^(-dim/2)*sqrt(sigmaInverse)*exp(-dx.*dx*sigmaInverse);
  plot(x,px,varargin{:});
end
