function newline(fid)
if(nargin==0)
  fprintf('\n');
else
  fprintf(fid, '\x0d\x0a');
end  
end
