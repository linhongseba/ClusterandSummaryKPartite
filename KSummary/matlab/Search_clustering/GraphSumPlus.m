function [Summary,Cluster,f] = GraphSumPlus(A,varargin)
%
% Input: 
%   k-partite graph A, given as cell array with matrix A{i,j}=A{j,i}
%       describing weights between vertices of type i and those of type j
%
% Additional optional input [param,value]:
%   clusters   maximum number of super vertices (default n)
%   numit       number of iterations numit (default 500)
%   abort       abort iteration if (normalized) change of cost function is 
%                   below this treshold (default 1e-10)
%   verbose     text output (default true)
%   verbosecompact  compact text output during counting (default true)
%
% Output:
%   Summary   a summary k-paritite super graph
%   Cluster   clustering cell vector of the $k$-type vertices
%   fs  cost function value 
%
% Output is such that Aij-Ci*Bij*Cj' has minimal Frobenius norm.
%
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
p.addParamValue('clusters', n, @(x)isvector(x) && length(x)==k);
p.addParamValue('numit', 200, @(x)x>0 && mod(x,1)==0);
p.addParamValue('abort', 1e-10, @(x)x>=0);
p.addParamValue('verbose', true, @islogical);
p.addParamValue('verbosecompact', true, @islogical);
p.parse(varargin{:});
res=p.Results;
if res.verbose
    fprintf('starting graph Co-clustering of %i-partite graph with partition sizes: ',k);
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
maxcluster=res.clusters;
%% matrix containing empty connections implying NO fit here, includes diagonal!
hasCon=zeros(k);
for i=1:k, for j=1:k, hasCon(i,j)=~isempty(A{i,j}); end, end
flag=true;
r=zeros(k,1);
for i=1:k
    r(i)=maxcluster(i);
end

