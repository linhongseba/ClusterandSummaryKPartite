function [B,C,powerA] = Initilize(A,hasCon, n,r)
    k=size(A,1);
    B=cell(k,k); C=cell(k,1); powerA=0;
    maxcluster=max(r);
    % s=cputime;
    if maxcluster<50
        for i=1:k
            C{i}=max(randn(n(i),r(i)),0.00001);
            C{i}=C{i}./repmat(sum(C{i},2),1,r(i));
        end
    else
        for i=1:k
            C{i}=zeros(n(i),r(i));
            if hasCon(i,i)
                 G = A{i,i};
                 G = G + G.'; %' make graph undirected
                 [S,CC]=conncomp(G);
                 disp('connected component');
                 disp(S);
                 CC=CC';
                 if S>5
                     C{i}=CCInit(C{i},CC);
                 else
                     C{i}=MYRandomInit(C{i});
                 end
            else
                C{i}=MYRandomInit(C{i});
            end
            C{i}=sparse(C{i});       
        end
    end
    for i=1:k
        if hasCon(i,i)
            C{i}=LP(A{i,i},C{i});
        end
    end
    C{i}=sparse(C{i});
    for i=1:k
        for j=i:k%save half computation
            if hasCon(i,j)
                if j~=i
                    B{i,j}=max(randn(r(i),r(j)),0.0000001);
                    B{i,j}=sparse(B{i,j});
                else
                    B{i,j}=eye(r(i),r(j));
                end
                powerA=powerA+sum(sum(A{i,j}.^2));
            end
        end
    end
end

function [y]=LP(S, x)
    y = x;
    for iter=1:80
        y = 0.5 * S * y + 0.5 * x;
        y=y./repmat(sum(y,2),1,size(y,2));
    end
    y = y / 0.5;
end

function [Y]=MYRandomInit(Y)
n=size(Y,1);
r=size(Y,2);
for j=1:n
    index=round(rand()*r);
    if index<1
        index=1;
    end
    if index>r
        index=mod(index,r);
    end
    Y(j,index)=1;
end

end

function [Y]=CCInit(Y,CC)
    n=size(Y,1);
    r=size(Y,2);
    for j=1:n
        idx=round(CC(j));
        if idx>r
            idx=mod(idx,r);
        end
        if idx==0
            idx=1;
        end
        Y(j,idx)=1;
    end
end

function [S,C] = conncomp(G)
  [p,~,r] = dmperm(G'+speye(size(G)));
  S = numel(r)-1;
  C = cumsum(full(sparse(1,r(1:end-1),1,1,size(G,1))));
  C(p) = C;
end



