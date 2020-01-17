function As=VAC_ResponsiveCells(As)

if exist('cellIDresponse') ~= 1
[FileList,PathName]=uigetfile('*.mat','Select cellID file','MultiSelect', 'on');
cd(PathName)
load(FileList)
end

ResponseTypes={'RewAct','PunAct','RewInh','PunInh'};

for i=1:size(ResponseTypes,2)
    thisResponseType=ResponseTypes{i};
    if contains(thisResponseType,'Rew')
        thisDataType='Reward';
    else
        thisDataType='Punish';
    end
	thisLogical=logical(cellIDresponse.(thisResponseType));
    As.(thisResponseType).Time=As.Raw.Time;
    % Index
    As.(thisResponseType).Index.Session=As.(thisDataType).Index.Session(thisLogical);
    As.(thisResponseType).Index.BrainAreas=As.(thisDataType).Index.BrainAreas(thisLogical);
    %Data
    thisData=As.(thisDataType).Data(thisLogical,:);
%     if NormMax
%         thisMax=max(thisData,[],2);
%         thisData=thisData./thisMax;
%     end
    As.(thisResponseType).Data=thisData;
    As.(thisResponseType).DFF_AVG=mean(thisData,1);
    As.(thisResponseType).DFF_STD=std(thisData,1);
    %PCA
    As.(thisResponseType).PCA.PCs=As.(thisDataType).PCA.PCs(thisLogical,:);
    As.(thisResponseType).PCA.TSNE=As.(thisDataType).PCA.TSNE(thisLogical,:);
    %Events
    As.(thisResponseType).Events.Names=As.(thisDataType).Events.Names;
    As.(thisResponseType).Events.Data=As.(thisDataType).Events.Data(thisLogical,:);
    As.(thisResponseType).Events.TSNE=As.(thisDataType).Events.TSNE(thisLogical,:);

end
