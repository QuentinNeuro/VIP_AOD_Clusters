function As=VAC_Concat(As,TrialTypes,EventTimes_Concat,EventZero,decimatefactor)

As.(TrialTypes{4}).Time=[As.Raw.Time As.Raw.Time+9+0.1];
thisrew=As.(TrialTypes{2}).Data;
thispun=As.(TrialTypes{3}).Data;
As.(TrialTypes{4}).Data=[thisrew thispun-(thispun(:,1)-thisrew(:,end))];
% Events
thisTime=As.(TrialTypes{4}).Time;
thisData=As.(TrialTypes{4}).Data;
As.(TrialTypes{4}).DFF_AVG=mean(thisData,1);
As.(TrialTypes{4}).DFF_STD=std(thisData,1);
for j=1:size(EventTimes_Concat,1)
switch EventZero
    case 0
        thisZeros=zeros(size(thisData,1),1);
    case 1
        thisZeros=mean(thisData(:,thisTime>0-0.1 & thisTime<0+0.1),2);
    case 2
        thisZeros=mean(thisData(:,thisTime>EventTimes_Concat(j,1)-0.1 & thisTime<EventTimes_Concat(j,2)+0.1),2);
end
As.(TrialTypes{4}).Events.Data(:,j)=mean(thisData(:,thisTime>EventTimes_Concat(j,1) & thisTime<EventTimes_Concat(j,2)),2)-thisZeros;
end
% PCs
thisPCAData=thisData;
if decimatefactor~=1
    thisDecimatePCAData=[];
    for j=1:size(thisPCAData,1)
    thisDecimatePCAData(j,:)=decimate(thisPCAData(j,:),decimatefactor);
    end
    thisPCAData=thisDecimatePCAData;
end
thisPCA=VAC_myPCA(thisPCAData',thresholdexplainedPCA,plotExplainedPCs,minPCs);
As.(TrialTypes{4}).PCA.PCs=thisPCA;
% TSNE
As.(TrialTypes{4}).Events.TSNE=tsne(As.(TrialTypes{4}).Events.Data);
As.(TrialTypes{4}).PCA.TSNE=tsne(As.(TrialTypes{4}).PCA.PCs);

end