function [ ] = Plotnode2cluster(C,Xmin1,Xmin2,Ycor1,Ycor2, color)
%Xmin1: the x coordiante of nodes
%Ycor1: the y coordiante of nodes
%Xmin2: the x coordinate of clusters
%Ycor2: the y coordinate of clusters
[k,k2]=size(C);
 for i=1:k
     G=C{i,1};
     [ni,nj]=size(G);
      for n1=1:ni
          for n2=1:nj
              if G(n1,n2)>0.1
                  plot([Xmin1(i), Xmin2(i)], [Ycor1{i,1}(n1), Ycor2{i,1}(n2)], 'Color', color{i,1}, 'LineWidth', G(n1,n2));
              end
          end
      end
 end
end

