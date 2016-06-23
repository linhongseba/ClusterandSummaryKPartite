function [Su,Sp,Sf,Hu,Hp,errsu, errsp, errsr, accyu,accyp, MIu, MIp] = tricluster(Xu,Xr,Xp,Gu,Sf0,alpha,beta,tlabel, ulabel)
%tricluster Summary of this function:
  %perform co-clustering for tweet, user, and features (words)
  %n: number of tweets
  %m: number of users
  %d: number of features
  %r: number of clusters
  %Input:  
  %Xu: user-feature matrix m X d
  %Xr: user-retweet matrix m X n
  %Xp: tweet-feature matrix n X d
  %Gu: user-user graph, n X n
  %Sf0: feature-sentiment lexicon information
  %tlabel: ground truth for tweet-cluster
  %ulabel: groupd truth for user-cluster
  %hyperparameter: alpha and beta
  %output: 
  %Su: user-cluster matrix m X r
  %Sp: tweet-cluster matrix n X r
  %Sf: feature-cluster matrix d X r
  %errsu: user-level approximation error
  %errsp: tweet-level approximation error
  %errsr: total approximation error
  %accyu: user-level accuracy of each iteration
  %accyp :tweet-level accuracy of each iteration
  %MIu: user-level MI of each iteration
  %MIp: tweet-level MI of each iteration
%end 
r=2; %number of clusters, here we have 2 classes, positive and negative
niter=50;  %total number of iteration
errsu = zeros(niter,1);  %user-level error of each iteration
errsp = zeros(niter,1);  %tweet-level error of each iteration
errsr = zeros (niter,1); %total error of each iteration
accyu = zeros(niter,1);  %user-level accuracy of each iteration
accyp = zeros(niter,1);  %tweet-level accuracy of each iteration
MIu = zeros(niter,1);    %user-level MI of each iteration
MIp = zeros(niter,1);    %tweet-level MI of each iteration

myeps = 1e-30;
n=size(Xp,1); %number of tweets;
m=size(Xu,1); %number of users;
d=size(Xp,2); %number of features;
%=== initialized user-clusters using Kmeans========
res = kmeans(Xu,r,'emptyaction','singleton');
Su = zeros(m,r); %user-sentiment cluster information m X r (r=2);
for i = 1:m
    Su(i,res(i)) = 1;
end
Su = Su+0.2;

