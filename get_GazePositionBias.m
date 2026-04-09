%% Step2--Gaze position calculation

%% start clean
clear; clc; close all;

%% parameters
for pp = [1:25];

baselineCorrect     = 0; 
removeTrials        = 0; % remove trials where gaze deviation larger than value specified below. Only sensible after baseline correction!
max_eye_pos         = 2; % remove trials with x_position bigger than 2 degrees visual angle (only works if removeTrials is on)

plotResults         = 1;

%% load epoched data of this participant
param = getSubjParam(pp);
load([param.path, '\epoched_data\eyedata_m6','__'  param.subjName], 'eyedata');

%% only keep channels of interest
cfg = [];
cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
eyedata = ft_selectdata(cfg, eyedata); % select x & y channels

%% reformat such that all data in single matrix of trial x channel x time
cfg = [];
cfg.keeptrials = 'yes';
tl = ft_timelockanalysis(cfg, eyedata); % realign the data: from trial*time cells into trial*channel*time?
tl.time = tl.time * 1000;

% dirty hack to get proxy for blink rate
tl.blink = squeeze(isnan(tl.trial(:,1,:))*100); % 0 where not nan, 1 where nan (putative blink, or eye close etc.)... *100 to get to percentage of trials where blink at that time

%% baseline correct?
if baselineCorrect
    tsel = tl.time >= -250 & tl.time <= 0; 
    bl = squeeze(mean(tl.trial(:,:,tsel),3));
    for t = 1:length(tl.time);
        tl.trial(:,:,t) = ((tl.trial(:,:,t) - bl));
    end
end

%% pixel to degree
[dva_x, dva_y] = frevede_pixel2dva(squeeze(tl.trial(:,1,:)), squeeze(tl.trial(:,2,:)));
tl.trial(:,1,:) = dva_x;
tl.trial(:,2,:) = dva_y;

%% remove trials with gaze deviation >= 2 dva
chX = ismember(tl.label, 'eyeX');
chY = ismember(tl.label, 'eyeY');

if plotResults
figure;
plot(tl.time, squeeze(tl.trial(:,chX,:)));
title('all trials - full time range');
end

if removeTrials
    tsel = tl.time>= 0 & tl.time <=3000; % only check within this time range of interest
    
    figure;
    subplot(1,2,1);
    plot(tl.time(tsel), squeeze(tl.trial(:,chX,tsel)));
    title('before');
    
    for trl = 1:size(tl.trial,1)
        oktrial(trl) = sum(sqrt(abs(tl.trial(trl,chX,tsel)).^2 + abs(tl.trial(trl,chY,tsel)).^2  ) > max_eye_pos) ==0;
    end
    tl.trial = tl.trial(oktrial,:,:);
    tl.trialinfo = tl.trialinfo(oktrial,:);

    subplot(1,2,2);
    plot(tl.time(tsel), squeeze(tl.trial(:,chX,tsel)));
    title('after');
    proportionOK(pp) = mean(oktrial)*100;
    fprintf('%s has %.2f%% OK trials\n\n', param.subjName, mean(oktrial)*100)

end

%% selection vectors for conditions -- this is where it starts to become interesting!
% cued item location is always target location
targL = ismember(tl.trialinfo(:,1), [31,32,35,36]);
targR = ismember(tl.trialinfo(:,1), [33,34,37,38]);
    
% which tone was low or high
low = ismember(tl.trialinfo(:,1), [31:34]);
high = ismember(tl.trialinfo(:,1), [35:38]);

% when was the target item presented
targ_1 = ismember(tl.trialinfo(:,1), [31,33,35,37]);
targ_2 = ismember(tl.trialinfo(:,1), [32,34,36,38]);
%% get relevant contrasts out
gaze = [];
gaze.time = tl.time;
gaze.label = {'all', 'targ1', 'targ2', 'low', 'high'};

for selection = [1:5] % conditions.
    if     selection == 1  sel = ones(size(targL));
    elseif selection == 2  sel = targ_1;
    elseif selection == 3  sel = targ_2;
    elseif selection == 4  sel = low;
    elseif selection == 5  sel = high;
    end

    gaze.dataL(selection,:) = squeeze(nanmean(tl.trial(sel&targL, chX,:)));
    gaze.dataR(selection,:) = squeeze(nanmean(tl.trial(sel&targR, chX,:)));
    gaze.blinkrate(selection,:) = squeeze(nanmean(tl.blink(sel, :)));
end

% add towardness field
gaze.towardness = (gaze.dataR - gaze.dataL) ./ 2;

%% plot
if plotResults
        figure; 
        hold on
        plot(gaze.time, gaze.dataL(1,:,:), 'b');
        plot(gaze.time, gaze.dataR(1,:,:), 'r');
        plot(gaze.time, gaze.towardness(1,:,:), 'k');
        title('Main effect');
        hold off

        figure;
        hold on;
        plot(gaze.time, gaze.blinkrate(1,:));
        plot(xlim, [0,0], '--k');
        legend('Blinkrate of all trials');
        title('blinkrate');
end

%% save
if baselineCorrect == 1     toadd1 = '_baselineCorrect';    else toadd1 = ''; end; % depending on this option, append to name of saved file.    
if removeTrials == 1        toadd2 = '_removeTrials';       else toadd2 = ''; end; % depending on this option, append to name of saved file.    

save([param.path, '\saved_data\gazePositionEffects', toadd1, toadd2, '__', param.subjName], 'gaze');

drawnow; 

%% close loops
end % end pp loop
