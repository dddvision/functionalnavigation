function MeasureTest(packageName,uri)

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

  % Compute bias? (distance from ground truth to cost minimum)
  % Perturb trajectory small amounts around ground truth and evaluate costs
  % Include tests with ta=tb and ta~=tb
  % Granularity (dilution of precision, distance until cost increases at all)
  % Monotonicity (distance until cost begins to decrease)
  % Cost (maybe smoothed around ground truth)
  % Jacobian (sensitivity)
  % Hessian (eigenvalues and consistency of their ratios, eigenvectors)
  
end
