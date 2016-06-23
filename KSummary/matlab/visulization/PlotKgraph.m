function [xmin,Ycor] = PlotKgraph(A, pattern,color,color2,center)
rng(1357);
h=figure;
set(gcf,'color','w');
%A the input tripartite graph
[k1,k2]=size(A);
 if k1~=k2
     disp('the dimension does not aggree in k-partite graph');
 end
 k=k1;
 nodesize=zeros(k,1);
 xmin=zeros(k,1);
 xmin(1)=0;
 xmin(2)=-0.02;
 xmin(3)=0.02;
 xmin(4)=0.04;
 xmin(5)=0.06;
%  for i=1:k
%      if mod(i,2)==1
%          xmin(i)=center+0.01*(i-1);
%      else
%          xmin(i)=center-0.01*(i-1);
%      end
%  end
 for i=1:k-1
     for j=(i+1):k
         G=A{i,j};
         [ni,nj]=size(G);
         if ni>1 &&nj>1
            nodesize(i)=ni;
            nodesize(j)=nj;
         end
     end
 end
 
%figure
hold on
 %plot the node,
 %remember the position of each node
 Ycor=cell(k,1);
 for i=1:k
     Ycor{i,1}=zeros(nodesize(i),1);
 end
 for i=1:k
     for n1=1:nodesize(i)
         if i~=k
            ypos=n1+rand/2;
         else
             ypos=n1/1.5+rand/2;
         end
         Ycor{i,1}(n1)=ypos;
         plot(xmin(i),ypos,pattern, 'MarkerSize', 15,'color',color{i,1});
     end
 end
 
 %plot the edge
 for i=1:k-1
     for j=(i+1):k
         G=A{i,j};
         [ni,nj]=size(G);
         if ni>1 &&nj>1
            for n1=1:ni
                for n2=1:nj
                    if G(n1,n2)>0.01
                        plot([xmin(i), xmin(j)], [Ycor{i,1}(n1), Ycor{j,1}(n2)], 'Color', color2, 'LineWidth', 1.4)
                    end
                end
                [~,index]=max(G(n1,:));
                plot([xmin(i), xmin(j)], [Ycor{i,1}(n1), Ycor{j,1}(index)], 'Color', color2, 'LineWidth', 1.4)
            end
         end
     end
 end
 axis off
 saveas(h,'Triall','fig');
 saveas(h,'Triall','eps');
end




