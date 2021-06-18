function As=VAC_kmeans(As,thisTrialType,thisDataType,clusterNbKmeans)
% Parameter-ish
    thisData=As.(thisTrialType).Data;
    thisClusterNbName=sprintf('KClusters_%.0d',clusterNbKmeans);
    switch thisDataType
        case 'Events'
            thisDataPath='Data';
        case 'PCA'
            thisDataPath='PCs';
    end
% doing its stuff
    thisIndexK=kmeans(As.(thisTrialType).(thisDataType).(thisDataPath),clusterNbKmeans,'Replicates',5);
    As.(thisTrialType).(thisDataType).(thisClusterNbName).Index=thisIndexK;
% generating avg fluo traces
    for j=1:clusterNbKmeans
        As.(thisTrialType).(thisDataType).(thisClusterNbName).DFFAVG(j,:)=mean(thisData(thisIndexK==j,:),1);
        As.(thisTrialType).(thisDataType).(thisClusterNbName).DFFSTD(j,:)=std(thisData(thisIndexK==j,:),1);
    end
end

