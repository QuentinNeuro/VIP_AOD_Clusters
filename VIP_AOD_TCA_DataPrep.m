%% Directory
Dir_In='D:\AOD\2ph_cellbase_for_Quentin\cellbase_2ph\';
Dir_Out='D:\AOD\TCA_QC';
AList=cellbase_2ph_List;
%% Parameters
CreateFigure=0;
% Massaging
LP.smoothFilt=0;
LP.maxNorm=3;           % -3- Normalize to max : (1) before process (2) after process (3) max of avg Hit response
LP.nnNorm=1;            % -1- (1) Before (works) or (2) After normalizing [does not apply to maxNorm=1]
LP.zeroCue=0;           % zero fluo value right before cue
% Timing and warping
LP.newTW=[-2.5 2.5];      % before cue and after outcome [-2 2.5] for warping / [-2.5 2.5] no warp
LP.realignOut=1;        % realign to Outcome when no warping - use RT=1.5 for 
LP.warpingRT=0;         % Warp RT fluo traces
LP.TTtoWarp={3,4};      % trial types that will be warped
LP.RT_wt=1.5;           % New warped RT in sec - could also be defined as median RT ?
LP.RT_ro=1;             % arbitrary RT for RT=3 when doing realignOut;
% TCA specific
LP.TCA_TTtoAdd=[1,2,3,4]; % can be sub-selected during the TCA process;
LP.TCA_extract=0;       % not working atm (1) is first (2) is random (3) is best corr ?
LP.TCA_trialNb=10;      % could also be [10 30 30 30];
% others
LP.FR=20;               % frame rate, to be determined
LP.RT_wp=LP.FR*LP.RT_wt;      %length of the new vector in points
if LP.warpingRT
thisTime_predict = LP.newTW(1):1/LP.FR:LP.RT_wt+LP.newTW(2)-2/LP.FR;
else
thisTime_predict = LP.newTW(1):1/LP.FR:LP.newTW(2)-1/LP.FR;
end

%% Loops through Animal (thisA), Session (thisS), Cells (thisC) and Trials (thisT)
VAT_Group=VAT_select([],[],LP,'ini');
counterS=0;
% Animals
for thisA=1:size(AList,2)
% Session
for thisS=2:size(AList{1,thisA},2)
counterS=counterS+1;
thisDir=[Dir_In AList{1,thisA}{1,1} filesep AList{1,thisA}{1,thisS}];
cd(thisDir);
FileList=ls;
VAT_Session=struct();
VAT_Session.sessionID=[AList{1,thisA}{1,1} '_' AList{1,thisA}{1,thisS}];
load('TrialEvents','RT','Outcomes');
load('BrainArea');
VAT_Session.LP=LP;
VAT_Session.RT=RT;
VAT_Session.Out=Outcomes;
VAT_Session.AreaID=AreaID;
VAT_Session.AreaName=AreaName;
for thisOut=1:4
VAT_Session.OutNb(thisOut)=nnz(VAT_Session.Out==thisOut);
end
VAT_Session.cellNb=0;
VAT_Session.Time=thisTime_predict;
% Cell
for thisC=1:size(FileList,1)
    if contains(FileList(thisC,:),'EVENTCS') && contains(FileList(thisC,:),'mat')
VAT_Session.cellNb=VAT_Session.cellNb+1;
VAT_Session=VAT_process(VAT_Session,LP,FileList(thisC,:));
    end %if
end %for

%% Save
cd (Dir_Out)
FileName=[VAT_Session.sessionID '.mat'];
save(FileName,'VAT_Session');

%% figure
if CreateFigure
    Dir_Fig=[Dir_Out filesep 'Figure_Processing'];
    if ~isdir(Dir_Fig)
        mkdir(Dir_Fig);
    end
VAT_plot(VAT_Session)
FileName=[VAT_Session.sessionID 'Data Processing'];
DirFile=[Dir_Fig filesep FileName];
saveas(gcf,DirFile,'png');
end
% Group
VAT_Group=VAT_select(VAT_Session,VAT_Group,LP,'add');
end % Session
end % Animal

%% Functions
function VAT_Session=VAT_process(VAT_Session,LP,cellDataName)
VAT_Session.cellID{VAT_Session.cellNb}=cellDataName;    
cellNb=VAT_Session.cellNb;
Out=VAT_Session.Out;
RT=VAT_Session.RT;
nbOfTrials=length(RT);

load(cellDataName);
thisTime=event_timevec{2,:};
if isnan(thisTime)
    thisTime=linspace(-3, 6, 181);
