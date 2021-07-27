%% Data
TW_AVG=[0 2];
TW_MAX=[0 4];
Time=As.Raw.Time; %1x181
Data_Core=As.Raw.Data; %1622x181
Depth_Core=As.Raw.Index.Depth; %1622x1
Filter_Session_Core=As.Raw.Index.Session;
Filter_BrainAreas_Core=As.Raw.Index.BrainAreas;
Filter_Session_RewAct=As.RewAct.Index.Session;
Filter_BrainAreas_RewAct=As.RewAct.Index.BrainAreas;
Filter_Rew=logical(As.Raw.Index.Rew1Pun0); %1622x1
Filter_RewAct=logical(As.Raw.Index.RewAct); %811x1

%% Zscore
Data_Core=Data_Core*100;
Data_Core=(Data_Core-mean(Data_Core(:,2:21),2))./std(Data_Core(:,2:21),0,2);

%% Filter the Data
Data_Rew=Data_Core(Filter_Rew,:); %-->811x181
Depth_Rew=Depth_Core(Filter_Rew); %-->811x1

Data_RewAct=Data_Rew(Filter_RewAct,:); %-->606x181
Depth_RewAct=Depth_Rew(Filter_RewAct,:); %-->606x1

%% Average
AVG_RewAct=nanmean(Data_RewAct(:,Time>TW_AVG(1) & Time<TW_AVG(2)),2); %--> 606x1
MAX_RewAct=max(Data_RewAct(:,Time>TW_MAX(1) & Time<TW_MAX(2)),[],2); %--> 606x1

for thisSession=1:max(Filter_Session_RewAct)
    thisFilterSession=Filter_Session_RewAct==thisSession;
    AVG_RewAct_AVGSession(thisSession)=mean(AVG_RewAct(thisFilterSession));
    Data_RewAct_NormAVG(thisFilterSession)=AVG_RewAct(thisFilterSession)/AVG_RewAct_AVGSession(thisSession);
    MAX_RewAct_AVGSession(thisSession)=mean(MAX_RewAct(thisFilterSession));
    Data_RewAct_NormMAX(thisFilterSession)=MAX_RewAct(thisFilterSession)/MAX_RewAct_AVGSession(thisSession);
end
[rAVG,pAVG]=corr(Depth_RewAct,Data_RewAct_NormAVG');
[rMAX,pMAX]=corr(Depth_RewAct,Data_RewAct_NormMAX');
LFit_AVG=fitlm(Depth_RewAct,Data_RewAct_NormAVG');
LFit_MAX=fitlm(Depth_RewAct,Data_RewAct_NormMAX');

%% Figure
figure()
subplot(3,2,1)
gscatter(Depth_RewAct,AVG_RewAct,Filter_Session_RewAct)
title('Average DFF [0 2]');
xlabel('Depth'); ylabel('AVG Zsc Fluo');
legend off
subplot(3,2,2)
gscatter(Depth_RewAct,MAX_RewAct,Filter_Session_RewAct)
title('MAX DFF [0 4]');
xlabel('Depth'); ylabel('MAX Zsc Fluo');
legend off
subplot(3,2,3)
gscatter(Depth_RewAct,Data_RewAct_NormAVG,Filter_Session_RewAct)
xlabel('Depth'); ylabel('Norm Zsc Fluo');
legend off
subplot(3,2,4)
gscatter(Depth_RewAct,Data_RewAct_NormMAX,Filter_Session_RewAct)
xlabel('Depth'); ylabel('Norm Zsc Fluo');
legend off
subplot(3,2,5)
plot(LFit_AVG);
xlabel('Depth'); ylabel('Norm Zsc Fluo');
subplot(3,2,6)
plot(LFit_MAX);
xlabel('Depth'); ylabel('Norm Zsc Fluo');

