classdef linearKalmanOptimizer < linearKalmanOptimizer.linearKalmanOptimizerConfig & optimizer
  
 properties (GetAccess=private,SetAccess=private)
    F
    g
    state
    cost
  end
  
  methods (Access=public)
    function this=linearKalmanOptimizer
      this.F=[];
      this.g=[];
      this.state=rand;
      this.cost=[];
    end
    
    function initialCost=defineProblem(this,dynamicModelName,measureName,dataURI)      
      % initialize the measure (assuming a single measure)
      this.g=unwrapComponent(measureName{1},dataURI);
           
      % initialize the dynamic model
      initialBlock=state2block(this.state);
      this.F=unwrapComponent(dynamicModelName,dataURI,this.referenceTime,initialBlock);

      % extend dynamic model domain
      extensionBlocks=struct('logical',[],'uint32',[]);
      appendExtensionBlocks(this.F,extensionBlocks);
      
      % compute initial cost
      node=last(this.g);
      initialCost=computeInitialBlockCost(this.F,initialBlock)+computeEdgeCost(this.g,this.F,node,node);
      this.cost=initialCost;
    end
    
    function step(this)
      % update the sensor
      refresh(this.g);
      
      % compute prior and measurement distribution models
      [pCost,pJacobian,pHessian]=computePriorModel(this);
      [mCost,mJacobian,mHessian]=computeMeasureModel(this);
    end
    
    function [xEst,cEst]=getResults(this)
      xEst=this.F;
      cEst=this.cost;
    end
  end
  
  methods (Access=private)
    % compute second order model of prior distribution
    function [cost,jacobian,hessian]=computePriorModel(this)
      h=1e-2;
      xo=this.state;
      ym=computeInitialBlockCost(this.F,state2block(xo-h));
      cost=computeInitialBlockCost(this.F,state2block(xo));
      yp=computeInitialBlockCost(this.F,state2block(xo+h));
      jacobian=(yp-ym)/(h+h);
      hessian=(yp-2*cost+ym)/(h*h);
    end
    
    % compute second order model of measurement distribution
    function [cost,jacobian,hessian]=computeMeasureModel(this)
      h=1e-2;
      xo=this.state;
      node=last(this.g);
      replaceInitialBlock(this.F,state2block(xo-h));
      ym=computeEdgeCost(this.g,this.F,node,node);
      replaceInitialBlock(this.F,state2block(xo));
      cost=computeEdgeCost(this.g,this.F,node,node);
      replaceInitialBlock(this.F,state2block(xo+h));
      yp=computeEdgeCost(this.g,this.F,node,node);
      jacobian=(yp-ym)/(h+h);
      hessian=(yp-2*cost+ym)/(h*h);
    end
  end
end

function block=state2block(state)
  scale=4294967295;
  block=struct('logical',[],'uint32',uint32(round(state*scale)));
end
