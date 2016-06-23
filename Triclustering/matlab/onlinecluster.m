function [Sut,Spt,Sft,Hut,Hp,errSut, errSpt, errsrt, accyu,accyp, MIu, MIp] = onlinecluster(Xut,Xrt,Xpt,Gut,Sftw,alpha,beta,gamma, tlabel, ulabel,Supre)
%tricluster summary of this function:
  %perform co-clustering for tweet, user, and features (words)
  %n: number of tweets
  %m: number of users
  %d: number of features
  %r: number of clusters
  %Input:  
  %Xut: user-feature matrix m X d
  %Xrt: user-retweet matrix m X n
  %Xpt: tweet-feature matrix n X d
  %Gut: user-user graph, n X n
  %Sftw: last w time stamp feature-cluster information
  %tlabel: ground truth for tweet-cluster
  %ulabel: ground truth for user-cluster
  %hyper-parameter: alpha, beta, gamma
  %output: 
  %Sut: user-cluster matrix m X r
  %Spt: tweet-cluster matrix n X r
  %Sft: feature-cluster matrix d X r
  %errSut: user-level approximation error
  %errSpt: tweet-level approximation error
  %errsrt: total approximation error
  %accyu: user-level accuracy of each iteration
  %accyp :tweet-level accuracy of each iteration
  %MIu: user-level MI of each iteration
  %MIp: tweet-level MI of each iteration
%end 
r=2; %number of clusters, here we have 2 classes, positive and negative
niter=100;  %total number of iteration
errSut = zeros(niter,1);  %user-level error of each iteration
errSpt = zeros(niter,1);  %tweet-level error of each iteration
errsrt = zeros (niter,1); %total error of each iteration
accyu = zeros(niter,1);  %user-level accuracy of each iteration
accyp = zeros(niter,1);  %tweet-level accuracy of each iteration
MIu = zeros(niter,1);    %user-level MI of each iteration
MIp = zeros(niter,1);    %tweet-level MI of each iteration

myeps = 1e-30;
n=size(Xpt,1); %number of tweets;
m=size(Xut,1); %number of users;
d=size(Xpt,2); %number of features;
%=== initialized user-clusters using Kmeans========
%ftime=cputime;
res = kmeans(Xut,r,'emptyaction','singleton');
Sut = zeros(m,r); %user-sentiment cluster information m X r (r=2);
 for i = 1:m
   Sut(i,res(i)) = 1;
 end
Sut = Sut+0.2;
%disp('Init user time:');
%disp(cputime-ftime);
mpre=size(Supre,1);
if mpre<=m
    for i= 1:mpre
        Sut(i)=Supre(i);
    end
    %construct a new supre by horizontally concatenate zeros to supre to let the
    %size of supre equal to Sut
    [i,j,s]=find(Supre);
    Supre=sparse(i,j,s,m,r);
else
    for i=1:m
        Sut(i)=Supre(i);
    end
    Supre=Sut;
