gamma = 0.0:0.1:1;
l1 = length(gamma);
l2 = 1;
bestuseracc = zeros(l1,1);
besttweetacc = zeros(l1,1);
bestuserMI = zeros(l1,l2);
besttweetMI = zeros(l1,l2);
for i = 1:l1
    [accyp, accyu, MIp, MIu] = onlinerun2(gamma(i), 1);
    bestuseracc(i) = accyu;
    besttweetacc(i) = accyp;
    bestuserMI(i) = MIu;
    besttweetMI(i) = MIp;
end
fileID = fopen('onlineaccu4.txt','w');
fprintf(fileID,'%f\n',bestuseracc);
% for i=1:size(bestuseracc, 1)
%     fprintf(fileID, '%f ', bestuseracc(i,:));
%     fprintf(fileID, '\n');
% end
fclose(fileID);
fileID = fopen('onlineaccp4.txt','w');
fprintf(fileID,'%f\n',besttweetacc);
% for i=1:size(besttweetacc, 1)
%     fprintf(fileID, '%f ', besttweetacc(i,:));
%     fprintf(fileID, '\n');
% end
fclose(fileID);
fileID = fopen('onlineMIu4.txt','w');
fprintf(fileID,'%f\n',bestuserMI);
% for i=1:size(bestuserMI, 1)
%     fprintf(fileID, '%f ', bestuserMI(i,:));
%     fprintf(fileID, '\n');
% end
fclose(fileID);
fileID = fopen('onlineMIp4.txt','w');
fprintf(fileID,'%f\n',besttweetMI);
% for i=1:size(besttweetMI, 1)
%     fprintf(fileID, '%f ', besttweetMI(i,:));
%     fprintf(fileID, '\n');
% end
fclose(fileID);
clearvars alpha beta bestusererr besttweeterr bestuseracc besttweetacc bestuserMI besttweetMI;
clearvars Xu Xr Xp Gu F0 tlabel ulabel;