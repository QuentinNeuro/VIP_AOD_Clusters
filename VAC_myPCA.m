function dataPCA=VAC_myPCA(data,threshold)
[coeffPCA,~,~,~,explainedPCA]=pca(data);
% Sum explainedPCA to get the corresponding number of coeff
sumExplainedPCA=0;
index=0;
while sumExplainedPCA<threshold
    index=index+1;
    sumExplainedPCA=sumExplainedPCA+explainedPCA(index);
end
if index<3
    indexPCA=3;
else
indexPCA=index;
end
dataPCA=coeffPCA(:,1:indexPCA);
end