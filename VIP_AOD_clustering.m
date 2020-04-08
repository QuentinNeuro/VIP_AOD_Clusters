%% Clustering based on PCA and kmeans for VIP AOD data
% Todo: (1) timecut for concat data / decimate the data ?
%       (2) label histogram
%       (3) distribution statistic
% - v 0.92 by Quentin November 2019 - 

%% Parameters
LoadNewData=1;
ReCluster=0;
clusterNbKmeans=5;
% data massaging
smoothing=0;
smoothingBef1After0Norm=0;
decimatefactor=1;
newZscore=1;
NormMax=1;
TimeCutMax=[0 4];
% Figure
Figures=1;
figType='RewAct';
figClusterNb=5;
figNbOfPC=3;
% Trialtype names
TrialTypes={'All','Reward','Punish','ConcatRewPun'}; % cannot really change these types. Types 1 and 4 are hard coded in multiple places
TrialTypeNb=size(TrialTypes,2);
% Events to calculate cue and reinf responses 
EventZero=2; %0 no zeroing - 1 zero at reinf - 2 zero at begining of timewindow.
EventNames={'Cue','Reinf_Early','Reinf_Med','Reinf_Late'};
EventTimes=[-1 0 ; 0 1 ; 1 3 ; 3 6];
EventNames_Concat={'Cue1','RewardAVG','RewardMax','Cue2','PunishAVG','PunishMax'}; % Used for trial type 4, concat of rew and punish trials.
EventTimes_Concat=[-1 0 ; 0 3 ; 0 6 ; 8.1 9.1;9.1 12.1; 9.1 15.1];
% PCA parameters
thresholdexplainedPCA=90;
minPCs=4;
plotExplainedPCs=1;
TimeCutPC=[0 4]; % make empty for no cut
% Cells to remove


if LoadNewData
%% Initialize
% Loading new data into Raw substructure
tic
dataLoaded=VAC_LoadData;
Timer(1)=toc;
sprintf('Loading time %.2d sec', Timer(1))
As=struct();
As.Raw.SessionNames=dataLoaded.FileList;
As.Raw.Index=dataLoaded.Index;
As.Raw.Time=dataLoaded.Time;
As.Raw.Data=dataLoaded.DFF;
end
% Initiate the indices for the cell/trial types
As.(TrialTypes{1}).Index.Session=As.Raw.Index.Session;
As.(TrialTypes{1}).Index.BrainAreas=As.Raw.Index.BrainAreas;
As.(TrialTypes{1}).Index.Cells=As.Raw.Index.Rew1Pun0==1 | As.Raw.Index.Rew1Pun0==0;
% Reward
As.(TrialTypes{2}).Index.Cells=As.Raw.Index.Rew1Pun0==1;
As.(TrialTypes{2}).Index.Session=As.Raw.Index.Session(As.(TrialTypes{2}).Index.Cells);
As.(TrialTypes{2}).Index.BrainAreas=As.Raw.Index.BrainAreas(As.(TrialTypes{2}).Index.Cells);
% Punish
As.(TrialTypes{3}).Index.Cells=As.Raw.Index.Rew1Pun0==0;
As.(TrialTypes{3}).Index.Session=As.Raw.Index.Session(As.(TrialTypes{3}).Index.Cells);
As.(TrialTypes{3}).Index.BrainAreas=As.Raw.Index.BrainAreas(As.(TrialTypes{3}).Index.Cells);
%ConcatRewandPun
As.(TrialTypes{4}).Index.Cells=As.Raw.Index.Rew1Pun0==1;
As.(TrialTypes{4}).Index.Session=As.Raw.Index.Session(As.(TrialTypes{4}).Index.Cells);
As.(TrialTypes{4}).Index.BrainAreas=As.Raw.Index.BrainAreas(As.(TrialTypes{4}).Index.Cells);


%% Compute new zs or max norm
Timer(1)=tic;
thisRawData=As.Raw.Data;
thisRawTime=As.Raw.Time;

if smoothing && smoothingBef1After0Norm
    for i=1:size(thisRawData,1)
        thisRawData(i,:)=smooth(thisRawData(i,:));
    end
end

if newZscore
thisRawData=thisRawData*100;
thisRawData=(thisRawData-mean(thisRawData(:,2:21),2))./std(thisRawData(:,2:21),0,2);
end

if NormMax
    if ~isempty(TimeCutMax)
    thisMax=max(thisRawData(:,thisRawTime>TimeCutMax(1) & thisRawTime<TimeCutMax(2)),[],2);
    else
    thisMax=max(thisRawData,[],2);
    end
    thisRawData=thisRawData./thisMax;
end

if smoothing && ~smoothingBef1After0Norm
    for i=1:size(thisRawData,1)
        thisRawData(i,:)=smooth(thisRawData(i,:));
    end
end
%% Organize data, create AVG traces, PCs and TSNE for 3 starting types
for i=1:4
% Data   
if i~=4
thisTime=As.Raw.Time;
thislogical=As.(TrialTypes{i}).Index.Cells;
thisData=thisRawData(thislogical,:);
else
    thisTime=[As.Raw.Time As.Raw.Time+9+0.1];
    thisrew=As.(TrialTypes{2}).Data;
    thispun=As.(TrialTypes{3}).Data;
    thisData=[thisrew thispun-(thispun(:,1)-thisrew(:,end))];
