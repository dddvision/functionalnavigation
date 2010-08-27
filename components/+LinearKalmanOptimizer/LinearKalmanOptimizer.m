classdef LinearKalmanOptimizer < LinearKalmanOptimizer.LinearKalmanOptimizerConfig & Optimizer
  
  properties (GetAccess=private,SetAccess=private)
    dynamicModel
    measure
    state
    covariance
    cost
  end
  
  methods (Static=true,Access=protected)
    function initialize(name)
      function text=componentDescription
        text=['Applies a linear Kalman filter algorithm to optimize over initial Uint32 parameters only. ',...
          'All logical parameters are set to false. ',...
          'Extension blocks are ignored. ',...
          'Only the last on-diagonal element of each measure is evaluated after each refresh.'];
      end
      Optimizer.connect(name,@componentDescription,@LinearKalmanOptimizer.LinearKalmanOptimizer);
    end
  end
 
  methods (Access=public)
    function this=LinearKalmanOptimizer(dynamicModel,measure)
      this=this@Optimizer(dynamicModel,measure);
      
      % copy input arguments
      this.dynamicModel=dynamicModel;
      this.measure=measure;
      
      nIU=numInitialUint32(this.dynamicModel(1));
      for k=1:numel(this.dynamicModel)
        % set initial state (assuming its range is the interval [0,1])
        this.state{k}=rand(nIU,1);

        % compute prior distribution model (assuming non-zero prior uncertainty)
        [jacobian,hessian]=computeSecondOrderModel(this,k,'priorCost');
        this.covariance{k}=hessian^(-1);
        this.cost{k}=sqrt(trace(this.covariance{k}));
      end
        
      % incorporate first measurement (includes refresh)
      step(this);
    end
    
    function num=numResults(this)
      num=numel(this.dynamicModel);
    end
    
    function xEst=getTrajectory(this,k)
      xEst=this.dynamicModel(k+1);
    end

    function cEst=getCost(this,k)
      cEst=this.cost{k+1};
    end
    
    function step(this)      
      % refresh all measures
      for m=1:numel(this.measure)
        refresh(this.measure{m});
      end
      
      for k=1:numel(this.dynamicModel)
        % compute measurement distribution model
        [jacobian,hessian]=computeSecondOrderModel(this,k,'measurementCost');

        % get the prior state and covariance
        priorState=this.state{k};
        priorCovariance=this.covariance{k};

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
        this.state{k}=posteriorState;
        this.covariance{k}=posteriorCovariance;

        % compute current trajectory and approximate cost
        putParam(this,k,state2param(this.state{k}));
        this.cost{k}=sqrt(trace(this.covariance{k}));

        % optionally plot distributions
        if(this.plotDistributions)
          plotNormalDistributions(priorState,priorCovariance,posteriorState,posteriorCovariance,hessian,jacobian);
        end
      end
    end
  end
  
  methods (Access=private)
    % compute second order model of prior distribution
    function [jacobian,hessian]=computeSecondOrderModel(this,k,func)
      scale=4294967295; % double(intmax('uint32'))
      h=floor(sqrt(scale)); % carefully chosen integer for discrete derivative
      sh=scale/h;
      xo=round(this.state{k}*scale);
      xoMax=scale-h;
      xo(xo<h)=h;
      xo(xo>xoMax)=xoMax;
      D=numel(xo);
      hessian=zeros(D,D);
      jacobian=zeros(D,1);
      for d=1:D
        xm=xo;
        xp=xo;
        xm(d)=xm(d)-h;
        xp(d)=xp(d)+h;
        ym=feval(func,this,k,uint32(xm));
        yp=feval(func,this,k,uint32(xp));
        jacobian(d)=yp-ym;
        hessian(d,d)=yp+ym; % wait to subtract 2*yo
        for dd=(d+1):D
          xmm=xm;
          xmp=xm;
          xpm=xp;
          xpp=xp;
          xmm(dd)=xmm(dd)-h;
          xmp(dd)=xmp(dd)+h;
          xpm(dd)=xpm(dd)-h;
          xpp(dd)=xpp(dd)+h;
          ymm=feval(func,this,k,uint32(xmm));
          ymp=feval(func,this,k,uint32(xmp));
          ypm=feval(func,this,k,uint32(xpm));
          ypp=feval(func,this,k,uint32(xpp));
          hessian(d,dd)=(ypp-ypm-ymp+ymm)/4;
          hessian(dd,d)=hessian(d,dd);
        end
      end
      yo=feval(func,this,k,uint32(xo)); % evaluate xo last because dynamic model parameters are affected
      twoyo=2*yo;
      for d=1:D
        hessian(d,d)=hessian(d,d)-twoyo;
      end
      jacobian=jacobian*(sh/2);
      hessian=hessian*(sh*sh);
      hessian=real((hessian*hessian)^0.5); % improves numerical stability
    end
    
    function y=priorCost(this,k,v)
      putParam(this,k,v);
      y=computeInitialBlockCost(this.dynamicModel(k));
    end
    
    function y=measurementCost(this,k,v)
      y=0;
      putParam(this,k,v);
      for m=1:numel(this.measure)
        edgeList=findEdges(this.measure{m},this.dynamicModel(k),uint32(0),uint32(0)); % zero or one edges
        if(~isempty(edgeList))
          y=y+computeEdgeCost(this.measure{m},this.dynamicModel(k),edgeList);
        end
      end
    end
    
    function putParam(this,k,v)
      for p=uint32(1):uint32(numel(v))
        setInitialUint32(this.dynamicModel(k),p-1,v(p));
      end
    end
  end
  
end

function v=state2param(x)
  scale=4294967295; % double(intmax('uint32'))
  v=uint32(round(x*scale))';
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
