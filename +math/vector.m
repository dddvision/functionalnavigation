% Vector.
%
% @param[in]  type uninitialized object of the desired class or numeric type
% @param[in]  N    number of rows in the output vector
% @param[in]  fill scalar object or value that will be copied to fill all elements of the output vector
% @param[out] v    vector object (Nx1)
%
% @note
% Only classes and numeric types are supported.
function v = vector(varargin)
switch(nargin)
  case 0
    error('vector: missing type argument');
  case 1
    a = varargin{1};
    if(numel(a)>0)
      v = varargin{1}([], :);
    else
      c = class(a);
      v = feval(c, 0);
      v = v([], :);
    end
  case 2
    N = varargin{2};
    if(N==0)
      v = math.vector(varargin{1});
    else
      a = varargin{1};
      c = class(a);
      if(isobject(a))
        v(N, 1) = eval(c);
      else
        z = feval(c, 0);
        v = repmat(z, N, 1);
      end
    end
  case 3
    if(strcmp(class(varargin{1}), class(varargin{3})))
      N = varargin{2};
      if(N==0)
        v = math.vector(varargin{1});
      else
        if(isscalar(varargin{3}))
          a = varargin{1};
          if(isobject(a))
            if(ismember('copy', methods(a)))
              v(N, 1) = varargin{3};
              for n = 1:(N-1)
                v(n, 1) = v(N, 1).copy();
              end
            else
              error('vector: fill object must support a copy method');
            end
          else
            v = repmat(varargin{3}, N, 1);
          end
        else
          error('vector: fill argument must be scalar');
        end
      end
    else
      error('vector: fill object and type argument must be of the same class');
    end
  otherwise
    error('vector: too many input arguments');
end
end
