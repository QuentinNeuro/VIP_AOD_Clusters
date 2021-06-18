function data=VAC_LoadData
% Select Files
[FileList,PathName]=uigetfile('*.mat','Select sessions to merge)','MultiSelect', 'on');
cd(PathName);
% Initialize
DFF=[];
Index.Rew1Pun0=[];
Index.Session=[];
Index.BrainAreas=[];
Index.BrainAreaNames=['S1' ;	'M1';	'PC' ;  'V1'];

% Open Files
for i=1:length(FileList)
    thisFile=FileList{i};
    load(thisFile);
    if i==1
        data.Time=time;
    end
    try
    thisRew=aveCS_rew;
    thisPun=aveCS_pun;
    catch
    thisRew=zs_AveCS_rew;
    thisPun=zs_AveCS_pun;
    end
    DFF=[DFF;thisRew;thisPun];
    Index.Rew1Pun0=[Index.Rew1Pun0; ones(size(thisRew,1),1); zeros(size(thisRew,1),1)];
    Index.Session=[Index.Session; i*ones(size(thisPun,1),1); i*ones(size(thisPun,1),1)];
    BrainAreaIndex=VAC_S2A(FileList{i});
    Index.BrainAreas=[Index.BrainAreas; BrainAreaIndex*ones(size(thisPun,1),1); BrainAreaIndex*ones(size(thisPun,1),1)]; 
end
% Save
data.FileList=FileList;
data.DFF=DFF;
data.Index=Index;
end