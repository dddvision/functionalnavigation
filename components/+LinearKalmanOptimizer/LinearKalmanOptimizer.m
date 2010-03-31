classdef LinearKalmanOptimizer < LinearKalmanOptimizer.LinearKalmanOptimizerConfig & Optimizer
  
 properties (GetAccess=private,SetAccess=private)
    F
    g
    state
    covariance
    cost
    initialBlockDescription
  end
  
  methods (Access=public)
    function this=LinearKalmanOptimizer(dynamicModelName,measureName,uri)
      this=this@Optimizer(dynamicModelName,measureName,uri);
      fprintf('\n\n%s',class(this));
      
      % display warning
      fprintf('\nWarning: This optimizer updates itself using only the last on-diagonal measure.');
      
      % handle dynamic model update rate
      updateRate=eval([dynamicModelName,'.',dynamicModelName,'.getUpdateRate']); 
      if(updateRate)
        error('This optimizer does not yet handle dynamic models with nonzero update rates.');
      end
      
      % handle dynamic model initial block description
      this.initialBlockDescription=eval([dynamicModelName,'.',dynamicModelName,'.getInitialBlockDescription']);
      if(this.initialBlockDescription.numLogical>0)
        fprintf('\nWarning: This optimizer sets all logical parameters to false.');
      end
      
      % set initial state (assuming its range is the interval [0,1])
      this.state=repmat(0.5,[this.initialBlockDescription.numUint32,1]);
      
      % initialize the measure (assuming a single measure)
      this.g=Measure.factory(measureName{1},uri);
           
      % initialize single instance of the dynamic model
      initialBlock=state2initialBlock(this,this.state);
      this.F=DynamicModel.factory(dynamicModelName,this.referenceTime,initialBlock,uri);
      
      % compute prior distribution model (assuming non-zero prior uncertainty)
      [jacobian,hessian]=computeSecondOrderModel(this,'priorCost');
      this.covariance=hessian^(-1);
      this.cost=sqrt(trace(this.covariance));
      
      % incorporate first measurement (includes refresh)
      step(this);
    end
    
    function [xEst,cEst]=getResults(this)
      xEst=this.F;
      cEst=this.cost;
    end
    
    function step(this)      
      % update the sensor
      refresh(this.g);
      
      % return if no data is available
      if(~hasData(this.g))
        return;
      end
      
      % compute measurement distribution model
      [jacobian,hessian]=computeSecondOrderModel(this,'measurementCost');
      
      % get the prior state and covariance
      priorState=this.state;
      priorCovariance=this.covariance;
      
      % linear least squares update
      I=eye(numel(priorState));
      partialGain=(priorCovariance^(-1)+hessian)^(-1);
      kalmanGain=partialGain*hessian;
      posteriorState=priorState-partialGain*jacobian;
      posteriorCovariance=(I-kalmanGain)*priorCovariance;
      
      % clamp state within valid range
      posteriorState(posteriorState<0)=0;
      posteriorState(posteriorState>1)=1;

      % set the posterior state and covariance
      this.state=posteriorState;
      this.covariance=posteriorCovariance;

      % compute current trajectory and approximate cost
      setInitialBlock(this.F,state2initialBlock(this,this.state));
      this.cost=sqrt(trace(this.covariance));
      
      % optionally plot distributions
      if(this.plotDistributions)
        plotNormalDistributions(priorState,priorCovariance,posteriorState,posteriorCovariance,hessian,jacobian);
      end
    end
  end
  
  methods (Access=private)
    % compute second order model of prior distribution
    function [jacobian,hessian]=computeSecondOrderModel(this,func)
      scale=4294967295; % double(intmax('uint32'))
      h=floor(sqrt(scale)); % carefully chosen integer for discrete derivative
      sh=scale/h;
      xo=round(this.state*scale);
      xoMax=scale-h;
      xo(xo<h)=h;
      xo(xo>xoMax)=xoMax;
      D=numel(xo);
      yo=feval(func,this,xo);
      jacobian=zeros(D,1);
      hessian=zeros(D,D);
      for d=1:D
        xm=xo;
        xp=xo;
        xm(d)=xm(d)-h;
        xp(d)=xp(d)+h;
        ym=feval(func,this,xm);
        yp=feval(func,this,xp);
        jacobian(d)=yp-ym;
        hessian(d,d)=yp-2*yo+ym;
        for dd=(d+1):D
          xmm=xm;
          xmp=xm;
          xpm=xp;
          xpp=xp;
          xmm(dd)=xmm(dd)-h;
          xmp(dd)=xmp(dd)+h;
          xpm(dd)=xpm(dd)-h;
          xpp(dd)=xpp(dd)+h;
          ymm=feval(func,this,xmm);
          ymp=feval(func,this,xmp);
          ypm=feval(func,this,xpm);
          ypp=feval(func,this,xpp);
          hessian(d,dd)=(ypp-ypm-ymp+ymm)/4;
          hessian(dd,d)=hessian(d,dd);
        end
      end
      jacobian=jacobian*(sh/2);
      hessian=hessian*(sh*sh);
      hessian=real((hessian*hessian)^0.5); % improves numerical stability
    end
    
    function y=priorCost(this,x)
      y=computeInitialBlockCost(this.F,param2initialBlock(this,uint32(x)));
    end
    
    function y=measurementCost(this,x)
      node=last(this.g);
      setInitialBlock(this.F,param2initialBlock(this,x));
      y=computeEdgeCost(this.g,this.F,node,node);
    end
      
    % INPUT
    % param = uint32 numUint32-by-1
    function block=param2initialBlock(this,param)
      block=struct('logical',false(1,this.initialBlockDescription.numLogical),'uint32',param');
    end

    % INPUT
    % state = double numUint32-by-1
    function block=state2initialBlock(this,state)
      scale=4294967295; % double(intmax('uint32'))
      block=param2initialBlock(this,uint32(round(state*scale)));
    end  
  end
end

function plotNormalDistributions(muPrior,sigmaPrior,muPosterior,sigmaPosterior,hessian,jacobian)
  persistent hfigure x
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
  plotNormalDistribution(x,muPrior(1),sigmaPrior(1,1),'k--');
  plotNormalDistribution(x,muMeas(1),sigmaMeas(1,1),'r');
  plotNormalDistribution(x,muPosterior(1),sigmaPosterior(1,1),'k');
  legend({'prior','measurement','posterior'});
end

function plotNormalDistribution(x,mu,sigma,varargin)
  dx=x-mu;
  px=1/((2*pi)^(numel(mu)/2)*sqrt(det(sigma)))*exp(-0.5*dx.*dx*sigma^(-1));
  plot(x,px,varargin{:});
end
