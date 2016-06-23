function [Xpt, Xut, Xrt, Gut, tlabel, ulabel,n,m] = loadminibatch(k, l)
%loadonlinedata: read the current day-k data matrices into matlab
%k: file index
%l: number of features
%Xpt: tweet-word matric
%Xut: user-word matric
%Xrt: user-tweet matric
%Gut: user-user graph
%tlabel: tweet-label
%ulabel: user-label
    tweetfilename = sprintf('./Data/minibatch/37/tweet-word-%d.txt', k);
    Xpt=load(tweetfilename);
    n=size(Xpt,1); %number of tweets
    if n==0
        Xpt=[];
        Xut=[];
        Xrt=[];
        Gut=[];
        tlabel=[];
        ulabel=[];
        m=0;
        n=0;
        return
    end
    Xpt=spconvert(Xpt);  %read tweet-feature matrix
    n=size(Xpt,1);
    [i,j,s]=find(Xpt);
    Xpt=sparse(i,j,s,n,l); %initilize tweet-feature matrix
    usefilename = sprintf('./Data/minibatch/37/user-word-%d.txt', k);
    Xut=load(usefilename);
    Xut=spconvert(Xut);  %read user-feature matrix
    RTfilename = sprintf('./Data/minibatch/37/user-retweet-%d.txt', k);
    Xrt=load(RTfilename);
    m1=size(Xrt,1);
    if m1>0
        Xrt=spconvert(Xrt);
        m1=size(Xrt,1);
    end
    m2=size(Xut,1);
    if m2>0
        Xut=spconvert(Xut);  %read user-feature matrix
        m2=size(Xut,1);
    end
    if m1<m2
        m=m2;
    else
        m=m1;
    end
    % resize the user-feature matrix and user-tweet matrix
    [i,j,s]=find(Xrt);
    Xrt=sparse(i,j,s,m,n);
	[i,j,s]=find(Xut);
    Xut=sparse(i,j,s,m,l);
    %read the user-user graph
    graphfilename = sprintf('./Data/minibatch/37/user-user-graph-%d.txt', k);
    Gut=load(graphfilename);
    [i,j,s]=find(Gut);
    Gut=sparse(i,j,s,m,m);
	clearvars i j s;
    %read the tweet-label
    tlabel=zeros(n,1);
    for i=1:size(tlabel)
        tlabel(i)=-1;
    end;
    tlabelfilename = sprintf('./Data/minibatch/37/tweetlabel-%d.txt',k);
    tweetlabel=load(tlabelfilename);
    if isempty(tweetlabel)==false
        v=tweetlabel(:,2);
        index=tweetlabel(:,1);
        for i=1:size(index)
            tlabel(index(i))=v(i);
        end;
    end
    %read the user-label
    ulabel=zeros(m,1);
    for i=1:size(ulabel)
        ulabel(i)=-1;
    end;
    ulabelfilename = sprintf('./Data/minibatch/37/userlabel-%d.txt',k);
    userlabel=load(ulabelfilename);
    if isempty(userlabel)==false
        index=userlabel(:,1);
        v=userlabel(:,2);
        for i=1:size(index)
            ulabel(index(i))=v(i);
        end;
    end
end

