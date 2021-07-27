function As=VAC_ResponsiveCells(As)

if exist('cellIDresponse') ~= 1
[FileList,PathName]=uigetfile('*.mat','Select cellID file','MultiSelect', 'on');
cd(PathName)
load(FileList)
end

ResponseTypes={'RewAct','PunAct','RewInh','PunInh','AllAct'};
cellIDresponse.AllAct=[cellIDresponse.RewAct ; cellIDresponse.PunAct]

for i=1:size(ResponseTypes,2)
    thisResponseType=ResponseTypes{i};
    thisDepth=cellIDresponse.Depth;
    if contains(thisResponseType,'Rew')
        thisDataType='Reward';
    elseif contains(thisResponseType,'Pun')
        thisDataType='Punish';
    elseif contains(thisResponseType,'All')
        thisDataType='All';
        thisDepth=[cellIDresponse.Depth ; cellIDresponse.Depth];
    else
        disp('Cannot find data for Response cell sorting function')
        return
    end
	thisLogical=logical(cellIDresponse.(thisResponseType));
    As.Raw.Index.(thisResponseType)=thisLogical;
    As.(thisResponseType).Time=As.Raw.Time;
    % Index
    As.(thisResponseType).Index.Session=As.(thisDataType).Index.Session(thisLogical);
    As.(thisResponseType).Index.BrainAreas=As.(thisDataType).Index.BrainAreas(thisLogical);
    As.(thisResponseType).Index.Depth=thisDepth(thisLogical);
    %Data
    thisData=As.(thisDataType).Data(thisLogical,:);
    As.(thisResponseType).Data=thisData;
    As.(thisResponseType).DFF_AVG=mean(thisData,1);
    As.(thisResponseType).DFF_STD=std(thisData,1);
    %PCA
    As.(thisResponseType).PCA.PCs=As.(thisDataType).PCA.PCs(thisLogical,:);
    As.(thisResponseType).PCA.TSNE=tsne(As.(thisResponseType).PCA.PCs);
    %Events
    As.(thisResponseType).Events.Names=As.(thisDataType).Events.Names;
    As.(thisResponseType).Events.Data=As.(thisDataType).Events.Data(thisLogical,:);
    As.(thisResponseType).Events.TSNE=tsne(As.(thisResponseType).Events.Data);

end
As.Raw.Index.Depth=thisDepth;