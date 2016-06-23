function [ ] = saveCCSmatrix(X,filename)
[i,j,value]=find(X);
[n1,n2]=size(X);
nz=nnz(X);
fid=fopen(strcat(filename,'_dim'),'w');
fprintf(fid,'%d\t%d\t%d\n',n1,n2,nz);
fclose(fid);
fid=fopen(strcat(filename,'_row_ccs'),'w');
for k=1:length(i)
    fprintf(fid,'%d\n',i(k)-1);
end
fclose(fid);
fid=fopen(strcat(filename,'_col_ccs'),'w');
for k=1:length(j)
    fprintf(fid,'%d\n',j(k)-1);
end
fclose(fid);
fid=fopen(strcat(filename,'_nz'),'w');
for k=1:length(value)
    fprintf(fid,'%f\n',value(k));
end
fclose(fid);
end
