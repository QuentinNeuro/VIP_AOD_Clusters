function dataPCA=VAC_myPCA(data,threshold,plotExplained,minPCs)
[coeffPCA,~,~,~,explainedPCA]=pca(data);
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

if plotExplained
    sumExplainedPCA=explainedPCA(1:30);
    for i=2:30
        sumExplainedPCA(i)=sumExplainedPCA(i-1)+sumExplainedPCA(i);
    end
    figure()
    plot(0:1:30,[0;sumExplainedPCA],'-ok');
    hold on
    plot([0 indexPCA],[threshold threshold],'-r');
    plot([indexPCA indexPCA],[0 threshold],'-r');
    xlabel('# of PCs'); xlim([0 30]); ylabel('Explained Variance'); ylim([0 100])
end
end