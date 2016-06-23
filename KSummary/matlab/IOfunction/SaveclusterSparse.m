function [  ] = SaveclusterSparse( C, name)
    [k,~]=size(C);
    for i=1:k
        if isempty(name{i,1})==0
            X=C{i,1};
            [p,q,value]=find(X);
            data_dump = [p,q,value];
            e=size(data_dump,1);
            fid=fopen(name{i,1},'w');
            for j=1:e
                fprintf(fid,'%d\t%d\t%f\n',data_dump(j,1),data_dump(j,2),data_dump(j,3));
            end
            fclose(fid);
        end
    end
end

