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
      % update the sensor
      refresh(this.g);
      
      % compute measurement distribution model
      [mCost,mJacobian,Qinv]=computeMeasureModel(this);
      
      % compute residual
      residual=inv(Qinv)*mJacobian;
      
      if(this.plotDistributions)
        dim=1;
        x=(-4:0.01:4)';
        dx=x-this.state;
        dxy=x-residual;
        px=(2*pi)^(-dim/2)*sqrt(this.Pinv)*exp(-dx.*dx*this.Pinv);
        pxy=(2*pi)^(-dim/2)*sqrt(Qinv)*exp(-dxy.*dxy*Qinv);
        figure(2);
        plot(x,px,'b');
        hold('on');
        plot(x,pxy,'r');
      end
  
      % update the state and covariance
      kalmanGain=inv(this.Pinv+Qinv)*Qinv;
      this.state=this.state-kalmanGain*residual;
      this.Pinv=inv((eye(1)-kalmanGain)*inv(this.Pinv));
      
      % clamp state within valid range
      this.state(this.state<0)=0;
      this.state(this.state>1)=1;

%       global Phistory statehistory
%       statehistory=[statehistory,this.state];
%       Phistory=[Phistory,inv(this.Pinv)];
%       figure(2);
%       plot(Phistory);
%       figure(3)
%       plot(statehistory);
      
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
      scale=4294967295; % double(intmax('uint32'))
      h=floor(sqrt(scale)); % carefully chosen integer for discrete derivative
      sh=scale/h;
      xo=round(this.state*scale);
      xoMax=scale-h;
      xo(xo<h)=h;
      xo(xo>xoMax)=xoMax;
      ym=computeInitialBlockCost(this.F,param2block(uint32(xo-h)));
      cost=computeInitialBlockCost(this.F,param2block(uint32(xo)));
      yp=computeInitialBlockCost(this.F,param2block(uint32(xo+h)));
      jacobian=(yp-ym)*(sh+sh);
      hessian=(yp-2*cost+ym)*sh*sh;
    end
    
    % compute second order model of measurement distribution
    function [cost,jacobian,hessian]=computeMeasureModel(this)
      scale=4294967295; % double(intmax('uint32'))
      h=floor(sqrt(scale)); % carefully chosen integer for discrete derivative
      sh=scale/h;
      xo=round(this.state*scale);
      xoMax=scale-h;
      xo(xo<h)=h;
      xo(xo>xoMax)=xoMax; 
      node=last(this.g);
      replaceInitialBlock(this.F,param2block(xo-h));
      ym=computeEdgeCost(this.g,this.F,node,node);
      replaceInitialBlock(this.F,param2block(xo));
      cost=computeEdgeCost(this.g,this.F,node,node);
      replaceInitialBlock(this.F,param2block(xo+h));
      yp=computeEdgeCost(this.g,this.F,node,node);
      jacobian=(yp-ym)*(sh+sh);
      hessian=(yp-2*cost+ym)*sh*sh;
    end
  end
end

function block=param2block(param)
  block=struct('logical',[],'uint32',param);
end

function block=state2block(state)
  scale=4294967295; % double(intmax('uint32'))
  block=param2block(uint32(round(state*scale)));
end
