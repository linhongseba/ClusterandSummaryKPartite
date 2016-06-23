function [Acctweettotal, Accusertotal, MItweettotal, MIusertotal] = onlinerun2(gamma, tau)
t = cputime;
first=13;
numfile=5;
alpha=0.9;
beta=0.8;
%gamma=0.8;
%tau=0.6;
load ./Data/30/Sf0.txt
Sf0=spconvert(Sf0);
l=size(Sf0,1); %number of features;
% erruser = zeros(numfile,1);  %uer-level error of each iteration
% errtweet = zeros(numfile,1);  %tweet-level error of each iteration
% errtotal = zeros (numfile,1); %total errof of each iteration
Accuser = zeros(numfile,1);  %user-level accuracy of each iteration
Acctweet = zeros(numfile,1);  %tweet-level accuracy of each iteration
MIuser = zeros(numfile,1);    %user-level MI of each iteration
MItweet = zeros(numfile,1);    %tweet-level MI of each iteration
ntotal=0;
mtotal=0;
Accusertotal=0;
Acctweettotal=0;
MIusertotal=0;
MItweettotal=0;
totaltime=zeros(numfile,1);
for k=1:numfile
	ftime=cputime;
    [Xpt, Xut, Xrt, Gut, tlabel, ulabel, n, m]=loadonlinedata(k+first,l);
	%disp('time to load the data:');
	%disp(cputime-ftime);
    if isempty(Xpt)==true
        continue;
    end
    if(k==1)
        Sftw = Sf0;
        clearvars Sf0;
    end
    if(k==1)
        %initilize Supre based on Xut;
        Supre = InitSu(Xut,m);
    else
        Supre = Sut;
    end
	%ftime=cputime;
    [Sut,~,Sft,~,~,~, ~, ~, accyu,accyp, MIu, MIp] = onlinecluster(Xut,Xrt,Xpt,Gut,Sftw,alpha,beta,gamma, tlabel, ulabel,Supre);
	%disp('time to do tri-clustering:');
	%disp(cputime-ftime);
%     erruser(k)=min(errSut);
%     errtweet(k)=min(errSpt);
%     errtotal(k)=min(errsrt);
    Accuser(k)=max(accyu);
    Acctweet(k)=max(accyp);
    MIuser(k)=max(MIu);
    MItweet(k)=max(MIp);
    if k==2
         Sftw = tau *Sft;
    else
        if k>=2
        Sftw = tau *Sft+tau*Sfpre;
        end
    end
    Sfpre=Sft;
    disp(k+first);
    disp('finish computing current Day');
    [user ~] = memory;
    disp(user.MemUsedMATLAB/1024/1024);
    if Accuser(k)~=0
         mtotal=mtotal+m;
         Accusertotal=Accusertotal+Accuser(k)*m;
    end
    if Acctweet(k)~=0
        ntotal=ntotal+n;
        Acctweettotal=Acctweettotal+Acctweet(k)*n;
    end
    if(isnan(MIuser(k))==false)
        MIusertotal=MIusertotal+MIuser(k)*m;
    end
    if(isnan(MItweet(k))==false)
        MItweettotal=MItweettotal+MItweet(k)*n;
    end
    totaltime(k)=cputime-ftime;
    disp(cputime-ftime);
end
MIusertotal=MIusertotal/mtotal;
Accusertotal=Accusertotal/mtotal;
MItweettotal=MItweettotal/ntotal;
Acctweettotal=Acctweettotal/ntotal;
e=cputime-t;
disp('running time(s):');    disp(e);
disp('Average user Accuracy:'); disp(Accusertotal);
disp('Average tweet Accuracy:'); disp(Acctweettotal);
disp('Average user MI:'); disp(MIusertotal);
disp('Average tweet MI:'); disp(MItweettotal);
clearvars Sfpre Sft Sftw errSut errSpt errsrt accyu accyp MIu MIp;
clearvars Sut supre;

end

