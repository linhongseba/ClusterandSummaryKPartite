gamma = 0.0:0.1:1;
tau = 0.0:0.1:1;
l1 = length(gamma);
l2 = length(tau);
bestuseracc = zeros(l1,l2);
besttweetacc = zeros(l1,l2);
bestuserMI = zeros(l1,l2);
besttweetMI = zeros(l1,l2);
for i = 1:l1
    for j= 1:l2
        [accyp, accyu, MIp, MIu] = onlinerun2(gamma(i), tau(j));
        bestuseracc(i,j) = accyu;
        besttweetacc(i,j) = accyp;
        bestuserMI(i,j) = MIu;
        besttweetMI(i,j) = MIp;
    end
end
fileID = fopen('onlineaccu3.txt','w');
for i=1:size(bestuseracc, 1)
    fprintf(fileID, '%f ', bestuseracc(i,:));
    fprintf(fileID, '\n');
end
fclose(fileID);
fileID = fopen('onlineaccp3.txt','w');
for i=1:size(besttweetacc, 1)
    fprintf(fileID, '%f ', besttweetacc(i,:));
    fprintf(fileID, '\n');
end
fclose(fileID);
fileID = fopen('onlineMIu3.txt','w');
for i=1:size(bestuserMI, 1)
    fprintf(fileID, '%f ', bestuserMI(i,:));
    fprintf(fileID, '\n');
end
fclose(fileID);
fileID = fopen('onlineMIp3.txt','w');
for i=1:size(besttweetMI, 1)
    fprintf(fileID, '%f ', besttweetMI(i,:));
    fprintf(fileID, '\n');
end
fclose(fileID);
clearvars alpha beta bestusererr besttweeterr bestuseracc besttweetacc bestuserMI besttweetMI;
clearvars Xu Xr Xp Gu F0 tlabel ulabel;