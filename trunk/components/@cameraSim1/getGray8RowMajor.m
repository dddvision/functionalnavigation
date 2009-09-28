function gray=getGray8RowMajor(this,k)
gray=rgb2gray(getColor32RowMajor(this,k));
if(isempty(gray))
  gray=zeros(0,0);
end
end
