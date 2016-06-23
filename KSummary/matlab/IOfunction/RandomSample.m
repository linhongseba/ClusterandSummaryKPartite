function [ B ] = RandomSample(A, t, thres, n)
%given a k-type graph A, typte t, random sample thres*100% of vertices for t-type
%vertices
    k=size(A,1);
    B=A;
    for i=1:k
        if i==t
            a=n;
             % determine how many elements is ten percent
             numelements = round(thres*a);
             %disp(numelements)
             % get the randomly-selected indices
             indices = randperm(a);
             indices = indices(1:numelements);
             %disp(indices)
            for j=1:k
                G=A{i,j};
                [a,b]=size(G);
                if a>0 && b>0
                    % choose the subset of a you want
                    if j~=i
                        G = G(indices,:);
                    else
                        G=G(indices,indices);
                    end
                    B{i,j}=G;
                    %disp(size(B{i,j}));
                end %end of if
            end
        end %for t-type
    end
    
    
end

