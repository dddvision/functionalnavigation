function rgb=getColor32ColMajor(this,k)
rgb=getColor32RowMajor(this,k);
rgb=permute(rgb,[2,1,3]);
end
