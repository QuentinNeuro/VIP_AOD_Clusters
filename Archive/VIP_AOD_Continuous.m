%% Parameters
thistrial=51;
SR=20;
wheel_th=0.4;
limxor=[];
limypup=[];
zsc=1;

isdbch=size(Analysis.AllData.Raw{1, thistrial}.Photometry,2)>1;
iswheel=isfield(Analysis.AllData.Raw{1, thistrial},'Wheel');
ispupil=isfield(Analysis.AllData.Raw{1,thistrial},'Pupil');

%% Data
photo1=Analysis.AllData.Raw{1, thistrial}.Photometry{1, 1};
photo1AVG=mean(photo1(1:20));
photo1STD=std2(photo1(1:20));
if ~zsc
photoDFF=100*(photo1-photo1AVG)/photo1AVG;
else
photoDFF=(photo1-photo1AVG)/photo1STD;
end
time=1/SR:1/SR:length(photoDFF)/SR;
limx=[time(1) time(end)];

if isdbch
photo2=Analysis.AllData.Raw{1, thistrial}.Photometry{1, 2};
photo2AVG=mean(photo2(1:20));
photo2STD=std2(photo2(1:20));
if ~zsc
photoDFF(:,end+1)=100*(photo2-photo2AVG)/photo2AVG;
else
    photoDFF(:,end+1)=(photo2-photo2AVG)/photo2STD;
end
end

if iswheel
wheel=Analysis.AllData.Raw{1, thistrial}.Wheel;
wheel=smooth(wheel);
wheeldiff=diff(wheel);
wheeldiffabs=abs(wheeldiff);
wheeldiffabs=smooth(wheeldiffabs);
wheeldiffabslog=wheeldiffabs>wheel_th;
end

if ispupil
   %timepupil=Analysis.AllData.Raw{1, thistrial}.PupilTime;
    pupil=Analysis.AllData.Raw{1, thistrial}.Pupil;
    pupilAVG=mean(pupil(1:20));
    pupilDP=100*(pupil-pupilAVG)/pupilAVG;
    timepupil=1/SR:1/SR:length(pupil)/SR;
end

licks=Analysis.AllData.Raw{1,thistrial}.Lick;
licksY=max(photoDFF(:,1),[],1)*ones(length(licks),1);

%% Reward


%% Figure
subplotNb=1+iswheel+ispupil;
subplotCounter=1;
if ~isempty(limxor)
    limx=limxor;
end

figure()
subplot(subplotNb,1,subplotCounter)
hold on
plot(time,photoDFF(:,1),'-k');
if isdbch
   plot(time,photoDFF(:,2),'-g');
end
plot(licks,licksY,'vb');
xlim(limx);

if iswheel
subplotCounter=subplotCounter+1;
subplot(subplotNb,1,subplotCounter)
hold on
plot(time(1:end-1),wheeldiffabs,'-r'); 
plot(time(1:end-1),wheeldiffabslog,'-p');
xlim(limx);
end

if ispupil
subplotCounter=subplotCounter+1;
subplot(subplotNb,1,subplotCounter)
hold on
plot(timepupil,pupilDP,'-b'); 
xlim(limx);
if ~isempty(limypup)
ylim(limypup)
end
end
