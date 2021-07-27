function [dataPCA,scoreOut]=VAC_myPCA(data,threshold,plotExplained,minPCs)
[coeffPCA,score,latent,~,explainedPCA]=pca(data);
% Sum explainedPCA to get the corresponding number of coeff
sumExplainedPCA=0;
index=0;
while sumExplainedPCA<threshold
    index=index+1;
    sumExplainedPCA=sumExplainedPCA+explainedPCA(index);
end
if index<minPCs
    indexPCA=minPCs;
else
indexPCA=index;
end
dataPCA=coeffPCA(:,1:indexPCA);
scoreOut=score(:,1:indexPCA);

if plotExplained
    sumExplainedPCA=explainedPCA;
    for i=2:length(sumExplainedPCA)
        sumExplainedPCA(i)=sumExplainedPCA(i-1)+sumExplainedPCA(i);
    end
    if length(sumExplainedPCA)<20
        n=length(sumExplainedPCA);
    else
        n=20;
    end
    figure('Name','PCA variance','NumberTitle','off');
    plot(0:1:n,[0 ; sumExplainedPCA(1:n)],'-ok');
    hold on
    plot([0 indexPCA],[threshold threshold],'-r');
    plot([indexPCA indexPCA],[0 threshold],'-r');
    xlabel('# of PCs'); xlim([0 30]); ylabel('Explained Variance'); ylim([0 100])
end
end