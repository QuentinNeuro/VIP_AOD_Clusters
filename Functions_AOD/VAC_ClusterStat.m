% function As=VAC_ClusterStat(As)
thisType='RewAct';
thisClusterType='KClusters_5';
thisData=As.(thisType).PCA.PCs;
thisCluster=As.(thisType).PCA.(thisClusterType).Index;
thisKMethod='kmeans';
ClusterNbs=[1:10];
thisEvalTypes={'CalinskiHarabasz' 'DaviesBouldin' 'gap' 'silhouette'}; %'CalinskiHarabasz' 'DaviesBouldin' 'gap' 'silhouette'
thisNbofEval=size(thisEvalTypes,2);
thisDistance={}; %'sqEuclidean' 'Euclidean' 'cityblock' 'cosine' 'correlation'

%% Eval and plot
figure('Name','PCA_plot','NumberTitle','off')
subplot(1,3,1)
gscatter(thisData(:,1),thisData(:,2),thisCluster)
xlabel('PC1'); ylabel('PC2');
subplot(1,3,2)
gscatter(thisData(:,2),thisData(:,3),thisCluster)
xlabel('PC2'); ylabel('PC3');
subplot(1,3,3)
gscatter(thisData(:,3),thisData(:,4),thisCluster)
xlabel('PC3'); ylabel('PC4');

figure('Name','ClusterEvaluation','NumberTitle','off')
for i=1:thisNbofEval
eva = evalclusters(thisData,thisKMethod,thisEvalTypes{i},'KList',ClusterNbs);
subplot(1,thisNbofEval,i)
plot(eva);
end