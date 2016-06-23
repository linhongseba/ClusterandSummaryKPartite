loaddata
alpha = 0.0:0.1:1;
beta = 0.0:0.1:1;
l1 = length(alpha);
l2 = length(beta);
bestusererr = zeros(l1,l2);
besttweeterr = zeros(l1,l2);
bestuseracc = zeros(l1,l2);
besttweetacc = zeros(l1,l2);
bestuserMI = zeros(l1,l2);
besttweetMI = zeros(l1,l2);
for i = 1:l1
    for j= 1:l2
        [~,~,~,~,~,errsu, errsp, errsr,accyu,accyp, MIu, MIp] = tricluster(Xu,Xr,Xp,Gu,F0,alpha(i),beta(j),tlabel,ulabel);
        bestusererr(i,j) = min(errsu);
        besttweeterr(i,j) = min(errsp);
        bestuseracc(i,j) = max(accyu);
        besttweetacc(i,j) = max(accyp);
        bestuserMI(i,j) = max(MIu);
        besttweetMI(i,j) = max(MIp);
    end
end
fileID = fopen('erru.txt','w');
for i=1:size(bestusererr, 1)
    fprintf(fileID, '%f ', bestusererr(i,:));
    fprintf(fileID, '\n');
end
fclose(fileID);
fileID = fopen('errp.txt','w');
for i=1:size(besttweeterr, 1)
    fprintf(fileID, '%f ', besttweeterr(i,:));
    fprintf(fileID, '\n');
end
fclose(fileID);
fileID = fopen('accu.txt','w');
for i=1:size(bestuseracc, 1)
    fprintf(fileID, '%f ', bestuseracc(i,:));
    fprintf(fileID, '\n');
end
fclose(fileID);
fileID = fopen('accp.txt','w');
for i=1:size(besttweetacc, 1)
    fprintf(fileID, '%f ', besttweetacc(i,:));
    fprintf(fileID, '\n');
end
fclose(fileID);
fileID = fopen('MIu.txt','w');
for i=1:size(bestuserMI, 1)
    fprintf(fileID, '%f ', bestuserMI(i,:));
    fprintf(fileID, '\n');
end
fclose(fileID);
fileID = fopen('MIp.txt','w');
for i=1:size(besttweetMI, 1)
    fprintf(fileID, '%f ', besttweetMI(i,:));
    fprintf(fileID, '\n');
end
fclose(fileID);
clearvars alpha beta bestusererr besttweeterr bestuseracc besttweetacc bestuserMI besttweetMI;
clearvars Xu Xr Xp Gu F0 tlabel ulabel;