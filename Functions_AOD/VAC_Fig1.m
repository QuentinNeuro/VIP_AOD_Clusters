function fig_data=VAC_Fig1(As,trialtypeName)
%% Doesnt work anymore - lot of changes made in the As structure 
if nargin<2
    trialtypeName='All';
end
% Data for plot
    thisTime=As.Raw.Time;
    thisData=As.(trialtypeName).Data;
    yraster=1:size(thisData,1);
    thisPCA=As.(trialtypeName).PCA;
    thisIndexK=As.(trialtypeName).ClustersKmeans.IndexK;
    thisTSNE=As.(trialtypeName).TSNE;
    thisRew1Pun0Index=As.Index.Rew1Pun0;
    thisSessionIndex=As.Index.Session;
    color4plot='brgcy';
% figure
    fig_data=figure('Name',trialtypeName,'NumberTitle','off');
    subplot(4,4,1)
    imagesc(thisTime,yraster,thisData,[-20 20]);
    xlabel('Time from reinf (sec)'); ylabel('Trial Nb');
    
    subplot(4,4,2)
    thisDFF_AVG=As.(trialtypeName).ClustersKmeans.DFF_AVG;
    thisDFF_STD=As.(trialtypeName).ClustersKmeans.DFF_STD;
    hold on
    if size(thisDFF_AVG,1)<5
    for i=1:size(thisDFF_AVG,1)
        hs=shadedErrorBar(thisTime,thisDFF_AVG(i,:),thisDFF_STD(i,:),['-' color4plot(i)],1);
        hp(i)=hs.mainLine;
        thislegend{i}=sprintf('cluster_%.0d',i);
    end
    legend(hp,thislegend,'Location','northwest','FontSize',8);
    legend('boxoff');
    else
        plot(thisTime,thisDFF_AVG);
    end
	title('Clusters'); xlabel('Time from reinf (sec)'); ylabel('Z-score fluo');

    
    subplot(4,4,3)
    thisDFF_AVG=[As.Reward.DFF_AVG ; As.Punish.DFF_AVG];
    thisDFF_STD=[As.Reward.DFF_STD ; As.Punish.DFF_STD];
    thislegend={'Reward','Punish'};
    hold on
    for i=1:size(thisDFF_AVG,1)
        hs=shadedErrorBar(thisTime,thisDFF_AVG(i,:),thisDFF_STD(i,:),['-' color4plot(i)],1);
        hp(i)=hs.mainLine;
    end
    title('Rew vs. Pun'); xlabel('Time from reinf (sec)'); ylabel('Z-score fluo');
    legend(hp,thislegend,'Location','northwest','FontSize',8);
    legend('boxoff');
    
    subplot(4,4,4)
    bar(As.All.IndexMatch.ClustMatch,'stack');
    hold on
    ylim([0 1.1]); ylabel('% of each cluster');
    xticks([1 2 4 4+max(As.Index.Session)/2 max(As.Index.Session)+4]); xtickangle(45);
    xticklabels({'Rew','Pun','Sess 1','...',sprintf('Sess %.0d',max(As.Index.Session))})
% Cluster plot
if size(thisDFF_AVG,1)>5
    color4plot=[];
end
    subplot(4,4,5)
    gscatter(thisTSNE(:,1),thisTSNE(:,2),thisIndexK,color4plot);
    title('t-SNE'); ylabel('Clusters');legend('off')
    
    subplot(4,4,6)
    gscatter(thisPCA(:,1),thisPCA(:,2),thisIndexK,color4plot);
    title('PCA 1vs2'); xlabel('PC1'); ylabel('PC2');legend('off')
    
    subplot(4,4,7)
    gscatter(thisPCA(:,2),thisPCA(:,3),thisIndexK,color4plot);
    title('PCA 2vs3'); xlabel('PC2'); ylabel('PC3');legend('off')

    subplot(4,4,8)
    gscatter(thisPCA(:,3),thisPCA(:,4),thisIndexK,color4plot);
    title('PCA 3vs4'); xlabel('PC3'); ylabel('PC4');
% Rew/Pun plot   
    subplot(4,4,9)
    gscatter(thisTSNE(:,1),thisTSNE(:,2),thisRew1Pun0Index);
    title('t-SNE'); ylabel('Rew vs Pun');legend('off')
    
    subplot(4,4,10)
    gscatter(thisPCA(:,1),thisPCA(:,2),thisRew1Pun0Index);
    title('PCA 1vs2'); xlabel('PC1'); ylabel('PC2');legend('off')
    
    subplot(4,4,11)
    gscatter(thisPCA(:,2),thisPCA(:,3),thisRew1Pun0Index);
    title('PCA 2vs3'); xlabel('PC2'); ylabel('PC3');legend('off')

    subplot(4,4,12)
    gscatter(thisPCA(:,3),thisPCA(:,4),thisRew1Pun0Index);
    title('PCA 3vs4'); xlabel('PC3'); ylabel('PC4');

% Session
    subplot(4,4,13)
    gscatter(thisTSNE(:,1),thisTSNE(:,2),thisSessionIndex);
    title('t-SNE'); ylabel('Sessions');legend('off')
    
    subplot(4,4,14)
    gscatter(thisPCA(:,1),thisPCA(:,2),thisSessionIndex);
    title('PCA 1vs2'); xlabel('PC1'); ylabel('PC2');legend('off')
    
    subplot(4,4,15)
    gscatter(thisPCA(:,2),thisPCA(:,3),thisSessionIndex);
    title('PCA 2vs3'); xlabel('PC2'); ylabel('PC3');legend('off')

    subplot(4,4,16)
    gscatter(thisPCA(:,3),thisPCA(:,4),thisSessionIndex);
    title('PCA 3vs4'); xlabel('PC3'); ylabel('PC4');    
end

