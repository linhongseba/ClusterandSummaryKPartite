function [f] = objective( A, B, C, k, hasCon)
% compute the square loss between original graph and reconstructed graph
 f=0;
    for i=1:k
        for j=i+1:k % save speed do half the updates, implies SYMMETRIC graph i.e. nondirected
            if hasCon(i,j)
                dz=A{i,j}-C{i}*B{i,j}*C{j}';
                f=f+sum(sum(dz.^2));
            end
        end
    end
end

