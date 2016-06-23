# Clustering and Graph Summarization on K-Partite Graphs
Clustering and Summarization Softwares on K-Partite Graphs

#Clustering
# Table of Content
- [Publication](##related-publications)
- [Code Location](##code-location)
- [Usage](##usage)
- [Q and A](##common-questions)

##Related Publications

Linhong Zhu, Aram Galstyan, James Cheng, and Kristina Lerman. Tripartite Graph Clustering for Dynamic Sentiment Analysis on Social Media. ACM SIGMOD 2014: 1531-1542.

Linhong Zhu, Aram Galstyan, James Cheng, Kristina Lerman:
Tripartite Graph Clustering for Dynamic Sentiment Analysis on Social Media. CoRR abs/1402.6010 (2014)

##Code location
The matlab implementation for clustering on Tripartite graph is located within folder Triclustering

## Usage
Matlab: 

[Su,Sp,Sf,Hu,Hp,errsu, errsp, errsr, accyu,accyp, MIu, MIp] = tricluster(Xu,Xr,Xp,Gu,Sf0,alpha,beta,tlabel, ulabel)
where:

  %n: number of tweets
  
  %m: number of users
  
  %d: number of features
  
  %r: number of clusters
  
  %Input:
  
  %Xu: user-feature matrix m X d
  
  %Xr: user-retweet matrix m X n
  
  %Xp: tweet-feature matrix n X d
  
  %Gu: user-user graph, n X n
  
  %Sf0: feature-sentiment lexicon information (d X r)
  
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
  
## Common Questions
        1. What if I do not have ground truth clusters?
        Note that tlabel and ulabel are the ground truth label information for tweet-level and user-level. They are used for performance evaluation. If we do not have any ground truth, please remove them and the corresponding lines from 148 to 171 in the tricluster.m function.
        
        2. How can we know which cluster is positive, negative or neutral?
        Each cluster is corresonding to one dimension. We can assume positive is dimension 1, negative is dimension 2 or opposite. But these assignment should keep consistant.
        
        3. How Sf0 is initilized ?
        
        For sentiment clustering with 2 clusters, if we assume positive is dimension 1, then 
        if a word i is positive, sf0(i)=[1,0]; if a word i is negative, sf0[i]=[0,1], and for other words that we do not have any prior knowledge, sf0[i]=[0.5,0.5] or sf0[i]=[0,0].
