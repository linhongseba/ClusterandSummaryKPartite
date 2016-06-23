function [ Supre] = InitSu(Xut, m)
%InitSu:
    %InitSu based on the first four features of Xut
    % feature 1: positive words
    % feature 2: negative words
    % feature 3: positive emoticon
    % feature 4: negative emoticon
    Supre = zeros(m,2); %user-sentiment cluster information m X r (r=2);
    for i = 1:m
        thres1=Xut(i,1)+Xut(i,3);
        thres2=Xut(i,2)+Xut(i,4);
        if thres1>thres2&&thres1>0
            Supre(i,1) = 1;
        else
            if thres1<thres2&&thres2>0
                Supre(i,2)=1;
            else
                Supre(i,1) = 0.5;
                Supre(i,2) = 0.5;
            end
        end
    end
    %end of initilization for Supre
end

