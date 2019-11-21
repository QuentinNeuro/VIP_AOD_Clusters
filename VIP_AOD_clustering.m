%% Clustering based on PCA and kmeans for VIP AOD data
% Todo: (1) timecut for concat data / decimate the data ?
%       (2) label histogram
%       (3) distribution statistic
% - v 0.91 - by Quentin November 2019 - 

%% Parameters
LoadNewData=1;
ReCluster=0;
clusterNbKmeans=3;
% data massaging
decimatefactor=1;
newZscore=1;
MaxNorm=0;
% Figure
FigType='Reward';
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
thresholdexplainedPCA=85;
plotExplainedPCs=1;
TimeCut=[0 4]; % make empty for no cut

if LoadNewData
%% Initialize
% Loading new data
tic
dataLoaded=VAC_LoadData;
Timer(1)=toc;
sprintf('Loading time %.2d sec', Timer(1))
As=struct();
As.Raw.SessionNames=dataLoaded.FileList;
As.Raw.Index=dataLoaded.Index;
As.Raw.Time=dataLoaded.Time;
%As.Raw.Time=decimate(As.Raw.Time,decimatefactor);
% Z-scored data
if newZscore
DFF=dataLoaded.DFF*100;
ZscorDFF=(DFF-mean(DFF(:,2:21),2))./std(DFF(:,2:21),0,2);
dataLoaded.DFF=ZscorDFF;
end
As.Raw.Data=dataLoaded.DFF;
%As.Raw.Data=decimate(As.Raw.Data,decimatefactor)

%% Create trial types
As.(TrialTypes{1}).Index.Session=As.Raw.Index.Session;
As.(TrialTypes{1}).Index.BrainAreas=As.Raw.Index.BrainAreas;
As.(TrialTypes{1}).Time=As.Raw.Time;
As.(TrialTypes{1}).Data=dataLoaded.DFF;
% Reward
As.(TrialTypes{2}).Index.Session=As.Raw.Index.Session(As.Raw.Index.Rew1Pun0==1,:);
As.(TrialTypes{2}).Index.BrainAreas=As.Raw.Index.BrainAreas(As.Raw.Index.Rew1Pun0==1,:);
As.(TrialTypes{2}).Time=As.Raw.Time;
As.(TrialTypes{2}).Data=dataLoaded.DFF(As.Raw.Index.Rew1Pun0==1,:);
% Punish
As.(TrialTypes{3}).Index.Session=As.Raw.Index.Session(As.Raw.Index.Rew1Pun0==0,:);
As.(TrialTypes{3}).Index.BrainAreas=As.Raw.Index.BrainAreas(As.Raw.Index.Rew1Pun0==0,:);
As.(TrialTypes{3}).Time=As.Raw.Time;
As.(TrialTypes{3}).Data=dataLoaded.DFF(As.Raw.Index.Rew1Pun0==0,:);
%ConcatRewandPun
As.(TrialTypes{4}).Index.Session=As.Raw.Index.Session(As.Raw.Index.Rew1Pun0==1,:);
As.(TrialTypes{4}).Index.BrainAreas=As.Raw.Index.BrainAreas(As.Raw.Index.Rew1Pun0==1,:);
As.(TrialTypes{4}).Time=[As.Raw.Time As.Raw.Time+9+0.1];
thisrew=As.(TrialTypes{2}).Data;
thispun=As.(TrialTypes{3}).Data;
As.(TrialTypes{4}).Data=[thisrew thispun-(thispun(:,1)-thisrew(:,end))];

%% Organize data
tic
for i=1:TrialTypeNb
    thisData=As.(TrialTypes{i}).Data;
    thisTime=As.(TrialTypes{i}).Time;
    As.(TrialTypes{i}).DFF_AVG=mean(thisData,1);
    As.(TrialTypes{i}).DFF_STD=std(thisData,1);
    As.(TrialTypes{i}).Events.Names=EventNames;
    %% Events
    if i~=4
        for j=1:size(EventTimes,1)
            switch EventZero
                case 0
                    thisZeros=zeros(size(thisData,1),1);
                case 1
                    thisZeros=mean(thisData(:,thisTime>0-0.1 & thisTime<0+0.1),2);
                case 2
                    thisZeros=mean(thisData(:,thisTime>EventTimes(j,1)-0.1 & thisTime<EventTimes(j,2)+0.1),2);
            end
            As.(TrialTypes{i}).Events.Data(:,j)=mean(thisData(:,thisTime>EventTimes(j,1) & thisTime<EventTimes(j,2)),2)-thisZeros;
        end
    else % For concat
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
    end
    % TSNE
    thisTSNE=tsne(As.(TrialTypes{i}).Events.Data);
    As.(TrialTypes{i}).Events.TSNE=thisTSNE;
    %% PCA
    % Cut data according to the new timewindow
    if ~isempty(TimeCut) && i~=4
        thisPCAData=thisData(:,thisTime>TimeCut(1) & thisTime<TimeCut(2));
        thisPCAData=thisPCAData-thisPCAData(:,1);
    else thisPCAData=thisData;
    end
    if decimatefactor~=1
        thisDecimatePCAData=[];
        for j=1:size(thisPCAData,1)
        thisDecimatePCAData(j,:)=decimate(thisPCAData(j,:),decimatefactor);
        end
        thisPCAData=thisDecimatePCAData;
    end
    thisPCA=VAC_myPCA(thisPCAData',thresholdexplainedPCA,plotExplainedPCs);
    As.(TrialTypes{i}).PCA.PCs=thisPCA;
    % TSNE
    thisTSNE=tsne(thisPCA);
    As.(TrialTypes{i}).PCA.TSNE=thisTSNE;
end
Timer(2)=toc;
sprintf('Organize data %.2d sec', Timer(2))
end

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
% fig_data=VAC_Fig1(As);
%VAC_Fig2(As,FigType,clusterNbKmeans)