%% Launcher
% TCA parameters
LP.newFit=1;
LP.R=3; % latent
LP.n_fits = 10; % replicates
LP.ttToFit=[1,2,3,4];
% Plotting
LP.plotFitOverlay=0;
LP.plotFitIdx=1;
LP.plotErr=0;
LP.sortByArea=1; %session by default
LP.CMbyArea=0;
LP.ttLegend={'Miss','CR','Hit','FA'};
LP.areaLegend={'S1','M1','PtA','V1'};
switch LP.R %[0 0.06 ; 0.07 0.12 ; -0.2 0.5]; % [0 0.06 ; 0 0.2 ; -0.2 0.5]
    case 2
LP.yLim=[0 0.06 ; 0.07 0.12 ; -0.2 0.5]; 
    case 4
LP.yLim=[0 0.06 ; 0 0.2 ; -0.2 0.5];
end
LP.yLim=[0 0.06 ; 0 0.2 ; -0.2 0.5];
%% Figure initialization
if LP.plotFitOverlay
fh2=TCA_FigOverlay('ini');
end

%% Fit CP Tensor Decomposition
if LP.newFit
% Parameters
VAT_Fit=VAT_Group;
VAT_Fit=rmfield(VAT_Fit,'Data');
VAT_Fit.latents=LP.R;
VAT.Fit.reps=LP.n_fits;
VAT_Fit.Fit={};
VAT_Fit.err=[];
% Data
data=permute(VAT_Group.Data,[3 2 1]);
data=data(:,:,ismember(VAT_Fit.TrialTypes,LP.ttToFit));
data = tensor(data);
% fit the cp decomposition from random initial guesses
% these commands require that you download Sandia Labs' tensor toolbox:
% http://www.sandia.gov/~tgkolda/TensorToolbox/index-2.6.html
% convert data to a tensor object
err = zeros(LP.n_fits,1);
for n = 1:LP.n_fits
    % fit model
%     est_factors = cp_als(tensor(data),LP.R);
    est_factors = cp_apr(tensor(data),LP.R);
    % store error
    err(n) = norm(full(est_factors) - data)/norm(data)
    VAT_Fit.Fit{n} = est_factors;
    VAT_Fit.err(n) = err(n);
    if LP.plotFitOverlay
    fh2=TCA_FigOverlay('add',fh2,est_factors,VAT_Group);
    end
end
end

%% Generate colormaps and sorting vectors for plotting
% Cell factor
[sortCF, cmCF]=VAT_CF_sortAndCM(VAT_Fit,LP);
% Trial factor
thisCM=lines(4);
thisTrialTypes=VAT_Fit.TrialTypes(ismember(VAT_Fit.TrialTypes,LP.ttToFit));
cmTF=thisCM(thisTrialTypes, :);

cmVec={cmCF,cmTF};

%% Figures
for n=LP.plotFitIdx
TCA_Fig(VAT_Fit.Fit{n},VAT_Fit,LP,cmVec,sortCF)
end


function TCA_Fig(TCAfit,VAT_Fit,LP,cmVec,sortCF)

if LP.sortByArea
    xArea(1)=1;
    xArea(2)=sum(VAT_Fit.CellNb(VAT_Fit.AreaID==1));
    areaCounter=2;
    for a=3:2:8
        xArea(a)=xArea(a-1)+1;
        xArea(a+1)=xArea(a-1)+sum(VAT_Fit.CellNb(VAT_Fit.AreaID==areaCounter));
        areaCounter=areaCounter+1;
    end
    xArea=reshape(xArea,2,4);
end

time=VAT_Fit.Time(1,:);
CF=TCAfit.u{1};
if ~isnan(sortCF)
    CF=CF(sortCF,:);
end
LF=TCAfit.u{2};
TF=TCAfit.u{3};

counter=0;
figure()
for thisL=1:VAT_Fit.latents
subplot(VAT_Fit.latents,3,1+counter); hold on;
CFx=1:size(CF,1);
CFy=CF(:,thisL);
if LP.sortByArea
plot(xArea,[0.05 0.05],'-')
end
scatter(CFx,CFy,10,cmVec{1},'filled');
plot([0 0],[CFx(1) CFx(end)],'-k');
axis tight
ylim(LP.yLim(1,:));

subplot(VAT_Fit.latents,3,2+counter); hold on;
LFx=time;
LFy=LF(:,thisL);
plot(LFx,LFy,'-k')
 ylim(LP.yLim(2,:));
 xlim([-2 4]);

