classdef MeasureTest < handle
  
  methods (Access=public)
    function this=MeasureTest(packageName,uri)
      fprintf('\npackageName =');
      assert(isa(packageName,'char'));
      fprintf(' ''%s''',packageName);

      fprintf('\nuri =');
      assert(isa(uri,'char'));
      fprintf(' ''%s''',uri);

      fprintf('\nfactory =');
      measure=Measure.factory(packageName,uri);
      assert(isa(measure,'Measure'));
      fprintf(' ok');

      % Call copy constructor?
      % Call destructor?
      % Call all interface functions
      % Check exception handling
      
      % For each edge that the measure supports for the specified data set
        % Compute bias? (distance from ground truth to cost minimum)
        % Perturb trajectory small amounts around ground truth and evaluate costs
        % Include tests with ta=tb and ta~=tb
        % Granularity (dilution of precision, distance until cost increases at all)
        % Monotonicity (distance until cost begins to decrease)
        % Cost (maybe smoothed around ground truth)
        % Jacobian (sensitivity of cost to pertrubation from ground truth)
        % Hessian (eigenvalues and consistency of their ratios, eigenvectors)
        % Time to evaluate initially
        % Time to evaluate repeated
    end
  end
  
end
