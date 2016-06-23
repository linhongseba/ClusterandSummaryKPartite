function [  ] = SaveSummary( B,name )
%
%   Detailed explanation goes here
[n1,~]=size(B);
[n2,~]=size(name);
if n1~=n2
    disp('summary graph is not a square cell');
end
%1: offer layer
%2: attribute layer
%3: Service layer
%4: Page layer
%5: Word layer
for i=1:n1
    for j=1:n1
        G=B{i,j};
        [a,b]=size(G);
        if a>0
           if (isempty(name{i,j}) == 0)
                fprintf('%d %d %s\n',i, j, name{i,j});
                fid=fopen(name{i,j},'w');
                for na=1:a
                    [value,index]=max(G(na,:));
                    fprintf(fid,'%d\t%d\t%f\n',na,index,value);
                end
                for nb=1:b
                    [value,index]=max(G(:,nb));
                    fprintf(fid,'%d\t%d\t%f\n',index,nb,value);
                end
           end
        end
    end
end      
end


