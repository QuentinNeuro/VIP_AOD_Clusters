function VAC_Cluster_vectors(As,thisType,nbOfClusters,histo_cumul,timeCut)

%% Parameters
if nargin<4
thisType='RewAct';
nbOfClusters=5;
histo_cumul=1;
timeCut=[];
end
clusterDir=sprintf('KClusters_%.0d',nbOfClusters);
removeSession=[];
checkArea1Session0=1;
nBinHisto=30;
anovaCheck=1;
%% Data
thisTime=As.(thisType).Time ;
thisData=As.(thisType).Data;
thisClusterAVG_OG=As.(thisType).PCA.(clusterDir).DFFAVG';

if checkArea1Session0
index4sort=As.(thisType).Index.BrainAreas;
else
index4sort=As.(thisType).Index.Session;
end
% Adjust Data
if ~isempty(removeSession)
    thisSession=As.(thisType).Index.Session;
    index4sort=index4sort(thisSession~=removeSession);
    thisData=thisData(thisSession~=removeSession,:);
end

if ~isempty(timeCut)
    thisData=thisData(:,thisTime>timeCut(1) & thisTime<timeCut(2));
    thisData=thisData-thisData(:,1);
    thisClusterAVG=thisClusterAVG_OG(thisTime>timeCut(1) & thisTime<timeCut(2),:);
    thisClusterAVG=thisClusterAVG-thisClusterAVG(1,:);
else
     thisClusterAVG=thisClusterAVG_OG;
end

[index4sort_sorted,indexToSort]=sort(index4sort);
%% Processing
thisDot=thisData*thisClusterAVG;
thisDot_sorted=thisDot(indexToSort,:);

%% TSNE
% thisTSNE=tsne(thisDot);
% figure()
% gscatter(thisTSNE(:,1),thisTSNE(:,2),index4sort_sorted);

%% ANOVA
if anovaCheck
for thisCluster=1:nbOfClusters
    [anoPVal,anoTble,anoStats]=anova1(thisDot(:,thisCluster),index4sort);
    [c,~,~,gnames] = multcompare(anoStats);
end
end

%% Figure
subplot_counter=[1 2 3];

figure('Name','Cluster weight')
subplot(nbOfClusters,3,1)
hold on
title('Cluster trace')
subplot(nbOfClusters,3,2)
hold on
title('Cluster loadings')
subplot(nbOfClusters,3,3)
hold on
title('distribution')

for thisCluster=1:nbOfClusters
thisClusterName=sprintf('Cluster %.0d',thisCluster);

subplot(nbOfClusters,3,subplot_counter(1))
hold on
plot(thisTime,thisClusterAVG_OG(:,thisCluster))
ylabel(thisClusterName); xlim([-3 4]);
legend off

subplot(nbOfClusters,3,subplot_counter(2))
hold on
gscatter(1:length(index4sort_sorted),thisDot_sorted(:,thisCluster),index4sort_sorted);
legend off

subplot(nbOfClusters,3,subplot_counter(3))
hold on
if histo_cumul
    [x,y]=cumulative(thisDot_sorted(index4sort_sorted==1,thisCluster));
    plot(x,y,'-r');
    [x,y]=cumulative(thisDot_sorted(index4sort_sorted==2,thisCluster));
    plot(x,y,'-g');
    [x,y]=cumulative(thisDot_sorted(index4sort_sorted==3,thisCluster));
    plot(x,y,'-c');
    [x,y]=cumulative(thisDot_sorted(index4sort_sorted==4,thisCluster));
    plot(x,y,'-','Color',[0.4940 0.1840 0.5560]);
    ylim([0 1]);
else
histogram(thisDot_sorted(index4sort_sorted==1,thisCluster),nBinHisto,'FaceColor','-r');
histogram(thisDot_sorted(index4sort_sorted==2,thisCluster),nBinHisto,'FaceColor','-g');
histogram(thisDot_sorted(index4sort_sorted==3,thisCluster),nBinHisto,'FaceColor','-c');
histogram(thisDot_sorted(index4sort_sorted==4,thisCluster),nBinHisto,'FaceColor',[0.4940 0.1840 0.5560]);
end
legend off

subplot_counter=subplot_counter+3;
end

subplot(nbOfClusters,3,3*nbOfClusters-2)
xlabel('Time from reward (sec)');

subplot(nbOfClusters,3,3*nbOfClusters-1)
xlabel('neurons');

subplot(nbOfClusters,3,3*nbOfClusters)
xlabel('distribution');
legend(As.Raw.Index.BrainAreaNames);
end