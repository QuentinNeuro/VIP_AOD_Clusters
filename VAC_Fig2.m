function [As,figData]=VAC_Fig2(As,thistype,clusterNbKmeans)
%% Sanity check
thisClusterNbName=sprintf('KClusters_%.0d',clusterNbKmeans);
if ~isfield(As.All.Events,thisClusterNbName)
    disp('Warning, requested cluster does not exist... computing in progress')
    As=VAC_kmeans(As,thistype,'Events',clusterNbKmeans);
    As=VAC_IndexMatch(As,thistype,'Events',clusterNbKmeans);
    As=VAC_kmeans(As,thistype,'PCA',clusterNbKmeans);
    As=VAC_IndexMatch(As,thistype,'PCA',clusterNbKmeans);
end
%% Data
    thisTime=As.(thistype).Time;
    thisData=As.(thistype).Data;
    thisSessionIndex=As.(thistype).Index.Session;
    yraster=1:size(thisData,1);
    thisPCA=As.(thistype).PCA.PCs;
    thisPCA_IndexK=As.(thistype).PCA.(thisClusterNbName).Index;
    thisPCA_TSNE=As.(thistype).PCA.TSNE;
    thisPCA_DFFAVG=As.(thistype).PCA.(thisClusterNbName).DFFAVG;
    thisPCA_DFFSTD=As.(thistype).PCA.(thisClusterNbName).DFFSTD;
    thisPCA_SessionMatchNames=As.(thistype).PCA.(thisClusterNbName).IndexMatch.Name;
    thisPCA_SessionMatchProba=As.(thistype).PCA.(thisClusterNbName).IndexMatch.Proba;
    thisEVENTS=As.(thistype).Events.Data;
    thisEVENTS_IndexK=As.(thistype).Events.(thisClusterNbName).Index;
    thisEVENTS_TSNE=As.(thistype).Events.TSNE;
    thisEVENTS_DFFAVG=As.(thistype).Events.(thisClusterNbName).DFFAVG;
    thisEVENTS_DFFSTD=As.(thistype).Events.(thisClusterNbName).DFFSTD;
    thisEVENTS_SessionMatchNames=As.(thistype).Events.(thisClusterNbName).IndexMatch.Name;
    thisEVENTS_SessionMatchProba=As.(thistype).Events.(thisClusterNbName).IndexMatch.Proba;

    color4plot='brgcy';
%% Figure
fig_data=figure('Name',thistype,'NumberTitle','off');
% Raster with all trials
subplot(6,2,[1 2])
imagesc(thisTime,yraster,thisData,[-20 20]);
xlabel('Time from reinf (sec)'); ylabel('Trial Nb');xlim([-3 4]);
% AVG traces for Events-clusters and PCA-based clusters
subplot(6,2,3)
hold on
if size(thisEVENTS_DFFAVG,1)<3
for i=1:size(thisEVENTS_DFFAVG,1)
    hs=shadedErrorBar(thisTime,thisEVENTS_DFFAVG(i,:),thisEVENTS_DFFSTD(i,:),['-' color4plot(i)],1);
    hp(i)=hs.mainLine;
    thislegend{i}=sprintf('cluster %.0d',i);
end
else
    plot(thisTime,thisEVENTS_DFFAVG);
end
title('Events'); xlabel('Time from reinf (sec)'); ylabel('Z-score fluo'); xlim([-3 4]);
subplot(6,2,4)
hold on
if size(thisPCA_DFFAVG,1)<3
for i=1:size(thisPCA_DFFAVG,1)
    hs=shadedErrorBar(thisTime,thisPCA_DFFAVG(i,:),thisPCA_DFFSTD(i,:),['-' color4plot(i)],1);
    hp(i)=hs.mainLine;
    thislegend{i}=sprintf('cluster %.0d',i);
end
else
    plot(thisTime,thisPCA_DFFAVG);
end
title('PCA'); xlabel('Time from reinf (sec)'); ylabel('Z-score fluo'); xlim([-3 4]);

TicksNb=1:1:size(thisEVENTS_SessionMatchNames,2);
TicksNames=thisEVENTS_SessionMatchNames;
subplot(6,2,5)
bar(thisEVENTS_SessionMatchProba,'stack');
hold on
ylim([0 1.1]); ylabel('% of each cluster');
title('Distribution');
xticks(TicksNb); 
xticklabels(TicksNames);
xtickangle(45);

subplot(6,2,6)
bar(thisPCA_SessionMatchProba,'stack');
hold on
ylim([0 1.1]); ylabel('% of each cluster');
title('Distribution');
xticks(TicksNb); 
xticklabels(TicksNames);
xtickangle(45);

% TSNEs
subplot(6,2,7)
gscatter(thisEVENTS_TSNE(:,1),thisEVENTS_TSNE(:,2),thisEVENTS_IndexK,color4plot);
title('t-SNE'); ylabel('Clusters Events');legend('off')

subplot(6,2,8)
gscatter(thisPCA_TSNE(:,1),thisPCA_TSNE(:,2),thisPCA_IndexK,color4plot);
title('t-SNE'); ylabel('Clusters PCA');legend('off')

subplot(6,2,9)
gscatter(thisEVENTS_TSNE(:,1),thisEVENTS_TSNE(:,2),thisPCA_IndexK,color4plot);
ylabel('Clusters PCA');legend('off')

subplot(6,2,10)
gscatter(thisPCA_TSNE(:,1),thisPCA_TSNE(:,2),thisEVENTS_IndexK,color4plot);
ylabel('Clusters EVENTS');legend('off')

subplot(6,2,11)
gscatter(thisEVENTS_TSNE(:,1),thisEVENTS_TSNE(:,2),thisSessionIndex,color4plot);
ylabel('Clusters Session');legend('off')

subplot(6,2,12)
gscatter(thisPCA_TSNE(:,1),thisPCA_TSNE(:,2),thisSessionIndex,color4plot);
ylabel('Clusters Session');legend('off')

end