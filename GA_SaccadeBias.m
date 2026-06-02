
%% Step3b--grand average plots of gaze-shift (saccade) results

%% start clean
clear; clc; close all;
    
%% parameters
oneOrTwoD       = 1;
oneOrTwoD_options = {'_1D','_2D'};

pp2do           = [1:10];

nsmooth         = 200;
plotSinglePps   = 1;
plotGAs         = 1;
xlimtoplot      = [-100 1500];

subplot_size = 4;

%% load and aggregate the data from all pp
s = 0;
for pp = pp2do
    s = s+1;

    % get participant data
    param = getSubjParam(pp);

    % load
    disp(['getting data from participant ', param.subjName]);
    load([param.path, '\saved_data\saccadeEffects', oneOrTwoD_options{oneOrTwoD} '__', param.subjName], 'saccade','saccadesize');
    
    % smooth?
    if nsmooth > 0
        for i = 1:size(saccade.toward,1)
            saccade.toward(i,:)  = smoothdata(squeeze(saccade.toward(i,:)), 'gaussian', nsmooth);
            saccade.away(i,:)    = smoothdata(squeeze(saccade.away(i,:)), 'gaussian', nsmooth);
            saccade.effect(i,:)  = smoothdata(squeeze(saccade.effect(i,:)), 'gaussian', nsmooth);
        end

        %also smooth saccadesize data over time.
        for i = 1:size(saccadesize.toward,1)
            for j = 1:size(saccadesize.toward,2)
                saccadesize.toward(i,j,:) = smoothdata(squeeze(saccadesize.toward(i,j,:)), 'gaussian', nsmooth);
                saccadesize.away(i,j,:)   = smoothdata(squeeze(saccadesize.away(i,j,:)), 'gaussian', nsmooth);
                saccadesize.effect(i,j,:) = smoothdata(squeeze(saccadesize.effect(i,j,:)), 'gaussian', nsmooth);
            end
        end
    end

    % put into matrix, with pp as first dimension
    d1(s,:,:) = saccade.toward;
    d2(s,:,:) = saccade.away;
    d3(s,:,:) = saccade.effect;

    d4(s,:,:,:) = saccadesize.toward;
    d5(s,:,:,:) = saccadesize.away;
    d6(s,:,:,:) = saccadesize.effect;
end

%% make GA for the saccadesize fieldtrip structure data, to later plot as "time-frequency map" with fieldtrip. For timecourse data, we directly plot from d structures above. 
saccadesize.toward = squeeze(mean(d4));
saccadesize.away   = squeeze(mean(d5));
saccadesize.effect = squeeze(mean(d6));

%% all subs
if plotSinglePps
    % toward & away - auditory all
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp); hold on;
        plot(saccade.time, squeeze(d1(sp,1,:)));
        plot(saccade.time, squeeze(d2(sp,1,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot);
        title(pp2do(sp));
    end
    legend({'toward (auditory)', 'away (auditory)'});

    % toward vs away - auditory all
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp); hold on;
        plot(saccade.time, squeeze(d3(sp,1,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot);
        title(pp2do(sp));
    end
    legend({'auditory all'});

    % towardness sizecourse - auditory all
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp);
        cfg = [];
        cfg.parameter = 'effect';
        cfg.figure = 'gcf';
        cfg.zlim = [-.1 .1];
        cfg.xlim = xlimtoplot;
        saccadesize.effect = squeeze(d6(sp,:,:,:)); % put in data from this pp
        cfg.channel = 1; % all auditory
        ft_singleplotTFR(cfg, saccadesize);
        title(pp2do(sp));
        colormap('jet');
    end

    % toward & away - visual all
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp); hold on;
        plot(saccade.time, squeeze(d1(sp,6,:)));
        plot(saccade.time, squeeze(d2(sp,6,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot);
        title(pp2do(sp));
    end
    legend({'toward (visual)', 'away (visual)'});

    % toward vs away - visual all
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp); hold on;
        plot(saccade.time, squeeze(d3(sp,6,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot);
        title(pp2do(sp));
    end
    legend({'visual all'});

    % towardness sizecourse - visual all
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp);
        cfg = [];
        cfg.parameter = 'effect';
        cfg.figure = 'gcf';
        cfg.zlim = [-.1 .1];
        cfg.xlim = xlimtoplot;
        hold on;
        saccadesize.effect = squeeze(d6(sp,:,:,:)); % put in data from this pp
        cfg.channel = 6; % all visual
        ft_singleplotTFR(cfg, saccadesize);
        title(pp2do(sp));
        colormap('jet');
    end
end

%% Plot grand average data patterns of interest, with error bars
if plotGAs
    % plot towardness of auditory and visual
    figure; 
    hold on
    p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,1,:)), 'b', 'se');
    p2 = frevede_errorbarplot(saccade.time, squeeze(d3(:,6,:)), 'r', 'se');
    xline(0, '--');
    yline(0, '--');
    legend([p1, p2], {'auditory', 'visual'});
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    xlim(xlimtoplot);
    hold off

    % plot toward and away of auditory
    figure; 
    hold on
    p1 = frevede_errorbarplot(saccade.time, squeeze(d1(:,1,:)), 'b', 'se');
    p2 = frevede_errorbarplot(saccade.time, squeeze(d2(:,1,:)), 'r', 'se');
    legend([p1, p2], {'toward', 'away'});
    title('Auditory');
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    xlim(xlimtoplot);
    hold off

    % plot toward and away of auditory
    figure; 
    hold on
    p1 = frevede_errorbarplot(saccade.time, squeeze(d1(:,6,:)), 'b', 'se');
    p2 = frevede_errorbarplot(saccade.time, squeeze(d2(:,6,:)), 'r', 'se');
    legend([p1, p2], {'toward', 'away'});
    title('Visual');
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    xlim(xlimtoplot);
    hold off
    
    %% just effect as function of saccade size
    cfg = [];
    cfg.parameter = 'effect';
    cfg.figure = 'gcf';
    % cfg.zlim = 'maxabs';
    cfg.zlim = [-0.12, 0.12];
    cfg.xlim = xlimtoplot;  
    cfg.colormap = 'jet';
    
    % for main conditions (auditory and visual)
    c = 0;

    figure;
    for chan = [1,6]
        c = c + 1;
        hold on
        cfg.channel = chan;
        subplot(1,2,c);
        saccadesize.effect = squeeze(mean(d6(:,:,:,:))); % put in data from all pp
        ft_singleplotTFR(cfg, saccadesize);
        ylabel('Saccade size (dva)');
        xlabel('Time (ms)');
        xlim(xlimtoplot);
    end
  
end