%% initialization
t=cputime;
[B,C,powerA]=Initilize(A,hasCon,n,r);
e=cputime;
disp('initilization time is');
disp(e-t);
while flag
    [B,C] = Refinement(B, C, A, r, powerA, res, hasCon);
    %start searching a better number of clusters by best-two merging
    fold=objective(A,B,C,k,hasCon);
    fprintf('old objective value is %f: \n',fold);
    disp(sum(r));
    disp(sum(maxcluster));
    if sum(r) > sum(maxcluster)
        [Cluster,Summary, r,isreduced]=search(B,C,k,r,true,maxcluster);
    else
        [Cluster,Summary, r,isreduced]=search(B,C,k,r,false,maxcluster);
    end
    if isreduced
        [Summary,Cluster] = Refinement(Summary, Cluster, A, r, powerA, res, hasCon);     
    end
    fnew=objective(A,Summary,Cluster,k,hasCon);
    fprintf('new objective value is %f: \n',fnew);
    disp(r');
    if abs(fnew-fold)/powerA<res.abort
        flag =false;
    end
    B=Summary;
    C=Cluster;
end
   f= objective(A,Summary,Cluster,k,hasCon);
end

function [Cnew, isreduced]=ClusterMinusmany(C,i,a,v)
    M=C{i,1};
    Cnew=C;
    [n1,n2]=size(M);
    nc=0;
    isreduced=false;
    for m1=1:length(a)
        if a(m1)<=v
            nc=nc+1;
            isreduced=true;
        end
    end
    Mnew=zeros(n1,n2-nc);
    nc=1;
    for m1=1:length(a)
        if a(m1)>v
            Mnew(:,nc)=M(:,m1);
            nc=nc+1;
        end
    end
    Cnew{i,1}=Mnew;
end

function [Bnew]=SummaryMinusmany(B,i,a,v)
    Bnew=B;
    [n1,n2]=size(B);
    nc=0;
    for m1=1:length(a)
        if a(m1)<=v
            nc=nc+1;
        end
    end
    for j=1:n1
        M=B{j,i};
        if size(M,2)<1
            continue;
        end
        [b1,b2]=size(M);
        Mnew=zeros(b1,b2-nc);
        idx=1;
        for m1=1:length(a)
            if a(m1)>v
                Mnew(:,idx)=M(:,m1);
                idx=idx+1;
            end
        end
        Bnew{j,i}=Mnew;
    end
    for j=1:n2
          M=B{i,j};
          if size(M, 1)<1
              continue;
          end
          [b1,b2]=size(M);
          Mnew=zeros(b1-nc,b2);
          idx=1;
          for m1=1:length(a)
              if a(m1)>v
                  Mnew(idx,:)=M(m1,:);
                  idx=idx+1;
              end
          end
          Bnew{i,j}=Mnew;
    end
    
end

%Cross-many out cluster reduction
function [C, B, r,isreduced]=search(B,C,k,r,ishard,maxcluster)
%search the best number of clusters for each type of vertices in k-partite
%graph A
% Input: 
% A: The cell array representation for k-partite graph
% B: The cell array representation for summary graph with number of
% supernodes r=[r1,r2, ...,rk]
% C: The cell array representation for node to cluster (super node)
% assignment
% r: current super node assignment r=[r1,r2,..., rk]
% Output:
% Cluster: New node to cluster assigment by cross-many out cluster reduction
% Summary: New summary graph by cross-many out cluster reduction
isreduced=false;
for i=1: k
    fprintf('old number of clusters for %i-type is %i\n',i,r(i));
    if r(i)< max(3,maxcluster/k)
        fprintf('skip %i-type', i);
        continue;
    end
    ni=size(C{i,1},1);
    a=zeros(1,r(i));
    for j=1:ni
        [~,index]=max(C{i,1}(j,:));
        a(index)=a(index)+1;
    end
    if ishard
        [v,~]=min(a);
    else
        v=0;
    end
    [C,isflag]=ClusterMinusmany(C,i,a,v);
    if isflag
        isreduced=true;
    end
    [B]=SummaryMinusmany(B,i,a,v);
    r(i)=size(C{i,1},2);
    fprintf('new number of clusters for %i-type is %i\n',i,r(i));
end     
end

% function [Cnew]=ClusterMinusone(C,i,m1)
%     Cnew=C;
%     M=C{i,1};
%     disp('matrix size');
%     disp(size(M,1));
%     disp(size(M,2));
%     disp(m1);
%     if size(M,2)>0
%         if (m1>1)&&(m1<size(M,2))
%             M=M(:,[1:m1-1,m1+1:end]);
%         elseif m1>1
%                 M=M(:,1:m1-1);
%         else
%                 M=M(:,m1+1:end);
%         end
%         Cnew{i,1}=M;
%     end
% end
% 
% function [Cnew]=SummaryMinusone(C,i,m1)
%      Cnew=C;
%      [n1,n2]=size(C);
%      for j=1:n1
%          M=C{j,i};
%          if size(M,2)>0
%              if (m1>1)&&(m1<size(M,2))
%                  M=M(:,[1:m1-1,m1+1:end]);
%              elseif m1>1
%                      M=M(:,1:m1-1);
%              else
%                      M=M(:,m1+1:end);
%              end
%              Cnew{j,i}=M;
%          end
%      end
%      for j=1:n2
%          M=C{i,j};
%          if size(M,1)>0
%              if (m1>1)&&(m1<size(M,1))
%                  M=M([1:m1-1,m1+1:end],:);
%              else if m1>1
%                      M=M(1:m1-1,:);
%                  else
%                      M=M(m1+1:end,:);
%                  end
%              end
%              Cnew{i,j}=M;
%          end
%      end
% end

% function [Cluster, Summary, r]=search(A,B,C,k,hascon,r)
% %search the best number of clusters for each type of vertices in k-partite
% %graph A
% % Input: 
% % A: The cell array representation for k-partite graph
% % B: The cell array representation for summary graph with number of
% % supernodes r=[r1,r2, ...,rk]
% % C: The cell array representation for node to cluster (super node)
% % assignment
% % r: current super node assignment r=[r1,r2,..., rk]
% % Output:
% % Cluster: New node to cluster assigment by cross-one out merging
% % Summary: New summary graph by cross-one out merging
% fold=objective(A,B,C,k,hascon);
% for i=1: k
%     minvalue=fold;
%     Cluster=C;
%     Summary=B;
%     fprintf('old number of clusters for %i-type is %i\n',i,r(i));
%     for m1=1:r(i)
%         [Cnew]=ClusterMinusone(C,i,m1);
%         [Bnew]=SummaryMinusone(B,i,m1);
%         flocalnew=objective(A,Bnew,Cnew,k,hascon);
%         if minvalue-flocalnew>0.000001
%             minvalue=flocalnew;
%             Cluster=Cnew;
%             Summary=Bnew;
%         end
%     end
%     C=Cluster;
%     B=Summary;
%     r(i)=size(C{i,1},2);
%     fprintf('new number of clusters for %i-type is %i\n',i,r(i));
%     fold=minvalue;
% end     
% end
% 
% function [Cnew]=ClusterMinusone(C,i,m1)
%     Cnew=C;
%     M=C{i,1};
%     if size(M,1)>0
%         M=M(:,[1:m1 - 1, m1 + 1:end]);
%         Cnew{i,1}=M;
%     end
% end
% 
% function [Cnew]=SummaryMinusone(C,i,m1)
%      Cnew=C;
%      [n1,n2]=size(C);
%      for j=1:n1
%          M=C{j,i};
%          if size(M,1)>0
%               M=M(:,[1:m1 - 1, m1 + 1:end]);
%               Cnew{j,i}=M;
%          end
%      end
%      for j=1:n2
%          M=C{i,j};
%          if size(M,1)>0
%              M=M([1:m1 - 1, m1 + 1:end],:);
%              Cnew{i,j}=M;
%          end
%      end
% end
% function [Cluster, Summary]=search(A,B,C,k,hascon,r)
% %search the best number of clusters for each type of vertices in k-partite
% %graph A
% % Input: 
% % A: The cell array representation for k-partite graph
% % B: The cell array representation for summary graph with number of
% % supernodes r=[r1,r2, ...,rk]
% % C: The cell array representation for node to cluster (super node)
% % assignment
% % r: current super node assignment r=[r1,r2,..., rk]
% % Output:
% % Cluster: New node to cluster assigment by best-two merging
% % Summary: New summary graph by best-two merging
% fold=objective(A,B,C,k,hascon);
% for i=1: k
%     minvalue=fold;
%     Cluster=C;
%     Summary=B;
%     for m1=1:r(i)-1
%         
%         for m2=(m1+1):r(i)
%             [Cnew]=merge(C,i,m1,m2,true);
%             [Bnew]=merge(B,i,m1,m2,false);
%             flocalnew=objective(A,Bnew,Cnew,k,hascon);
%             if flocalnew < minvalue
%                 minvalue=flocalnew;
%                 Cluster=Cnew;
%                 Summary=Bnew;
%             end
%         end
%     end
%     C=Cluster;
%     B=Summary;
%     [~,r(i)]=size(C{i,1});
%     fold=minvalue;
% end     
% end


% function [Cnew]=merge(C,i,m1,m2,column)
%     [~,n2]=size(C);
%     Cnew=C;
%     for j=1:n2
%         M=C{i,j};
%         if size(M,1)>0
%             if column 
%                 M(:,m1)=M(:,m1)+M(:,m2);
%                 M=M(:,[1:m2 - 1, m2 + 1:end]);
%             else
%                 M(m1,:)=M(m1,:)+M(m2,:);
%                 M=M([1:m2 - 1, m2 + 1:end],:);
%             end
%             Cnew{i,j}=M;
%         end
%     end
% end

