function As=VAC_IndexMatch(As,thisTrialType,thisDataType,clusterNbKmeans)
% Parameters
thisClusterNbName=sprintf('KClusters_%.0d',clusterNbKmeans);
%% Reward/Punish
switch thisTrialType
    case 'All'
MatchingName={'Reward','Punish'};
MatchingIndex=[0 1];
for i=1:2
As.(thisTrialType).(thisDataType).(thisClusterNbName).IndexMatch.Name{i}=MatchingName{i};
thisClass=As.Raw.Index.Rew1Pun0==MatchingIndex(i);
NbOfObs=sum(thisClass);
for j=1:clusterNbKmeans
    thisClusterIndex=As.(thisTrialType).(thisDataType).(thisClusterNbName).Index==j;
    thisMatch=sum(thisClusterIndex(thisClass))/NbOfObs;
    As.(thisTrialType).(thisDataType).(thisClusterNbName).IndexMatch.Proba(i,j)=thisMatch;
end
As.(thisTrialType).(thisDataType).(thisClusterNbName).IndexMatch.NbOfObs(i)=NbOfObs;
end
As.(thisTrialType).(thisDataType).(thisClusterNbName).IndexMatch.NbOfObs(end+1)=NbOfObs;
% Blank
As.(thisTrialType).(thisDataType).(thisClusterNbName).IndexMatch.Name{end+1}='blank';
As.(thisTrialType).(thisDataType).(thisClusterNbName).IndexMatch.ClustMatch(3,:)=NaN;
counter=3;
    otherwise
counter=0;
end

%% Sessions
for thisSess=1:max(As.Raw.Index.Session)
    counter=counter+1;
    As.(thisTrialType).(thisDataType).(thisClusterNbName).IndexMatch.Name{counter}=sprintf('ses_%.0d',thisSess);
    thisClass=As.(thisTrialType).Index.Session==thisSess;
    NbOfObs=sum(thisClass);
for i=1:clusterNbKmeans
    thisClusterIndex=As.(thisTrialType).(thisDataType).(thisClusterNbName).Index==i;
    thisMatch=sum(thisClusterIndex(thisClass))/NbOfObs;
    As.(thisTrialType).(thisDataType).(thisClusterNbName).IndexMatch.Proba(counter,i)=thisMatch;
end
As.(thisTrialType).(thisDataType).(thisClusterNbName).IndexMatch.NbOfObs(counter)=NbOfObs;
end
%% Blank
counter=counter+1;
%% Brain regions
for thisBrainArea=1:size(As.Raw.Index.BrainAreaNames,1)
    counter=counter+1;
    As.(thisTrialType).(thisDataType).(thisClusterNbName).IndexMatch.Name{counter}=As.Raw.Index.BrainAreaNames(thisBrainArea,:)
    thisClass=As.(thisTrialType).Index.BrainAreas==thisBrainArea;
    NbOfObs=sum(thisClass);
for i=1:clusterNbKmeans
    thisClusterIndex=As.(thisTrialType).(thisDataType).(thisClusterNbName).Index==i;
    thisMatch=sum(thisClusterIndex(thisClass))/NbOfObs;
    As.(thisTrialType).(thisDataType).(thisClusterNbName).IndexMatch.Proba(counter,i)=thisMatch;
end
As.(thisTrialType).(thisDataType).(thisClusterNbName).IndexMatch.NbOfObs(counter)=NbOfObs;
end

end
