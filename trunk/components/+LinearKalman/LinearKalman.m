classdef LinearKalman < tom.Optimizer & LinearKalman.LinearKalmanConfig
  
  properties (GetAccess=private,SetAccess=private)
    isDefined
    dynamicModel
    measure
    state
    covariance
    cost
  end
  
  methods (Static=true,Access=public)
    function initialize(name)
      function text=componentDescription
        text=['Applies a linear Kalman filter algorithm to optimize over initial Uint32 parameters only. ',...
          'All logical parameters are set to false. ',...
          'Extension blocks are ignored. ',...
          'Only the last on-diagonal element of each measure is evaluated.'];
      end
      tom.Optimizer.connect(name,@componentDescription,@LinearKalman.LinearKalman);
    end
  end
 
  methods (Access=public)
    function this=LinearKalman()
      this=this@tom.Optimizer();
      this.isDefined=false;
    end
    
    function num=numInitialConditions(this)
      num=this.popSize;
    end
    
    function defineProblem(this,dynamicModel,measure,randomize)
      % check number of dynamic models
      assert(numel(dynamicModel)==this.popSize);
      
      % store handles to inputs
      this.dynamicModel=dynamicModel;
      this.measure=measure;
      
      % optionally randomize initial parameters
      if(randomize)
        nIU=this.dynamicModel(1).numInitialUint32();
        for k=1:numel(this.dynamicModel)
          this.state{k}=rand(nIU,1); % range is within the interval [0,1]
          this.putParam(k,state2param(this.state{k}));
        end
      end
      
      % compute initial distribution model (assuming non-zero prior uncertainty)
      for k=1:numel(this.dynamicModel)
        [jacobian,hessian]=this.computeSecondOrderModel(k,'initialCost');
        this.covariance{k}=hessian^(-1);
        this.cost(k)=sqrt(trace(this.covariance{k}));
      end
      
      % flag the problem as defined
      this.isDefined=true;
    end
    
    function refreshProblem(this)
      assert(this.isDefined);
      currentTime=tom.WorldTime(-Inf);
      [cBest,iBest]=min(this.cost);
      for m=1:numel(this.measure)
        this.measure{m}.refresh(this.dynamicModel(iBest));
        if(this.measure{m}.hasData())
          currentTime=tom.WorldTime(max(currentTime,this.measure{m}.getTime(this.measure{m}.last())));
        end
      end
      interval=this.dynamicModel(1).domain();
      while(interval.second<currentTime)
        for k=1:numel(this.dynamicModel)
          this.dynamicModel(k).extend();
        end
        interval=this.dynamicModel(1).domain();
      end
    end
    
    function num=numSolutions(this)
      num=uint32(numel(this.dynamicModel));
    end
    
    function xEst=getSolution(this,k)
      xEst=this.dynamicModel(k+1);
    end

    function cEst=getCost(this,k)
      cEst=this.cost(k+1);
    end
    
    function step(this)
      assert(this.isDefined);
      for k=1:numel(this.dynamicModel)
        % compute measurement distribution model
        [jacobian,hessian]=this.computeSecondOrderModel(k,'measurementCost');

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
        this.putParam(k,state2param(this.state{k}));
        this.cost(k)=sqrt(trace(this.covariance{k}));
      end
    end
  end
  
  methods (Access=private)
    % compute second order model of a cost function
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
    
    function y=initialCost(this,k,v)
      this.putParam(k,v);
      y=this.dynamicModel(k).computeInitialBlockCost();
    end
    
    function y=measurementCost(this,k,v)
      y=0;
      this.putParam(k,v);
      for m=1:numel(this.measure)
        gm=this.measure{m};
        if(gm.hasData())
          node=gm.last();
          edgeList=gm.findEdges(node,node,node,node); % zero or one edges
          if(~isempty(edgeList))
            yDiff=gm.computeEdgeCost(this.dynamicModel(k),edgeList);
            if(~isnan(yDiff))
              y=y+yDiff;
            end
          end
        end
      end
    end
    
    function putParam(this,k,v)
      for p=uint32(1):uint32(numel(v))
        this.dynamicModel(k).setInitialUint32(p-1,v(p));
      end
    end
  end
  
end

function v=state2param(x)
  scale=4294967295; % double(intmax('uint32'))
  v=uint32(round(x*scale))';
end
