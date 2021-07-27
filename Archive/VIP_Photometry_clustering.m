%% Parameters
thisPhototype='Uncued_Reward'; %'Uncued_Reward' 'CueA_Go_Hit'
thisAODtype='RewAct';

DFFAVG=0;
NbOfTrials=5;
TrialsRND=1;
TrialNBs=[];
if DFFAVG
    counter=1;
else
counter=1:NbOfTrials;
end

decimatefactor=1;
newZscore=1;
NormMax=1;
TimeCutMax=[0 4];


thresholdexplainedPCA=90;
minPCs=4;
plotExplainedPCs=1;
TimeCutPC=[0 4]; % make empty for no cut




%% LOAD
[FileList,PathName]=uigetfile('*.mat','Select Photometry Bpod data)','MultiSelect', 'on');
cd(PathName);

% Initialize
DFFa=[];
DFFb=[];

% Open Files
for i=1:length(FileList)
    thisFile=FileList{i};
    load(thisFile);
    if i==1
        Time=Analysis.(thisPhototype).Photo_470.Time(1,:);
    end
    if DFFAVG
    DFFa(counter,:)=Analysis.(thisPhototype).Photo_470.DFFAVG;
    DFFb(counter,:)=Analysis.(thisPhototype).Photo_470b.DFFAVG;
    elseif TrialsRND
        NbOfthisType=Analysis.(thisPhototype).nTrials;
        TrialNBs=ceil(NbOfthisType*rand(NbOfTrials,1))
    DFFa(counter,:)=Analysis.(thisPhototype).Photo_470.DFF(TrialNBs,:);
    DFFb(counter,:)=Analysis.(thisPhototype).Photo_470b.DFF(TrialNBs,:);
    else
    DFFa(counter,:)=Analysis.(thisPhototype).Photo_470.DFF(TrialNBs,:);
    DFFb(counter,:)=Analysis.(thisPhototype).Photo_470b.DFF(TrialNBs,:);
    end
    counter=counter+NbOfTrials;
    
end

%% Normalization
if NormMax
    if ~isempty(TimeCutMax)
    Maxa=max(DFFa(:,Time>TimeCutMax(1) & Time<TimeCutMax(2)),[],2);
    Maxb=max(DFFb(:,Time>TimeCutMax(1) & Time<TimeCutMax(2)),[],2);
    else
    Maxa=max(DFFa,[],2);
    Maxb=max(DFFb,[],2);
    end
    DFFa=DFFa./Maxa;
    DFFb=DFFb./Maxb;
end
%% PCA
if ~isempty(TimeCutPC)
    PCADataA=DFFa(:,Time>TimeCutPC(1) & Time<TimeCutPC(2));
    PCADataB=DFFb(:,Time>TimeCutPC(1) & Time<TimeCutPC(2));
    PCADataA=PCADataA-PCADataA(:,1);
    PCADataB=PCADataB-PCADataB(:,1);
else
    PCADataA=DFFa;
    PCADataB=DFFb;
end
PCAa=VAC_myPCA(PCADataA',thresholdexplainedPCA,0,minPCs);
PCAb=VAC_myPCA(PCADataB',thresholdexplainedPCA,0,minPCs);
Photo_Cluster=kmeans([PCAa ; PCAb],2);
Photo_TSNE=tsne([PCAa ; PCAb]);
figure()
subplot(1,2,1);
gscatter(Photo_TSNE(:,1),Photo_TSNE(:,2),Photo_Cluster);
%% Data from AOD
AOD_PCA=As.(thisAODtype).PCA.PCs;
AOD_TSNE=As.(thisAODtype).PCA.TSNE;
AOD_Cluster=As.(thisAODtype).PCA.KClusters_5.Index;

%% new tsne
AOD_Photo_PCA=[AOD_PCA ; PCAa ; PCAb];
AOD_Photo_TSNE=tsne(AOD_Photo_PCA);
AOD_Cluster_Photo=[AOD_Cluster ; 6*ones(size(PCAa,1),1); 7*ones(size(PCAb,1),1)];

%% Figure
subplot(1,2,2);
gscatter(AOD_Photo_TSNE(:,1),AOD_Photo_TSNE(:,2),AOD_Cluster_Photo);
ylabel('Clusters');legend('off')
