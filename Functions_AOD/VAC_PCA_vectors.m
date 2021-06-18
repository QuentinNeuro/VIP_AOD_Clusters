function VAC_PCA_vectors(As,thisType,nbOfPC,histo_cumul,anovaCheck)

%% Parameters
if nargin<5
thisType='RewAct';
nbOfPC=3;
histo_cumul=1; % 0 for histogram, 1 for cumulative plot;
anovaCheck=1;
end
timeCutPC=[];
nBinHisto=30;

%% Data
thisData=As.(thisType).Data;
thisTime=As.(thisType).Time;
indexAreas=As.(thisType).Index.BrainAreas;
[indexAreas_sorted,indexSort]=sort(indexAreas);

%% PCA
if ~isempty(timeCutPC)
    thisPCAData=thisData(:,thisTime>timeCutPC(1) & thisTime<timeCutPC(2));
    thisTime=thisTime(thisTime>timeCutPC(1) & thisTime<timeCutPC(2));
    thisPCAData=thisPCAData-thisPCAData(:,1);
else
    thisPCAData=thisData;
end

[coeffPCA,score,latent,~,explainedPCA]=pca(thisPCAData');

% Sort
coeffPCA_sorted=coeffPCA(indexSort,1:nbOfPC);

%% ANOVA across cortical areas
if anovaCheck
for thisPC=1:nbOfPC
    [anoPVal,anoTble,anoStats]=anova1(coeffPCA(:,thisPC),indexAreas);
    [c,~,~,gnames] = multcompare(anoStats);
end
end
%% Figure
subplot_counter=[1 2 3];

figure('Name','PCA vectors')
subplot(nbOfPC,3,1)
hold on
title('PC score')
subplot(nbOfPC,3,2)
hold on
title('PC loadings')
subplot(nbOfPC,3,3)
hold on
title('distribution')

for thisPC=1:nbOfPC
thisPCName=sprintf('PC %.0d',thisPC);

subplot(nbOfPC,3,subplot_counter(1))
hold on
plot(thisTime,score(:,thisPC))
ylabel(thisPCName); xlim([-3 4]);
legend off

subplot(nbOfPC,3,subplot_counter(2))
hold on
gscatter(1:length(indexAreas_sorted),coeffPCA_sorted(:,thisPC),indexAreas_sorted);
legend off

subplot(nbOfPC,3,subplot_counter(3))
hold on
if histo_cumul
    [x,y]=cumulative(coeffPCA_sorted(indexAreas_sorted==1,thisPC));
    plot(x,y,'-r');
    [x,y]=cumulative(coeffPCA_sorted(indexAreas_sorted==2,thisPC));
    plot(x,y,'-g');
    [x,y]=cumulative(coeffPCA_sorted(indexAreas_sorted==3,thisPC));
    plot(x,y,'-c');
    [x,y]=cumulative(coeffPCA_sorted(indexAreas_sorted==4,thisPC));
    plot(x,y,'-','Color',[0.4940 0.1840 0.5560]);
    ylim([0 1]);
else
histogram(coeffPCA_sorted(indexAreas_sorted==1,thisPC),nBinHisto,'FaceColor','-r');
histogram(coeffPCA_sorted(indexAreas_sorted==2,thisPC),nBinHisto,'FaceColor','-g');
histogram(coeffPCA_sorted(indexAreas_sorted==3,thisPC),nBinHisto,'FaceColor','-c');
histogram(coeffPCA_sorted(indexAreas_sorted==4,thisPC),nBinHisto,'FaceColor',[0.4940 0.1840 0.5560]);
end
legend off

subplot_counter=subplot_counter+3;
end

subplot(nbOfPC,3,3*nbOfPC-2)
xlabel('Time from reward (sec)');

subplot(nbOfPC,3,3*nbOfPC-1)
xlabel('neurons');

subplot(nbOfPC,3,3*nbOfPC)
xlabel('distribution');
legend(As.Raw.Index.BrainAreaNames);