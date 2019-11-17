function data=VAC_LoadData
% Select Files
[FileList,PathName]=uigetfile('*.mat','Select sessions to merge)','MultiSelect', 'on');
cd(PathName);
% Initialize
DFF=[];
Index.Rew1Pun0=[];
Index.Session=[];
% Open Files
for i=1:length(FileList)
    thisFile=FileList{i};
    load(thisFile);
    if i==1
        data.Time=time;
    end
    thisRew=aveCS_rew;
    thisPun=aveCS_pun;
    DFF=[DFF;thisRew;thisPun];
    Index.Rew1Pun0=[Index.Rew1Pun0; ones(size(thisRew,1),1); zeros(size(thisRew,1),1)];
    Index.Session=[Index.Session; i*ones(size(thisPun,1),1); i*ones(size(thisPun,1),1)];
end
% Save
data.FileList=FileList;
data.DFF=DFF;
data.Index=Index;
end