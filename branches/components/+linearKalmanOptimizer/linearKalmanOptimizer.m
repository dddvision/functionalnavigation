classdef linearKalmanOptimizer < linearKalmanOptimizer.linearKalmanOptimizerConfig & optimizer
  
 properties (GetAccess=private,SetAccess=private)
    F
    g
    state
    Pinv
    cost
  end
  
  methods (Access=public)
    function this=linearKalmanOptimizer
      % do nothing
    end
    
    function initialCost=defineProblem(this,dynamicModelName,measureName,dataURI)      
      % set random initial state
      this.state=rand;
      
      % initialize the measure (assuming a single measure)
      this.g=unwrapComponent(measureName{1},dataURI);
           
      % initialize the dynamic model
      initialBlock=state2block(this.state);
      this.F=unwrapComponent(dynamicModelName,dataURI,this.referenceTime,initialBlock);

      % extend dynamic model domain
      extensionBlocks=struct('logical',[],'uint32',[]);
      appendExtensionBlocks(this.F,extensionBlocks);
      
      % compute initial cost and covariance
      [this.cost,pJacobian,this.Pinv]=computePriorModel(this);
      
      % set output
      initialCost=this.cost;
    end
    
    function step(this)
      global Phistory statehistory
      
      % update the sensor
      refresh(this.g);
      
      % compute measurement distribution model
      [mCost,mJacobian,Qinv]=computeMeasureModel(this);
  
      % update the state and covariance
      residual=inv(Qinv)*mJacobian;
      kalmanGain=inv(this.Pinv+Qinv)*Qinv;
      this.state=this.state-kalmanGain*residual;
      this.Pinv=inv((eye(1)-kalmanGain)*inv(this.Pinv));
      
      % clamp state within valid range
      this.state(this.state<0)=0;
      this.state(this.state>1)=1;

      statehistory=[statehistory,this.state];
      Phistory=[Phistory,inv(this.Pinv)];
      figure(2);
      plot(Phistory);
      figure(3)
      plot(statehistory);
      
      % compute current cost
      node=last(this.g);
      replaceInitialBlock(this.F,state2block(this.state));
      this.cost=computeInitialBlockCost(this.F,state2block(this.state))+computeEdgeCost(this.g,this.F,node,node);
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
      xo((xo-h)<0)=h;
      xo((xo+h)>1)=1-h;
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
      xo((xo-h)<0)=h;
      xo((xo+h)>1)=1-h;
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
