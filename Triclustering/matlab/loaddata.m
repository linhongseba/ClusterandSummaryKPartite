load ./Data/30/tweet-word-30.txt;
Xp=spconvert(tweet_word_30);
n=size(Xp,1); %number of tweets
l=size(Xp,2); %number of features
clearvars tweet_word_30; %clear variable from memory
load ./Data/30/user-retweet-30.txt;
Xr=spconvert(user_retweet_30);
load ./Data/30/user-word-30.txt;
Xu=spconvert(user_word_30);
m1=size(Xr,1);
m2=size(Xu,1);
if m1<m2
    m=m2;
else
    m=m1;
end
[i,j,s]=find(Xr);
Xr=sparse(i,j,s,m,n);
clearvars user_retweet_30 m1 m2;
[i,j,s]=find(Xu);
Xu=sparse(i,j,s,m,l);
clearvars user_word_30;
load ./Data/30/user-user-graph-30.txt
Gu=spconvert(user_user_graph_30);
[i,j,s]=find(Gu);
Gu=sparse(i,j,s,m,m);
clearvars i j s user_user_graph_30;
%load label information
ulabel=zeros(m,1);
for i=1:size(ulabel)
    ulabel(i)=-1;
end;
load ./Data/30/userlabel-30.txt
index=userlabel_30(:,1);
v=userlabel_30(:,2);
for i=1:size(index)
    ulabel(index(i))=v(i);
end;
clearvars userlabel_30;
tlabel=zeros(n,1);
for i=1:size(tlabel)
    tlabel(i)=-1;
end;
load ./Data/30/tweetlabel-30.txt
v=tweetlabel_30(:,2);
index=tweetlabel_30(:,1);
for i=1:size(index)
    tlabel(index(i))=v(i);
end;
clearvars tweetlabel_30;
clear v index;
load ./Data/30/Sf0.txt
F0 = spconvert(Sf0);
clearvars Sf0

 