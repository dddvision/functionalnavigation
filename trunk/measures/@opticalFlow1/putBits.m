function this=putBits(this,bits,tmin)
  fprintf('\n');
  fprintf('\ncameraOpticalFlow1::putBits');
  fprintf('\nbits = ');
  fprintf('%d',bits);
  this.focalPerturbation=bits;
end
