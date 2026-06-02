%% Step3-- gaze-shift calculation

%% start clean
clear; clc; close all;

%% parameter
oneOrTwoD  = 1;
oneOrTwoD_options = {'_1D','_2D'};

plotResults = 0;

%% loop over participants
for pp = [1:10];

    %% load epoched data of this participant data
     param = getSubjParam(pp);
     auditory_data = load([param.path, '\epoched_data\eyedata_m6', '__', param.subjName, '_a'], 'eyedata');
     visual_data = load([param.path, '\epoched_data\eyedata_m6', '__', param.subjName, '_v'], 'eyedata');
    
     auditory_data = auditory_data.eyedata;
     visual_data = visual_data.eyedata;

    %% only keep channels of interest
    cfg = [];
    cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
    
    auditory_data = ft_selectdata(cfg, auditory_data); % select x & y channels for auditory data
    visual_data = ft_selectdata(cfg, visual_data); % select x & y channels for visual data

    %% reformat all data to a single matrix of trial x channel x time
    cfg = [];
    cfg.keeptrials = 'yes';

    a_tl = ft_timelockanalysis(cfg, auditory_data); % realign the data: from trial*time cells into trial*channel*time?
    a_tl.time = a_tl.time * 1000;
    
    v_tl = ft_timelockanalysis(cfg, visual_data); % realign the data: from trial*time cells into trial*channel*time?
    v_tl.time = v_tl.time * 1000;

    %% pixel to degree
    [dva_x, dva_y] = frevede_pixel2dva(squeeze(a_tl.trial(:,1,:)), squeeze(a_tl.trial(:,2,:)));
    a_tl.trial(:,1,:) = dva_x;
    a_tl.trial(:,2,:) = dva_y;

    [dva_x, dva_y] = frevede_pixel2dva(squeeze(v_tl.trial(:,1,:)), squeeze(v_tl.trial(:,2,:)));
    v_tl.trial(:,1,:) = dva_x;
    v_tl.trial(:,2,:) = dva_y;

    %% selection vectors for conditions -- this is where it starts to become interesting!
    %%% AUDITORY %%%%
    % cued item location is always target location
    a_targL = ismember(a_tl.trialinfo(:,1), [31,32,35,36,39,310,313,314]);
    a_targR = ismember(a_tl.trialinfo(:,1), [33,34,37,38,311,312,315,316]);
      
    % which tone was low or high
    a_low = ismember(a_tl.trialinfo(:,1), [31:34,39:312]);
    a_high = ismember(a_tl.trialinfo(:,1), [35:38,313:316]);
    
    % when was the target item presented
    a_targ_1 = ismember(a_tl.trialinfo(:,1), [31,33,35,37,39,311,313,315]);
    a_targ_2 = ismember(a_tl.trialinfo(:,1), [32,34,36,38,310,312,314,316]);

    % channels
    a_chX = ismember(a_tl.label, 'eyeX');
    a_chY = ismember(a_tl.label, 'eyeY');

    %%% VISUAL %%%%
    % cued item location is always target location
    v_targL = ismember(v_tl.trialinfo(:,1), [31,32,35,36,39,310,313,314]);
    v_targR = ismember(v_tl.trialinfo(:,1), [33,34,37,38,311,312,315,316]);
      
    % which tone was low or high
    v_low = ismember(v_tl.trialinfo(:,1), [31:34,39:312]);
    v_high = ismember(v_tl.trialinfo(:,1), [35:38,313:316]);
    
    % when was the target item presented
    v_targ_1 = ismember(v_tl.trialinfo(:,1), [31,33,35,37,39,311,313,315]);
    v_targ_2 = ismember(v_tl.trialinfo(:,1), [32,34,36,38,310,312,314,316]);

    % channels
    v_chX = ismember(v_tl.label, 'eyeX');
    v_chY = ismember(v_tl.label, 'eyeY');

    %% get gaze shifts using our custom function
    cfg = [];

    data_input = squeeze(a_tl.trial);
    time_input = a_tl.time;
    [a_shiftsX, a_shiftsY, a_peakvelocity, a_times] = PBlab_gazepos2shift_2D(cfg, data_input(:,a_chX,:), data_input(:,a_chY,:), time_input);

    data_input = squeeze(v_tl.trial);
    time_input = v_tl.time;
    [v_shiftsX, v_shiftsY, v_peakvelocity, v_times] = PBlab_gazepos2shift_2D(cfg, data_input(:,v_chX,:), data_input(:,v_chY,:), time_input);

    %% select usable gaze shifts
    minDisplacement = 0;
    maxDisplacement = 1000;

    if oneOrTwoD == 1
        a_saccadesize = abs(a_shiftsX);
        v_saccadesize = abs(v_shiftsX);
    elseif oneOrTwoD == 2
        a_saccadesize = abs(a_shiftsX+a_shiftsY*1i);
        v_saccadesize = abs(v_shiftsX+v_shiftsY*1i);
    end

    a_shiftsL = a_shiftsX<0 & (a_saccadesize>minDisplacement & a_saccadesize<maxDisplacement);
    a_shiftsR = a_shiftsX>0 & (a_saccadesize>minDisplacement & a_saccadesize<maxDisplacement);

    v_shiftsL = v_shiftsX<0 & (v_saccadesize>minDisplacement & v_saccadesize<maxDisplacement);
    v_shiftsR = v_shiftsX>0 & (v_saccadesize>minDisplacement & v_saccadesize<maxDisplacement);

    %% get relevant contrasts out
    saccade = [];
    if a_times == v_times
        saccade.time = a_times;
    else
        throw('Times between the two different tasks are suddenly different!')
    end

    saccade.label = {'auditory_all', 'auditory_targ1', 'auditory_targ2', 'auditory_low', 'auditory_high', ...
    'visual_all', 'visual_targ1', 'visual_targ2', 'visual_green', 'visual_red'};

    for selection = [1:5] % auditory conditions
        if     selection == 1  sel = ones(size(a_targL));
        elseif selection == 2  sel = a_targ_1;
        elseif selection == 3  sel = a_targ_2;
        elseif selection == 4  sel = a_low;
        elseif selection == 5  sel = a_high;
        end

        saccade.toward(selection,:) =  (mean(a_shiftsL(a_targL&sel,:)) + mean(a_shiftsR(a_targR&sel,:))) ./ 2;
        saccade.away(selection,:)  =   (mean(a_shiftsL(a_targR&sel,:)) + mean(a_shiftsR(a_targL&sel,:))) ./ 2;
    end
    for selection = [6:10] % visual conditions
        if     selection == 6  sel = ones(size(v_targL));
        elseif selection == 7  sel = v_targ_1;
        elseif selection == 8  sel = v_targ_2;
        elseif selection == 9  sel = v_low;
        elseif selection == 10  sel = v_high;
        end

        saccade.toward(selection,:) =  (mean(v_shiftsL(v_targL&sel,:)) + mean(v_shiftsR(v_targR&sel,:))) ./ 2;
        saccade.away(selection,:)  =   (mean(v_shiftsL(v_targR&sel,:)) + mean(v_shiftsR(v_targL&sel,:))) ./ 2;
    end

    % add towardness field
    saccade.effect = (saccade.toward - saccade.away);
    
    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    
    saccade.toward = smoothdata(saccade.toward,2,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
    saccade.away   = smoothdata(saccade.away,2,  'movmean',integrationwindow)*1000;
    saccade.effect = smoothdata(saccade.effect,2,'movmean',integrationwindow)*1000;
       
    %% plot
    if plotResults
        figure; 
        hold on
        plot(saccade.time, saccade.toward(1,:,:), 'b');
        plot(saccade.time, saccade.away(1,:,:), 'r');
        plot(saccade.time, saccade.effect(1,:,:), 'k');
        title('Main effect');
        hold off
    end

    %% also get as function of saccade size - identical as above, except with extra loop over saccade size.
    binsize = 0.5;
    halfbin = binsize/2;

    saccadesize = [];
    saccadesize.dimord = 'chan_freq_time';
    saccadesize.freq = halfbin:0.1:7-halfbin; % shift sizes, as if "frequency axis" for time-frequency plot
    saccadesize.time = saccade.time;
    saccadesize.label = saccade.label;

    c = 0;
    for sz = saccadesize.freq;
        c = c+1;
        
        a_shiftsL = []; a_shiftsR = [];
        v_shiftsL = []; v_shiftsR = [];
        
        a_shiftsL = a_shiftsX<-sz+halfbin & a_shiftsX > -sz-halfbin; % left shifts within this range
        a_shiftsR = a_shiftsX>sz-halfbin  & a_shiftsX < sz+halfbin; % right shifts within this range
        
        v_shiftsL = v_shiftsX<-sz+halfbin & v_shiftsX > -sz-halfbin; % left shifts within this range
        v_shiftsR = v_shiftsX>sz-halfbin  & v_shiftsX < sz+halfbin; % right shifts within this range

        for selection = [1:5] % auditory conditions
            if     selection == 1  sel = ones(size(a_targL));
            elseif selection == 2  sel = a_targ_1;
            elseif selection == 3  sel = a_targ_2;
            elseif selection == 4  sel = a_low;
            elseif selection == 5  sel = a_high;
            end
    
            saccadesize.toward(selection,c,:) =  (mean(a_shiftsL(a_targL&sel,:)) + mean(a_shiftsR(a_targR&sel,:))) ./ 2;
            saccadesize.away(selection,c,:)  =   (mean(a_shiftsL(a_targR&sel,:)) + mean(a_shiftsR(a_targL&sel,:))) ./ 2;
        end
        for selection = [6:10] % visual conditions
            if     selection == 6  sel = ones(size(v_targL));
            elseif selection == 7  sel = v_targ_1;
            elseif selection == 8  sel = v_targ_2;
            elseif selection == 9  sel = v_low;
            elseif selection == 10  sel = v_high;
            end
    
            saccadesize.toward(selection,c,:) =  (mean(v_shiftsL(v_targL&sel,:)) + mean(v_shiftsR(v_targR&sel,:))) ./ 2;
            saccadesize.away(selection,c,:)  =   (mean(v_shiftsL(v_targR&sel,:)) + mean(v_shiftsR(v_targL&sel,:))) ./ 2;
        end

    end
   
    % add towardness field
    saccadesize.effect = (saccadesize.toward - saccadesize.away);

    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    saccadesize.toward = smoothdata(saccadesize.toward,3,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
    saccadesize.away   = smoothdata(saccadesize.away,  3,'movmean',integrationwindow)*1000;
    saccadesize.effect = smoothdata(saccadesize.effect,3,'movmean',integrationwindow)*1000;
    
    %% plot saccadesize effects
    if plotResults
        cfg = [];
        cfg.parameter = 'effect';
        cfg.figure = 'gcf';
        cfg.zlim = [-0.5, 0.5];
        figure;
        cfg.channel = 1;
        ft_singleplotTFR(cfg, saccadesize);
        colormap('jet');
        drawnow;
    end

    %% save
    save([param.path, '\saved_data\saccadeEffects', oneOrTwoD_options{oneOrTwoD} '__', param.subjName], 'saccade','saccadesize');
    %% close loops
end % end pp loop
