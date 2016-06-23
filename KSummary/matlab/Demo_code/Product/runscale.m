rng(1234567);
t=cputime;
load product2attr.txt;
G=spconvert(product2attr);
addpath(genpath('../../../'));
G=G./max(max(G));
n=size(G,1);
load product2product.txt;
sim=sparse(product2product(:,1),product2product(:,2),product2product(:,3),n,n);
sim=normalize_X(sim);
load attr2attr.txt;
sim2=sparse(attr2attr(:,1),attr2attr(:,2),attr2attr(:,3),m,m);
sim2=normalize_X(sim2);
A=cell(2,2);
A{1,1}=sim;
A{1,2}=G;
A{2,2}=sim2;
thresall=(0.1:0.1:1);
e=cputime;
Iotime=e-t;
for i=1:length(thresall)
    t=cputime;
    thres=thresall(i);
    B=RandomSample(A,1,thres,n);
    [~,C,~]=GraphSumPlus(B);
    e=cputime;
    fprintf('total running time for %d pencent of data', 10*i);
    disp(e-t+Iotime);
end
