% Convert the underlying representation of trajectories to a new type


function this=convert(this,newtype)
  for k=1:numel(this)
    this=trajectory_convert_individual(this(k),newtype);
  end
end


function this=trajectory_convert_individual(this,newtype)

  type=this.type;
  data=this.data;

  switch( type )
    case 'analytic'
      newtype = type;  
    case {'wobble_1.5','pendulum_1.5'}
      switch( newtype )
        case 'tposquat'
          [a,b]=domain(this);
          t=a:((b-a)/100):b;
          data=[t;evaluate(this,t)];
        otherwise
          error('unhandled conversion');
      end          
    case 'empty'
      % do nothing
    otherwise
      error('unhandled exception');
  end

  this(k).type=newtype;
  this(k).data=data;

end
