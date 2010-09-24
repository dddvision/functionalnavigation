classdef FastPBM < tom.Measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
    tracker
  end
  
  methods (Static=true,Access=public)
    function initialize(name)
      function text=componentDescription
        text='Implements a fast visual feature tracker and associated trajectory measure.';
      end
      tom.Measure.connect(name,@componentDescription,@FastPBM.FastPBM);
    end
  end
  
  methods (Access=public)
    function this=FastPBM(uri)
      this=this@tom.Measure(uri);

      try
        [scheme,resource]=strtok(uri,':');
        resource=resource(2:end);
        switch(scheme)
          case 'matlab'
            container=tom.DataContainer.create(resource);
            list=container.listSensors('Camera');
            this.sensor=container.getSensor(list(1));
          otherwise
            error('Unrecognized resource identifier in URI');
        end
      catch err
        error('Failed to open data resource: %s',err.message);
      end                  

      this.tracker=FastPBM.SparseTrackerKLT(this.sensor);
    end
    
    function refresh(this)
      refresh(this.sensor);
    end
    
    function flag=hasData(this)
      flag=hasData(this.sensor);
    end
    
    function n=first(this)
      n=first(this.sensor);
    end
    
    function n=last(this)
      n=last(this.sensor);
    end
    
    function time=getTime(this,n)
      time=getTime(this.sensor,n);
    end
    
    function edgeList=findEdges(this,x,naMin,naMax,nbMin,nbMax)
      assert(isa(x,'tom.Trajectory'));
      edgeList=repmat(tom.GraphEdge,[0,1]);
      if(hasData(this.sensor))
        nMin=max([naMin,first(this.sensor),nbMin-uint32(1)]);
        nMax=min([naMax+uint32(1),last(this.sensor),nbMax]);
        nList=nMin:nMax;
        [na,nb]=ndgrid(nList,nList);
        keep=nb(:)>na(:);
        na=na(keep);
        nb=nb(keep);
        if(~isempty(na))
          edgeList=tom.GraphEdge(na,nb);
        end
      end
    end
    
    function cost=computeEdgeCost(this,x,graphEdge)
      nA=graphEdge.first;
      nB=graphEdge.second;
      
      % return 0 if the specified edge is not found in the graph
      isAdjacent = ((nA+uint32(1))==nB) && ...
        hasData(this.sensor) && ...
        (nA>=first(this.sensor)) && ...
        (nB<=last(this.sensor));
      if(~isAdjacent)
        cost=0;
        return;
      end

      % return NaN if the graph edge extends outside of the trajectory domain
      tA=getTime(this.sensor,nA);
      tB=getTime(this.sensor,nB);
      interval=domain(x);
      if((tA<interval.first)||(tB>interval.second))
        cost=NaN;
        return;
      end

      % refresh the tracker
      this.tracker.refresh();
      numA=this.tracker.numFeatures(nA);
      rayA=zeros(3,numA);
      for localIndex=uint32(1):numA
        rayA(:,localIndex)=this.tracker.getFeatureRay(nA,localIndex-uint32(1));
      end
      figure(1);
      plot3(rayA(1,:),rayA(2,:),rayA(3,:),'r.','MarkerSize',1);
      axis('equal');
      xlim([-1,1]);
      ylim([-1,1]);
      zlim([-1,1]);
      drawnow;
      
      poseA=evaluate(x,tA);
      poseB=evaluate(x,tB);
      
      cost=0;
    end
  end
  
end
