t=cputime;
rng(123457)
load author2attr.txt;
load paper2word.txt;
load author2paper.txt;
load paper2paper.txt;
load author2author.txt;
A=cell(4,4);
A{1,2}=spconvert(author2paper);
A{1,3}=spconvert(author2attr);
A{2,4}=spconvert(paper2word);
A{2,4}=A{2,4}./max(max(A{2,4}));
n=size(A{1,2},1);
m=size(A{1,2},2);
sim=sparse(author2author(:,1),author2author(:,2),author2author(:,3),n,n);
sim=sim./max(max(sim));
sim2=sparse(paper2paper(:,1),paper2paper(:,2),paper2paper(:,3),m,m);
sim2=sim2./max(max(sim2));
A{1,1}=sim;
A{2,2}=sim2;
addpath(genpath('../../../'));
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
