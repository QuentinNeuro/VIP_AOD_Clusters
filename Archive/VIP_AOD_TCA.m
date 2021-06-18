% VIP_AOD_TCA
color = lines(6);

[pupilSort pupilIndex]=sort(pupil);
[outSort outIndex]=sort(outcome);

trialF_pupsort=trialF(pupilIndex,:);
trialF_outsort=trialF(outIndex,:);


trialF_pup1_AVG=mean(trialF(pupil==1,:),1);
sizePup1=length(trialF_pupsort(pupil==1));
trialF_pup2_AVG=mean(trialF(pupil==2,:),1);
sizePup2=length(trialF_pupsort(pupil==2));
trialF_out3_AVG=mean(trialF(outcome==3,:),1);
sizeOut3=length(trialF_outsort(outcome==3));
trialF_out4_AVG=mean(trialF(outcome==4,:),1);
sizeOut4=length(trialF_outsort(outcome==4));


counter=0;
figure()
for thisF=1:5
    % latent factor
    subplot(5,3,thisF+counter)
    hold on
    plot(latentF(:,thisF))
    legend off
    ylabel('DF/F');
    ylim([-0.5 2]);
    
    if thisF+counter==1
       title('Latent temporal factors')
    end
    
    % Arousal
    subplot(5,3,thisF+counter+1)
    hold on
    plot([0 sizePup1],[trialF_pup1_AVG(thisF) trialF_pup1_AVG(thisF)],'-k');
    gscatter(1:size(trialF,1),trialF_pupsort(:,thisF),pupilSort,color([1 3],:));
    plot([sizePup1+1 sizePup1+sizePup2],[trialF_pup2_AVG(thisF) trialF_pup2_AVG(thisF)],'-k');
    [h,p]=ttest2(trialF(pupil==1,thisF),trialF(pupil==2,thisF));
    xlim([-1 size(trialF,1)+1]);
    
    switch thisF+counter+1
        case 2
    title('Trial Factors - Arousal')
    legend(sprintf('p=%0.3f',p),'Low','High')
        case 14
  	legend(sprintf('p=%0.3f',p))
    xlabel('trial #');
        otherwise
    legend(sprintf('p=%0.3f',p))
    end
    
    subplot(5,3,thisF+counter+2)
    hold on
    plot([0 sizeOut3],[trialF_out3_AVG(thisF) trialF_out3_AVG(thisF)],'-k');
    gscatter(1:size(trialF,1),trialF_outsort(:,thisF),outSort,color([5 2],:));
    plot([sizeOut3+1 sizeOut3+sizeOut4],[trialF_out4_AVG(thisF) trialF_out4_AVG(thisF)],'-k');
    [h,p]=ttest2(trialF(outcome==3,thisF),trialF(outcome==4,thisF));
    
    switch thisF+counter+2
        case 3
    title('Trial Factors - Outcome')
    legend(sprintf('p=%0.3f',p),'Hit','FA')
        case 15
  	legend(sprintf('p=%0.3f',p))
    xlabel('trial #');
        otherwise
    legend(sprintf('p=%0.3f',p))
    end
    
    counter=counter+2;
end