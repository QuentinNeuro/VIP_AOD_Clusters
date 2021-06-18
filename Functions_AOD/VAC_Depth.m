notthiscx=[]; %
thistype='RewAct';
anovaCheck=1;

Depth=As.(thistype).Index.Depth;
Cluster=As.(thistype).PCA.KClusters_5.Index;

if ~isempty(notthiscx)
notthiscxIndex=As.(thistype).Index.BrainAreas~=notthiscx;
end


%% ANOVA across cortical areas
if anovaCheck
    [anoPVal,anoTble,anoStats]=anova1(Depth,Cluster);
    [c,~,~,gnames] = multcompare(anoStats);
end


%% Figure
figure()
hold on

for i=1:5
    thislogical=Cluster==i;
    if ~isempty(notthiscx)
    thislogical=logical(thislogical.*notthiscxIndex);
    end
    thisDepth=abs(Depth(thislogical));
    thiscumul=1/length(thisDepth);
    for j=2:length(thisDepth)
        thiscumul(j)=thiscumul(j-1)+1/length(thisDepth);
    end
    ClusterDepthStats(i,1)=mean(thisDepth);
    ClusterDepthStats(i,2)=median(thisDepth);
    ClusterDepthStats(i,3)=std(thisDepth);
    ClusterDepthStats(i,4)=length(thisDepth);
    
ClusterDepth{i}=[sort(thisDepth) thiscumul'];
plot(ClusterDepth{1,i}(:,1),ClusterDepth{1,i}(:,2));
end