end
thisData_OG=cell2mat(event_stimes{2,1}');
thisData=thisData_OG;
VAT_Session.OG.Time=thisTime;
%% PreProcessing
if LP.smoothFilt
thisDataS=smoothdata(thisData','movmean',5);
thisData=thisDataS';
end
if LP.maxNorm==1
	thisData=thisData/max(max(thisData));
end
if LP.zeroCue
    zeroValue=mean(thisData(:,thisTime>=-0.7 & thisTime<0.2),2);
    thisData=thisData-zeroValue;
end
%% Warping
if LP.warpingRT
for thisT=1:nbOfTrials
    switch Out(thisT)
        case LP.TTtoWarp
    if RT(thisT)~=3
        thisRT=RT(thisT)+0.5;
    else
        thisRT=RT(thisT);
    end
    thisData_Base      =thisData(thisT,thisTime>LP.newTW(1) & thisTime<0);
    thisData_RT        =thisData(thisT,thisTime>=0 & thisTime<=thisRT);
    thisData_Out       =thisData(thisT,thisTime>thisRT & thisTime<LP.newTW(2)+thisRT);
    % padding - it works but I am not 100% certain
    padRT=fliplr(thisData_RT);
    thisData_RT_pad=[thisData_RT padRT];
    tpFR=round(length(thisData_RT_pad)/(2*LP.RT_wt));
    thisData_RT_pad=resample(thisData_RT_pad,LP.FR,tpFR);
    thisData_RT=thisData_RT_pad(1:LP.RT_wp);
    thisData_warp{thisT}=[thisData_Base thisData_RT thisData_Out];
        otherwise
    thisData_warp{thisT}=thisData(thisT,thisTime>LP.newTW(1) & thisTime<LP.RT_wt+LP.newTW(2));
    end
end % End Trials
thisData=cell2mat(thisData_warp');
else
    for thisT=1:nbOfTrials
        if LP.realignOut
            if RT(thisT)>=3
                thisRT=LP.RT_ro;
            else
                thisRT=RT(thisT);
            end
        thisT_Time=thisTime-thisRT-0.5;
        else thisT_Time=thisTime;
        end
        tp=thisData(thisT,thisT_Time>LP.newTW(1));
        thisData_noWarp{thisT}=tp(1:length(VAT_Session.Time));
    end
    thisData=cell2mat(thisData_noWarp');
end

%% non-negative and max normalization
if LP.nnNorm==1
    thisData=(thisData-min(min(thisData)));
end
if LP.maxNorm==2
    thisData=thisData/max(max(thisData));
end
if LP.maxNorm==3
        thisData=thisData/max(nanmean(thisData(Out==3,:),1));
end
if LP.nnNorm==2
    thisData=(thisData-min(min(thisData)));
end

%% Saving and Avg
VAT_Session.Data{cellNb}=thisData;
for thisOut=1:4
    VAT_Session.DataAVG{thisOut}(cellNb,:)=nanmean(thisData(Out==thisOut,:),1);
    VAT_Session.OG.Data_AVG{thisOut}(cellNb,:)=nanmean(thisData_OG(Out==thisOut,:),1);
end
end

function VAT_Group=VAT_select(VAT_Session,VAT_Group,LP,action)
switch action
    case 'ini'
        VAT_Group=struct;
        VAT_Group.Parameters=LP;
        if length(VAT_Group.Parameters.TCA_trialNb)==1
            VAT_Group.Parameters.TCA_trialNb=ones(1,4)*VAT_Group.Parameters.TCA_trialNb;
        end
        VAT_Group.SessionCounter=0;
        VAT_Group.sessionID={};
        VAT_Group.sessionNb=[];
        VAT_Group.AreaName={};
        VAT_Group.AreaID=[];
        VAT_Group.CellNb=[];
        VAT_Group.TrialTypes=[];
        for thisO=LP.TCA_TTtoAdd
            VAT_Group.TrialTypes=[VAT_Group.TrialTypes ones(1,VAT_Group.Parameters.TCA_trialNb(thisO))*(thisO)];
        end
        VAT_Group.TrialID=[];
        VAT_Group.Time=[];
        VAT_Group.Data=[];
    case 'add'
        counter=VAT_Group.SessionCounter+1
        % take into account 'NaN' containing trials
        thisNaNTrials=~isnan(VAT_Session.Data{1,1}(:,1));
        OutNaN=thisNaNTrials.*VAT_Session.Out';
        for thisO=LP.TCA_TTtoAdd
            VAT_Session.OutNb(thisO)=nnz(OutNaN==thisO);
        end
        if all(VAT_Session.OutNb>=VAT_Group.Parameters.TCA_trialNb)
            VAT_Group.SessionCounter=counter;
            VAT_Group.sessionID{counter}=VAT_Session.sessionID;
            VAT_Group.sessionNb=[VAT_Group.sessionNb counter*ones(1,VAT_Session.cellNb)];
            VAT_Group.AreaName{counter}=VAT_Session.AreaName;
            VAT_Group.AreaID(counter)=VAT_Session.AreaID;
            VAT_Group.CellNb(counter)=VAT_Session.cellNb;
            VAT_Group.Time(counter,:)=VAT_Session.Time;
            for thisC=1:VAT_Session.cellNb
                thisData(:,:,thisC)=VAT_Session.Data{1,thisC};
            end
            trialID=[];
            for thisO=LP.TCA_TTtoAdd
                trialID=[trialID ; find(OutNaN==thisO,VAT_Group.Parameters.TCA_trialNb(thisO))];
            end
            VAT_Group.TrialID=[VAT_Group.TrialID ; trialID];
            thisData_sort=thisData(trialID',:,:);
            VAT_Group.Data=cat(3,VAT_Group.Data,thisData_sort);
        else
            disp('not enough trials for this session')
        end  
end
end

function VAT_plot(VAT_Session)
xTime=[-2 4];
if VAT_Session.LP.nnNorm
    yFluo=[0.7 1.2];
else
    yFluo=[-0.5 1.5];
end
labelTime='Time (sec)';
labelFluo='Fluo';
labelCells='Cell #';

figure('Name',VAT_Session.sessionID,'Position', [200 100 1200 700], 'numbertitle','off');
for thisOut=1:4
subplot(3,2,1); hold on;
plot(VAT_Session.Time,mean(VAT_Session.DataAVG{1,thisOut},1));
subplot(3,2,2); hold on;
plot(VAT_Session.OG.Time,mean(VAT_Session.OG.Data_AVG{1,thisOut},1));
subplot(3,2,2+thisOut); hold on;
imagesc(VAT_Session.Time,1:VAT_Session.cellNb,VAT_Session.DataAVG{1,thisOut},yFluo);
end

% make it pretty
subplot(3,2,1)
title('Processed');
set(gca,'XLim',xTime);
xlabel(labelTime);ylabel(labelFluo);
subplot(3,2,2)
title('Original');
set(gca,'XLim',xTime);
xlabel(labelTime);ylabel(labelFluo);
legend({'Miss','CR','Hit','FA'});

subplot(3,2,3)
title(sprintf('Miss (%.0d)',VAT_Session.OutNb(1)))
axis tight; ylabel(labelCells);
set(gca,'XLim',xTime);
subplot(3,2,4)
title(sprintf('CR (%.0d)',VAT_Session.OutNb(2)))
axis tight;
set(gca,'XLim',xTime);
subplot(3,2,5)
title(sprintf('Hit(%.0d)',VAT_Session.OutNb(3)))
axis tight; ylabel(labelCells);xlabel(labelTime);
set(gca,'XLim',xTime);
subplot(3,2,6)
title(sprintf('FA(%.0d)',VAT_Session.OutNb(4)))
axis tight; xlabel(labelTime);
set(gca,'XLim',xTime);
pos=get(gca,'pos');
c=colorbar('location','eastoutside','position',[pos(1)+pos(3)+0.001 pos(2) 0.01 pos(4)]);
c.Label.String = labelFluo;

end

function AList=cellbase_2ph_List
AList=cell(1,1);
AList{1}                = {'m151','150828a'};
AList{size(AList,2)+1}  = {'m152','150828a'};
AList{size(AList,2)+1}  = {'m153','150828a','150902a'};
AList{size(AList,2)+1}  = {'m162','150910a'};
AList{size(AList,2)+1}  = {'m170','151109a'};
AList{size(AList,2)+1}  = {'m171','151105a'};
AList{size(AList,2)+1}  = {'m192','160413a'};
AList{size(AList,2)+1}  = {'m230','160803a'};
AList{size(AList,2)+1}  = {'m243','160902a'};
AList{size(AList,2)+1}  = {'m253','161003a'};
AList{size(AList,2)+1}  = {'m312','160505a'};
AList{size(AList,2)+1}  = {'m334','160608a'};
AList{size(AList,2)+1}  = {'m341','160821a'};
AList{size(AList,2)+1}  = {'m392','171109a','171110a'};
AList{size(AList,2)+1}  = {'m395','171113a'};
AList{size(AList,2)+1}  = {'m398','171115a'};
end