subplot(VAT_Fit.latents,3,3+counter); hold on;
TFx=1:size(TF,1);
TFy=TF(:,thisL);
scatter(TFx,TFy,10,cmVec{2},'filled')
plot([0 0],[TFx(1) TFx(end)],'-k');
ylim(LP.yLim(3,:));
counter=counter+3;
end
subplot(VAT_Fit.latents,3,1+counter-3)
xlabel('neurons')
subplot(VAT_Fit.latents,3,2+counter-3)
xlabel('time (s)')
subplot(VAT_Fit.latents,3,3+counter-3)
xlabel('trials')
end

function fh2=TCA_FigOverlay(action,fh2,est_factors,VAT_Group)
switch action
    case 'ini'
fh2.fig=figure();
fh2.sp1=subplot(2,2,1); hold on;
title 'Latent 1 - trial 3/4';
fh2.sp2=subplot(2,2,2); hold on;
title 'Latent 2 - trial 3/4';
fh2.sp3=subplot(2,2,3); hold on;
fh2.sp4=subplot(2,2,4); hold on;
    case 'add'
        trialTypeIndex=VAT_Group.TrialTypes;
        time=VAT_Group.Time;
        latent1=est_factors.u{2}(:,1);
        latent2=est_factors.u{2}(:,2);
        mean1_34=mean(est_factors.u{3}(trialTypeIndex>2,1));
        mean1_12=mean(est_factors.u{3}(trialTypeIndex<=2,1));
        if mean1_12<mean1_34
            latent34=latent1;
            latent12=latent2;
            tf34=est_factors.u{3}(:,1);
            tf12=est_factors.u{3}(:,2);
        else
            latent34=latent2;
            latent12=latent1;
            tf34=est_factors.u{3}(:,2);
            tf12=est_factors.u{3}(:,1);
        end
        plot(fh2.sp1,time,latent34,'-k');
        ylim([0.07 0.12])
        plot(fh2.sp2,time,latent12,'-k');
        ylim([0.07 0.12])
        plot(fh2.sp3,tf34,'ok')
        ylim([-0.02 0.5])
        plot(fh2.sp4,tf12,'ok')
        ylim([-0.02 0.5])
end     
end

function [CF_sortVector, CF_colorMap]=VAT_CF_sortAndCM(VAT_Fit,LP)
% updates sorting and colormaps vectors according to LP

nbOfCells=VAT_Fit.CellNb;           % nb of cells per session
nbOfTotCells=sum(nbOfCells);        % total nb of cells
nbOfSessions=VAT_Fit.SessionCounter;  % nb of sessions
nbOfAreas=4;                         % nb of areas
areaID=VAT_Fit.AreaID;              % area ID per session
areaID_cell=[];                     % area ID per cell
sessionID_cell=[];                  % session ID per cell

for s=1:nbOfSessions
    areaID_cell     = [areaID_cell areaID(s)*ones(1,nbOfCells(s))];
    sessionID_cell  = [sessionID_cell s*ones(1,nbOfCells(s))];
end

%% Generates sorting vector
if LP.sortByArea
    [~,CF_sortVector]=sort(areaID_cell);
else CF_sortVector=1:nbOfTotCells;
end

%% Generates color map
switch LP.CMbyArea
    case 1
    thisCM=jet(nbOfAreas);
    if LP.sortByArea
        for c=1:nbOfTotCells
            CF_colorMap(c,:)=thisCM(areaID_cell(CF_sortVector(c)),:);
        end
    else
        for c=1:nbOfTotCells
            CF_colorMap(c,:)=thisCM(areaID_cell(c),:);
        end
    end
    case 0
    thisCM=jet(nbOfSessions);
    if ~LP.sortByArea
        for c=1:nbOfTotCells
            CF_colorMap(c,:)=thisCM(sessionID_cell(c),:);
        end
    else
        [~,areaID_sortID]=sort(areaID);
        nbOfCells_sort=nbOfCells(areaID_sortID);
        sessionID_cell_newSort=[];
        for s=1:nbOfSessions
            sessionID_cell_newSort=[sessionID_cell_newSort s*ones(1,nbOfCells_sort(s))];
        end
        for c=1:nbOfTotCells
            CF_colorMap(c,:)=thisCM(sessionID_cell_newSort(c),:);
        end
    end
end
end
