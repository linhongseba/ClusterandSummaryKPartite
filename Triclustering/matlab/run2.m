t = cputime;
loaddata
alpha=0.8;
beta=0.1;
[~,~,~,~,~,errsu1, errsp1, errsr1,accyu1,accyp1, MIu1, MIp1] = tricluster(Xu,Xr,Xp,Gu,F0,alpha,beta,tlabel,ulabel);
clearvars Xu Xr Xp Gu F0;
[user sys] = memory;
disp(user.MemUsedMATLAB/1024/1024);
e=cputime-t;
disp('running time(s):');    disp(e);