%===end of initialization for Su
disp('finish user initialization');
Su = sparse(Su);
%========== initialized feature-clusters==============
Sf=Sf0;
Sf = sparse(Sf);
%===end of initialization for Sf
disp('finish feature initialization');
%===initialize Hu using analytical expression
Hu =((Su' * Su)\(Su' *Xu *Sf))/(Sf'*Sf);
Hu = (abs(Hu)+Hu)/2;
%Hu = ((Su' * Su)\Su' * Xu * Sf)/(Sf'*Sf);
%Hu = (abs(Hu)+Hu)/2;
%===initialize Hu using analytical expression
disp('finish Hu initialization');
%===========initialized tweet-clusters using Kmeans=========
Sp = zeros(n,r); %tweet-sentiment cluster information m X r (r=2);
for i = 1:n
    thres1=Xp(i,1)+Xp(i,3);
    thres2=Xp(i,2)+Xp(i,4);
    if thres1>thres2&&thres1>0
        Sp(i,1) = 1;
    else
        if thres1<thres2&&thres2>0
            Sp(i,2)=1;
        else
            Sp(i,1) = 0.5;
            Sp(i,2) = 0.5;
        end
    end
end
Sp = sparse(Sp);
%end of initialization for Sp

%===initialize Hp using analytical expression
Hp = ((Sp' * Sp)\(Sp' * Xp * Sf))/(Sf'*Sf);
Hp = (abs(Hp)+Hp)/2;
%===initialize Hp using analytical expression
disp('finish tweet initialization');
%initialize Du and Lu
Du = diag(sum(Gu));
Du = sparse(Du);
Lu = Du - Gu;
Lu = sparse (Lu);
res = zeros(n,1);
count = 0;  % number of labelled user;
for j = 1:m
    if ulabel(j) ~= -1
        count = count +1;
    end
end
gnd = zeros (count,1);
userres = zeros (count,1);
for t = 1:niter
    
    %========================================================
    %update Sp the tweet-level sentiment cluster information
    Sp = Sp .*sqrt((Xp * Sf * Hp' + Xr' * Su) ./ max ((((Sp * Hp) * Sf') * Sf * Hp'+ (Sp * Su') * Su),myeps));
     % Renormalizes so columns of Sp have constant energy
    norms = sqrt(sum(Sp.^2,1));
    Sp = Sp./repmat(norms,n,1);
    %update Hp
    Hp = Hp .*sqrt((Sp'*Xp*Sf) ./max(((((Sp' * Sp) * Hp) *Sf') *Sf),myeps));
    Hp = Hp.*repmat(norms,r,1);
    %finish update Hp
    %===========finish update tweet-level sentiment=================
    
    
    %=================================================================
    %update Su the user-level sentiment cluster information
    TaoU = Su' * Xu * Sf * Hu' - ((Hu * Sf') * Sf) * Hu' +Su' * Xr *Sp -Sp' * Sp - beta * Su' * Lu * Su;
    TaoUplus = (abs(TaoU) + TaoU)./2;
    TaoUminus = (abs(TaoU) - TaoU)./2;
    Su = Su .* sqrt((Xu * Sf * Hu' + Xr * Sp+beta * Gu * Su + Su* TaoUminus) ./ max((((Su * Hu) * Sf') * Sf * Hu' + ((Su * Sp') * Sp) + beta *Du * Su + Su * TaoUplus), myeps));
    % Renormalizes so columns of Su have constant energy
    norms = sqrt(sum(Su.^2,1));
    Su = Su./repmat(norms,m,1);
    %update Hu
    Hu = Hu .* sqrt(((Su' * Xu * Sf) ./ max((((Su' * Su) * Hu) * Sf') * Sf, myeps)));
    Hu = Hu.*repmat(norms,r,1);
    %finish update Hu
    %===========finish update user-level sentiment=================
    
    %=========================================================
    %update Sf: the feature sentiment cluster information
    TaoF = Sf' * Xu' * Su * Hu - (Hu' * Su') * Su * Hu +Sf' * Xp' * Sp * Hp - (Hp * Sp') * Sp * Hp - alpha * Sf' * (Sf - Sf0);
    TaoFplus = (abs(TaoF) + TaoF)./2;
    TaoFminus = (abs(TaoF) - TaoF)./2;
    Sf = Sf .* sqrt((Xu' * Su * Hu + Xp' * Sp * Hp + alpha * Sf0 + Sf * TaoFminus) ./ max((((Sf * Hu') * Su') * Su * Hu + ((Sf * Hp') * Sp') * Sp * Hp + Sf* TaoFplus + alpha *Sf), myeps));
    % Renormalizes so colloums of Sf have constant energy
    norms = sqrt(sum(Sf.^2,1));
    Sf = Sf./repmat(norms,d,1);
    
    %1. evaluate the F-norm error
        %errsu(t) = sum(sum((Xu-Su*Hu*Sf').^2));
        %errsp(t) = sum(sum((Xp-Sp*Hp*Sf').^2));
        %errsr(t) = sum(sum((Xr-Su*Sp').^2))+errsu(t)+errsp(t)+alpha*sum(sum((Sf-Sf0).^2))+beta*trace(Su'*Lu*Su);  %total error
    % 2. evaluate MIhat: normalized mutual information and accuracy:
	%tweet-level NMI
        for j = 1:n
            [~, res(j)] = max(Sp(j,:));
        end
        MIp(t) = MutualInfo(tlabel,res)*100;
	%tweet-level accuracy
	res = bestMap(tlabel,res);
    accyp(t) = length(find(tlabel == res))/length(tlabel)*100;
    %compute user-level NMI 
	%note that not every user has ground truth label
	count = 1;
	for j = 1:m
		if ulabel(j) ~= -1
			gnd(count) = ulabel(j);
			[~,userres(count)] = max(Su(j,:));
			count = count +1;
		end
	end
    MIu(t) = MutualInfo(gnd,userres)*100;
    %user-level accuracy
	userres = bestMap(gnd,userres);
    accyu(t) = length(find(gnd == userres))/length(gnd)*100;
    disp(t);
end

