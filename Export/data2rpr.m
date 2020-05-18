function data2rpr(filename, rpr)


fid = fopen(filename,'wb'); 
fwrite(fid,rpr,'int8');
fclose(fid);


end