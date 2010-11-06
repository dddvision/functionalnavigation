classdef XDynamics < XDynamics.XDynamicsConfig & tom.DynamicModel
  
  properties (Constant=true,GetAccess=private)
    initialNumLogical=uint32(0);
    initialNumUint32=uint32(2);
    extensionNumLogical=uint32(0);
    extensionNumUint32=uint32(0);
    extensionBlockCost=0;
    numExtension=uint32(0);
    parameterErrorText='This dynamic model has no initial logical parameters';
    extensionErrorText='This dynamic model has no extension blocks';
  end
  
  properties (GetAccess=private,SetAccess=private)
    initialTime
    initialUint32
    xRef
  end
  
  methods (Static=true,Access=public)
    function initialize(name)
      function text=componentDescription
        text=['Evaluates a reference trajectory and adds perturbation to initial ECEF X positon and velocity. ',...
          'Perturbation is simulated by sampling from a normal distribution.'];
      end
      tom.DynamicModel.connect(name,@componentDescription,@XDynamics.XDynamics);
    end
  end
  
  methods (Access=public)
    function this=XDynamics(initialTime,uri)
      if(nargin==0)
        initialTime=tom.WorldTime(0);
        uri='';
      end
      this=this@tom.DynamicModel(initialTime,uri);
      if(nargin>0)
        this.initialTime=initialTime;
        this.initialUint32=zeros(1,this.initialNumUint32,'uint32');
        try
          [scheme,resource]=strtok(uri,':');
          resource=resource(2:end);
          switch(scheme)
            case 'antbed'
              container=antbed.DataContainer.create(resource,initialTime);
              if(hasReferenceTrajectory(container))
                this.xRef=getReferenceTrajectory(container);
              else
                this.xRef=tom.DynamicModelDefault(initialTime, uri);
              end
            otherwise
              error('Unrecognized resource identifier in URI');
          end
        catch err
          error('Failed to open data resource: %s',err.message);
        end
      end
    end
    
    function interval=domain(this)
      interval=this.xRef.domain();
    end
    
    function pose=evaluate(this,t)
      N=numel(t);
      if(N==0)
        pose=repmat(tom.Pose,[1,0]);
      else
        pose=evaluate(this.xRef,t);
        z=initialBlock2deviation(this);
        t=double(t);
        t0=double(this.initialTime);
        c1=this.positionOffset-this.positionDeviation*z(1);
        c2=this.positionRateOffset-this.positionRateDeviation*z(2);
        for n=1:N
          pose(n).p(1)=pose(n).p(1)+c1+c2*(t(n)-t0);
        end
      end
    end
   
    function tangentPose=tangent(this,t)
      N=numel(t);
      if(N==0);
        tangentPose=repmat(tom.TangentPose,[1,0]);
      else
        tangentPose=tangent(this.xRef,t);
        z=initialBlock2deviation(this);
        t=double(t);
        t0=double(this.initialTime);
        c1=this.positionOffset-this.positionDeviation*z(1);
        c2=this.positionRateOffset-this.positionRateDeviation*z(2);
        for n=1:N
          tangentPose(n).p(1)=tangentPose(n).p(1)+c1+c2*(t(n)-t0);
          tangentPose(n).r(1)=tangentPose(n).r(1)+c2;
        end
      end
    end
    
    function num=numInitialLogical(this)
      num=this.initialNumLogical;
    end
    
    function num=numInitialUint32(this)
      num=this.initialNumUint32;      
    end
  
    function num=numExtensionLogical(this)
      num=this.extensionNumLogical;
    end
    
    function num=numExtensionUint32(this)
      num=this.extensionNumUint32;
    end

    function num=numExtensionBlocks(this)
      num=this.numExtension;
    end
    
    function v=getInitialLogical(this,p)
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      v=false(size(p));
      error(this.parameterErrorText);
    end

    function v=getInitialUint32(this,p)
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      v=this.initialUint32(p+1);
    end

    function v=getExtensionLogical(this,b,p)
      assert(isa(b,'uint32'));
      assert(numel(b)==1);
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      v=false(size(p));
      error(this.extensionErrorText);
    end

    function v=getExtensionUint32(this,b,p)
      assert(isa(b,'uint32'));
      assert(numel(b)==1);
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      v=zeros(size(p),'uint32');
      error(this.extensionErrorText);
    end

    function setInitialLogical(this,p,v)
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      assert(isa(v,'logical'));
      assert(numel(v)==1);
      error(this.parameterErrorText);
    end

    function setInitialUint32(this,p,v)
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      assert(isa(v,'uint32'));
      assert(numel(v)==1);
      % assert(p<this.initialNumUint32); % removed for speed
      this.initialUint32(p+1)=v;
    end
    
    function setExtensionLogical(this,b,p,v)
      assert(isa(b,'uint32'));
      assert(numel(b)==1);
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      assert(isa(v,'logical'));
      assert(numel(v)==1);
      error(this.extensionErrorText);
    end
    
   function setExtensionUint32(this,b,p,v)
      assert(isa(b,'uint32'));
      assert(numel(b)==1);
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      assert(isa(v,'uint32'));
      assert(numel(v)==1);
      error(this.extensionErrorText);
    end
    
    function cost=computeInitialBlockCost(this)
      z=initialBlock2deviation(this);
      cost=0.5*dot(z,z);
    end

    function cost=computeExtensionBlockCost(this,b)
      assert(isa(b,'uint32'));
      assert(numel(b)==1);
      cost=this.extensionBlockCost;
    end
    
    function extend(this)
      assert(isa(this,'tom.DynamicModel'));
    end
    
    function obj=copy(this)
      obj=XDynamics.XDynamics();
      obj.initialTime=this.initialTime;
      obj.initialUint32=this.initialUint32;
      obj.xRef=this.xRef;
    end    
  end
  
  methods (Access=private)
    function z=initialBlock2deviation(this)
      sixthIntMax=715827882.5;
      z=double(this.initialUint32)/sixthIntMax-3;
    end
  end
  
end
