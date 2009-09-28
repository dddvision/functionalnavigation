function gray=getGray8ColMajor(this,k)
gray=getGray8RowMajor(this,k);
gray=permute(gray,[2,1]);
end
