function [cost] = TriclusterandVisual(A,clusternum)
[B,C,cost] = fuzzygraphclustering(A,'clusters',clusternum);
h=figure;
set(gcf,'color','w');
[x1,y1]=Plottrigraph(A,'.','b',[0.7,0.7,0.7],0);
[x2,y2]=Plottrigraph(B,'s','r',[0,0,0],-0.1);
Plotnode2cluster(C,x1,x2,y1,y2);
saveas(h,'Tritoy','fig');
saveas(h,'Tritoy','png');
end
