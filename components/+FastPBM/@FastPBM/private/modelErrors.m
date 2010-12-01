% TODO: supply normfit without relying on MATLAB toolboxes
function modelErrors(translation, rayA, rayB)
  residual = computeResidual(translation, rayA, rayB);
  mu = mean(residual);
  sigma = std(residual);
  fprintf('\n\n*** Computed Calibration Parameters ***\n');
  fprintf('\nmu = %f (radians)', mu);
  fprintf('\nsigma = %f (radians)', sigma);

  % Y = normpdf(range,M,S);
  % Y = Y./max(Y);
  % figure(1),clf;
  % plot(range,Y,'.');
  % hold on;
  % plot(range,Nn,'.','Color','r');
  % hold off;
  % legend('Gaussian','Data');
  % SSE1 = sum((Nn-Y).^2)./length(range);
  % title(sprintf('SSE = %.4d%',SSE1));

  % % KDE METHOD
  % f = ksdensity(Errors,range);
  % f = f./max(f);
  % figure(3),clf;
  % plot(range,f,'.');
  % hold on;
  % plot(range,Nn,'.','Color','r');
  % hold off;
  % legend('KDE','Data');
  % SSE2 = sum((Nn-f).^2)./length(range);
  % title(sprintf('SSE = %.4d%',SSE2));
end
