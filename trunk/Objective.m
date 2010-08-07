classdef Objective < handle
  
  properties (Constant=true,GetAccess=private)
    clockBase=[1980,1,6,0,0,0];
  end
  
  properties (GetAccess=public,SetAccess=private)
    input
    measure
  end
  
  methods (Access=public)
    function this=Objective(dynamicModelName,measureNames,uri,numInputs)
      assert(isa(dynamicModelName,'char'));
      assert(isa(measureNames,'cell'));
      assert(isa(uri,'char'));
      assert(numInputs>=1);
      
      % initialize multiple measures
      M=numel(measureNames);
      for m=1:M
        this.measure{m}=Measure.factory(measureNames{m},uri);
      end
      if(M>0)
        ta=Inf;
        while(isinf(ta))
          for m=1:M
            gm=this.measure{m};
            refresh(gm);
            if(hasData(gm))
              ta=min(ta,getTime(gm,first(gm)));
            end
          end
        end
        ta=WorldTime(ta);
      else
        ta=WorldTime(etime(clock,this.clockBase));
      end
      
      % initialize multiple dynamic models
      this.input=DynamicModel.factory(dynamicModelName,ta,uri);
      for k=2:numInputs
        this.input(k)=DynamicModel.factory(dynamicModelName,ta,uri);
      end
      
      % randomize initial input parameters
      nIL=numInitialLogical(this.input(1));
      nIU=numInitialUint32(this.input(1));
      for k=1:numInputs
        L=randLogical(nIL);
        for p=uint32(1):nIL
          setInitialLogical(this.input(k),p-uint32(1),L(p));
        end
        U=randUint32(nIU);
        for p=uint32(1):nIU
          setInitialUint32(this.input(k),p-uint32(1),U(p));
        end
      end
      
      refresh(this);
    end
    
    function refresh(this)
      M=numel(this.measure);
      if(M>0)
        tb=-Inf;
        while(isinf(tb))
          for m=1:M
            gm=this.measure{m};
            refresh(gm);
            if(hasData(gm))
              tb=max(tb,getTime(gm,last(gm)));
            end
          end
        end
        tb=WorldTime(tb);
      else
        tb=WorldTime(etime(clock,this.clockBase));
      end
      
      nEL=numExtensionLogical(this.input(1));
      nEU=numExtensionUint32(this.input(1));
      interval=domain(this.input(1));
      while(interval.second<tb)
        for k=1:numel(this.input)
          Fk=this.input(k);
          extend(Fk);
          b=numExtensionBlocks(Fk);
          L=randLogical(nEL);
          for p=uint32(1):nEL
            setExtensionLogical(Fk,b-uint32(1),p-uint32(1),L(p));
          end
          U=randUint32(nEU);
          for p=uint32(1):nEU
            setExtensionUint32(Fk,b-uint32(1),p-uint32(1),U(p));
          end
        end
        interval=domain(Fk);
      end
    end
  end
  
end

function v=randLogical(num)
  v=logical(rand(1,num)>0.5);
end

function v=randUint32(num)
  v=randi([0,4294967295],1,num,'uint32');
end