end
Sut=sparse(Sut);
Supre=sparse(Supre);
%===end of initialization for Sut
%disp('finish user initialization');
%========== initialized feature-clusters==============
Sft=Sftw;
Sft=sparse(Sft);
%===end of initialization for Sft
%disp('finish feature initialization');
%===initialize Hut using analytical eXptression
Hut = ((Sut' * Sut)/(Sut' * Xut * Sft))\(Sft'*Sft);
Hut = (abs(Hut)+Hut)/2;
%===initialize Hut using analytical eXptression
%disp('finish Hut initialization');
%===========initialized tweet-clusters using features=========
Spt = zeros(n,r); %tweet-sentiment cluster information m X r (r=2);
for i = 1:n
    thres1=Xpt(i,1)+Xpt(i,3);
    thres2=Xpt(i,2)+Xpt(i,4);
    if thres1>thres2&&thres1>0
        Spt(i,1) = 1;
    else
        if thres1<thres2&&thres2>0
            Spt(i,2)=1;
        else
            Spt(i,1) = 0.5;
            Spt(i,2) = 0.5;
        end
    end
end
Spt=sparse(Spt);
%end of initialization for Spt

%===initialize Hp using analytical eXptression
Hp = ((Spt' * Spt)/(Spt' * Xpt * Sft))\(Sft'*Sft);
Hp = (abs(Hp)+Hp)/2;
%===initialize Hp using analytical eXptression
%disp('finish tweet initialization');
%initialize Du and Lu
Du = diag(sum(Gut));
Du = sparse(Du);
Lu = Du - Gut;
Lu = sparse(Lu);
res = zeros(n,1);
for t = 1:niter
    
    %========================================================
    %update Spt the tweet-level sentiment cluster information
    Spt = Spt .*sqrt((Xpt * Sft * Hp' + Xrt' * Sut) ./ max ((((Spt * Hp) * Sft') * Sft * Hp'+ (Spt * Sut') * Sut),myeps));
     % Renormalizes so columns of Spt have constant energy
    norms = sqrt(sum(Spt.^2,1));
    Spt = Spt./repmat(norms,n,1);
    %update Hp
    Hp = Hp .*sqrt((Spt'*Xpt*Sft) ./max(((((Spt' * Spt) * Hp) *Sft') *Sft),myeps));
    Hp = Hp.*repmat(norms,r,1);
    %finish update Hp
    %===========finish update tweet-level sentiment=================
    
    
    %=================================================================
    %update Sut the user-level sentiment cluster information
    TaoU = Sut' * Xut * Sft * Hut' - ((Hut * Sft') * Sft) * Hut' +Sut' * Xrt *Spt -Spt' * Spt - beta * Sut' * Lu * Sut - gamma * Sut' * (Sut- Supre);
    TaoUplus = (abs(TaoU) + TaoU)./2;
    TaoUminus = (abs(TaoU) - TaoU)./2;
    Sut = Sut .* sqrt((Xut * Sft * Hut' + Xrt * Spt + gamma*Supre + beta * Gut * Sut + Sut* TaoUminus) ./ max((((Sut * Hut) * Sft') * Sft * Hut' + ((Sut * Spt') * Spt) + gamma * Sut + beta *Du * Sut + Sut * TaoUplus), myeps));
    % Renormalizes so columns of Sut have constant energy
    norms = sqrt(sum(Sut.^2,1));
    Sut = Sut./repmat(norms,m,1);
    %update Hut
    Hut = Hut .* sqrt(((Sut' * Xut * Sft) ./ max((((Sut' * Sut) * Hut) * Sft') * Sft, myeps)));
    Hut = Hut.*repmat(norms,r,1);
    %finish update Hut
    %===========finish update user-level sentiment=================
    
    %=========================================================
    %update Sft: the feature sentiment cluster information
    TaoF = Sft' * Xut' * Sut * Hut - (Hut' * Sut') * Sut * Hut +Sft' * Xpt' * Spt * Hp - (Hp * Spt') * Spt * Hp - alpha * Sft' * (Sft - Sftw);
    TaoFplus = (abs(TaoF) + TaoF)./2;
    TaoFminus = (abs(TaoF) - TaoF)./2;
    Sft = Sft .* sqrt((Xut' * Sut * Hut + Xpt' * Spt * Hp + alpha * Sftw + Sft * TaoFminus) ./ max((((Sft * Hut') * Sut') * Sut * Hut + ((Sft * Hp') * Spt') * Spt * Hp + Sft* TaoFplus + alpha *Sft), myeps));
    % Renormalizes so columns of Sft have constant energy
    norms = sqrt(sum(Sft.^2,1));
    Sft = Sft./repmat(norms,d,1);
    
    %1. evalute the F-norm error
        %errSut(t) = sum(sum((Xut-Sut*Hut*Sft').^2));
        %errSpt(t) = sum(sum((Xpt-Spt*Hp*Sft').^2));
        %errsrt(t) = sum(sum((Xrt-Sut*Spt').^2))+errSut(t)+errSpt(t)+alpha*sum(sum((Sft-Sftw).^2))+beta*trace(Sut'*Lu*Sut);  %total error
    % 2. evaluate MIhat: normalized mutual information and accuracy:
	%tweet-level NMI
        
        for j = 1:n
            [~, res(j)] = max(Spt(j,:));
        end
        MIp(t) = MutualInfo(tlabel,res)*100;
	%tweet-level accuracy
	res = bestMap(tlabel,res);
    accyp(t) = length(find(tlabel == res))/length(tlabel)*100;
        %compute user-level NMI 
	%note that not every user has ground truth label
    count = 0;  % number of labelled user;
    for j = 1:m
        if ulabel(j) ~= -1;
            count = count +1;
        end
    end
    if count >0
        gnd = zeros (count,1);
        userres = zeros (count,1);
        index = 1;
        for j = 1:m
            if ulabel(j) ~= -1
                gnd(index) = ulabel(j);
                [~,userres(index)] = max(Sut(j,:));
                index = index +1;
            end
        end
        MIu(t) = MutualInfo(gnd,userres)*100;
        %disp('size gnd');
        %disp(length(gnd));
        %disp('size userres');
        %disp(length(userres));
        userres = bestMap(gnd,userres);
        %disp('size gnd');
        %disp(size(gnd));
        %disp('size userres');
        %disp(size(userres));
        %if(size(gnd)==size(userres))
        accyu(t) = length(find(gnd == userres))/length(gnd)*100;
        %end
    end
end
A=Sut-Supre;
[~,ind] = max(A(:));
[i,j] = ind2sub(size(A),ind);
disp(i);
disp(j);
end


