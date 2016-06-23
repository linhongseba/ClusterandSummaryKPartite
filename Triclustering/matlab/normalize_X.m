function X = normalize_X(X)
d = size(X,2);
norms = sqrt(sum(X.^2,2));
eps = 1e-9;
X = X./(repmat(norms,1,d)+eps);
%make sure the elements in X is nonnegative and X is orthogonal
if min(min(X)) < 0
    error('The entries cannot be negative');
end
if min(sum(X,2)) == 0
    error('Summation of all entries in a row cannot be zero');
end
