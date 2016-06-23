function [  ] = Saveclustering(C, name)
[k,~]=size(C);
%layer 1: offer node
%layer 2: attr node
%layer 3: service node
%layer 4: web node
%layer 5: feature node
for i=1:k
    G=C{i,1};
    if issparse(G)
        G=full(G);
    end
    [n1,~]=size(G);
    fid=fopen(name{i,1},'w');
    for j=1:n1
        [v,index]=max(G(j,:));
        fprintf(fid,'%d\t%d\t%f\n',j,index,v);
    end
    fclose(fid);
end
end