end
% AVG,STD
As.(TrialTypes{i}).Time=thisTime;
As.(TrialTypes{i}).Data=thisData;
As.(TrialTypes{1}).DFF_AVG=mean(thisData,1);
As.(TrialTypes{1}).DFF_STD=std(thisData,1);

% Events and PCs
if i==1
As.(TrialTypes{i}).Events.Names=EventNames;
for j=1:size(EventTimes,1)
    switch EventZero
        case 0
            thisZeros=zeros(size(thisData,1),1);
        case 1
            thisZeros=mean(thisData(:,thisTime>0-0.1 & thisTime<0+0.1),2);
        case 2
            thisZeros=mean(thisData(:,thisTime>EventTimes(j,1)-0.1 & thisTime<EventTimes(j,2)+0.1),2);
    end
    As.(TrialTypes{1}).Events.Data(:,j)=mean(thisData(:,thisTime>EventTimes(j,1) & thisTime<EventTimes(j,2)),2)-thisZeros;
end
% PCs
if ~isempty(TimeCutPC)
    thisPCAData=thisData(:,thisTime>TimeCutPC(1) & thisTime<TimeCutPC(2));
    thisPCAData=thisPCAData-thisPCAData(:,1);
else
    thisPCAData=thisData;
end
if decimatefactor~=1
    thisDecimatePCAData=[];
    for j=1:size(thisPCAData,1)
    thisDecimatePCAData(j,:)=decimate(thisPCAData(j,:),decimatefactor);
    end
    thisPCAData=thisDecimatePCAData;
end
thisPCA=VAC_myPCA(thisPCAData',thresholdexplainedPCA,plotExplainedPCs,minPCs);
As.(TrialTypes{1}).PCA.PCs=thisPCA;
% Reward/Pun
elseif i~=4
As.(TrialTypes{i}).Events.Names=EventNames;
As.(TrialTypes{i}).Events.Data=As.(TrialTypes{1}).Events.Data(thislogical,:);
As.(TrialTypes{i}).PCA.PCs=As.(TrialTypes{1}).PCA.PCs(thislogical,:);

% Concat
else
for j=1:size(EventTimes_Concat,1)
switch EventZero
    case 0
        thisZeros=zeros(size(thisData,1),1);
    case 1
        thisZeros=mean(thisData(:,thisTime>0-0.1 & thisTime<0+0.1),2);
    case 2
        thisZeros=mean(thisData(:,thisTime>EventTimes_Concat(j,1)-0.1 & thisTime<EventTimes_Concat(j,2)+0.1),2);
end
As.(TrialTypes{i}).Events.Data(:,j)=mean(thisData(:,thisTime>EventTimes_Concat(j,1) & thisTime<EventTimes_Concat(j,2)),2)-thisZeros;
end 
% PCs
if ~isempty(TimeCutPC)
    thisPCAData=thisData(:,thisTime>TimeCutPC(1) & thisTime<TimeCutPC(2));
    thisPCAData=thisPCAData-thisPCAData(:,1);
else
    thisPCAData=thisData;
end
if decimatefactor~=1
    thisDecimatePCAData=[];
    for j=1:size(thisPCAData,1)
    thisDecimatePCAData(j,:)=decimate(thisPCAData(j,:),decimatefactor);
    end
    thisPCAData=thisDecimatePCAData;
end
thisPCA=VAC_myPCA(thisPCAData',thresholdexplainedPCA,plotExplainedPCs,minPCs);
As.(TrialTypes{i}).PCA.PCs=thisPCA;
end

% TSNE
As.(TrialTypes{i}).Events.TSNE=tsne(As.(TrialTypes{i}).Events.Data);
As.(TrialTypes{i}).PCA.TSNE=tsne(As.(TrialTypes{i}).PCA.PCs);
end


%% Organize data, create AVG traces, PCs and TSNE for other subgroups (concat and responsive cells)
As=VAC_ResponsiveCells(As);

%% Clustering and matching
thisClusterNbName=sprintf('KClusters_%.0d',clusterNbKmeans);
if ~isfield(As.All.Events,thisClusterNbName) || ReCluster
tic
for i=1:TrialTypeNb
    As=VAC_kmeans(As,TrialTypes{i},'Events',clusterNbKmeans);
    As=VAC_IndexMatch(As,TrialTypes{i},'Events',clusterNbKmeans);
    As=VAC_kmeans(As,TrialTypes{i},'PCA',clusterNbKmeans);
    As=VAC_IndexMatch(As,TrialTypes{i},'PCA',clusterNbKmeans);
end
Timer(3)=toc;
sprintf('Generate Clusters %.2d sec', Timer(3))
end
%% figure
if Figures
% fig_data=VAC_Fig1(As);
As=VAC_Fig2(As,figType,figClusterNb);
VAC_PCA_vectors(As,figType,figNbOfPC,1,0);
VAC_Cluster_vectors(As,figType,figClusterNb,1,[0 4]);
end