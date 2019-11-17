function As=VAC_IndexMatch(As,thisType,thisClusters)
% Parameters
clusterNbKmeans=max(As.(thisType).(thisClusters).Cluster_Index);
%% Reward/Punish
switch thisType
    case 'All'
MatchingName={'Reward','Punish'};
MatchingIndex=[0 1];
for i=1:2
As.(thisType).(thisClusters).IndexMatch.Name{i}=MatchingName{i};
thisClass=As.Raw.Index.Rew1Pun0==MatchingIndex(i);
NbOfObs=sum(thisClass);
for j=1:clusterNbKmeans
    thisClusterIndex=As.(thisType).(thisClusters).Cluster_Index==j;
    thisMatch=sum(thisClusterIndex(thisClass))/NbOfObs;
    As.(thisType).(thisClusters).IndexMatch.Proba(i,j)=thisMatch;
end
As.(thisType).(thisClusters).IndexMatch.NbOfObs(i)=NbOfObs;
end
As.(thisType).(thisClusters).IndexMatch.NbOfObs(end+1)=NbOfObs;
% Blank
As.(thisType).(thisClusters).IndexMatch.Name{end+1}='blank';
As.(thisType).(thisClusters).IndexMatch.ClustMatch(3,:)=NaN;
counter=3;
    otherwise
counter=0;
end

%% Sessions
for thisSess=1:max(As.Raw.Index.Session)
    counter=counter+1;
    As.(thisType).(thisClusters).IndexMatch.Name{counter}=sprintf('ses_%.0d',thisSess);
    thisClass=As.(thisType).Index.Session==thisSess;
    NbOfObs=sum(thisClass);
for i=1:clusterNbKmeans
    thisClusterIndex=As.(thisType).(thisClusters).Cluster_Index==i;
    thisMatch=sum(thisClusterIndex(thisClass))/NbOfObs;
    As.(thisType).(thisClusters).IndexMatch.Proba(counter,i)=thisMatch;
end
As.(thisType).(thisClusters).IndexMatch.NbOfObs(counter)=NbOfObs;
end
end