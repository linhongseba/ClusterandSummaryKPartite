function [B,C,fs]=GraphSum(A,varargin)
% function [B,C,fs]=GraphSum(A,[param,value])
%
% Input: 
%   k-partite graph A, given as cell array with matrix A{i,j}=A{j,i}
%       describing weights between vertices of color i and those of color j
%
% Additional optional input [param,value]:
%   clusters    number of vertex clusters of given color (default [2 ...2])
%   numit       number of iterations numit (default 1000)
%   abort       abort iteration if (normalized) change of cost function is 
%                   below this treshold (default 1e-10)
%   verbose     text output (default true)
%   verbosecompact  compact text output during counting (default true)
%
% Output:
%   B   k-partite summary graph
%   C   the mapping between original vertices and super nodes in summary graph
%   fs  cost function value in each iteration
%
% Output is such that Aij-Ci*Bij*Cj' has minimal Frobenius norm.
%

%

% EXAMPLE:
% Tripartite graph
% A=cell(3,3);
% A{1,2}=[1 1 1 1; 1 1 1 1; 0 0 1 1; 0 0 1 1;0 0 1 1;0 0 1 1; 1 1 0 0 ];
% A{1,3}=[1 1 0 0; 1 1 0 0; 1 1 0 0; 1 1 0 0;1 1 1 1;1 1 1 1; 1 1 1 1 ];
% [B,C,cost] = GraphSum(A,'clusters',[3,2,2]);


%% input parameter scan
k=size(A,1);
if ~iscell(A) || k<2 || size(A,2)~=k, error('need symmetric cell array as input of k-partite graph'); end
% determine dimensions
n=zeros(k,1);
for i=1:k 
    for j=1:k
        nn=size(A{i,j},1);
        if nn>0
            if n(i)==0
                n(i)=nn;
            elseif n(i)~=nn
                error('need same sizes in k-partite graph description in matrix %i %i',i,j);
            end
        end
        nn=size(A{j,i},2);
        if nn>0
            if n(i)==0
                n(i)=nn;
            elseif n(i)~=nn
                error('need same sizes in k-partite graph description in matrix %i %i',j,i);
            end
        end
    end
end
if min(n)==0, error('need at least one connectivity matrix per column'); end

p=inputParser;
p.addParamValue('clusters', repmat(2,k,1), @(x)isvector(x) && length(x)==k);
p.addParamValue('numit', 200, @(x)x>0 && mod(x,1)==0);
p.addParamValue('abort', 1e-10, @(x)x>=0);
p.addParamValue('verbose', true, @islogical);
p.addParamValue('verbosecompact', true, @islogical);
p.parse(varargin{:});
res=p.Results;
r=res.clusters;
if res.verbose
    fprintf('starting summarizing of %i-partite graph with partition sizes: ',k);
    disp(n');
end

%% (possibly) symmetrize or fill up lower (or upper) triangular part of A
for i=1:k
    for j=1:k
        if isempty(A{i,j})
            A{i,j}=A{j,i}';
        elseif ~isempty(A{j,i})
            A{i,j}=(A{i,j}+A{j,i}')/2;
        end
    end
end

%% matrix containing empty connections implying NO fit here, includes diagonal!
hasCon=zeros(k);
for i=1:k, for j=1:k, hasCon(i,j)=~isempty(A{i,j}); end, end

%% initialization
s=cputime;
[B,C,powerA]=Initilize(A,hasCon, n,r);
t=cputime;
disp('Initilization time ');
disp(t-s);

[B,C,fs]=Refinement(B, C, A, r, powerA, res, hasCon); 
if res.verbose, fprintf('\n'); 
end