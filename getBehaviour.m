clear all
close all
clc

%% set parameters and loops
display_percentage_ok = 0;
plot_individuals = 1;
plot_averages = 1;

pp2do = [1];
p = 0;

subplot_size = 1;

for pp = pp2do
    p = p+1;
    ppnum(p) = pp;
    figure_nr = 1;
    
    param = getSubjParam(pp);
    disp(['getting data from ', param.subjName]);
    
    %% load actual behavioural data
    behdata = readtable(param.log);

    %% check percentage oktrials
    % select trials with reasonable decision times
    oktrials = abs(zscore(behdata.idle_reaction_time_in_ms))<=3; 
    percentageok(p) = mean(oktrials)*100;
  
    % display percentage ok trials
    if display_percentage_ok
        fprintf('%s has %.2f%% oktrials\n\n', param.subjName, percentageok(p,1))
    end
    %% basic data checks, each pp in own subplot
    if plot_individuals
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(behdata.idle_reaction_time_in_ms,50);
        title(['decision time - pp ', num2str(pp2do(p))]);
        xlim([0 2000]);
        ylim([0 150]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(behdata.response_time_in_ms, 50);
        title(['response time - pp ', num2str(pp2do(p))]);
        xlim([0 2010]);
        ylim([0 150]);
        
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(behdata.performance,50);       
        title(['freq offset (levels) - pp ', num2str(pp2do(p))]);
        xlim([-10 10]);
        
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(behdata.performance_abs,50);     
        title(['abs performance - pp ', num2str(pp2do(p))]);
        xlim([0 10]);
    end

    
    %% trial selections
    left_trials = ismember(behdata.target_position, {'left'});
    right_trials = ismember(behdata.target_position, {'right'});

    first_target_trials = behdata.target_item == 1;
    second_target_trials = behdata.target_item == 2;

    low_trials = ismember(behdata.target_pitch_cat, {'low'});
    high_trials = ismember(behdata.target_pitch_cat, {'high'});

    premature_trials = ismember(behdata.premature_pressed, {'True'});
    
    %% extract data of interest
    overall_dt(p,1) = mean(behdata.idle_reaction_time_in_ms(oktrials), "omitnan");
    overall_abs_error(p,1) = mean(behdata.performance_abs(oktrials), "omitnan");
    overall_error(p,1) = mean(behdata.performance(oktrials), "omitnan");
    
    labels = {'low', 'high'};

    % get reaction time as function of pitch category
    dt_pitch(p,1) = mean(behdata.idle_reaction_time_in_ms(low_trials&oktrials), "omitnan");
    dt_pitch(p,2) = mean(behdata.idle_reaction_time_in_ms(high_trials&oktrials), "omitnan");
    
    % get error as function of pitch category
    error_pitch(p,1) = mean(behdata.performance_abs(low_trials&oktrials), "omitnan");
    error_pitch(p,2) = mean(behdata.performance_abs(high_trials&oktrials), "omitnan");

    % get responded frequency as function of pitch category
    response_pitch(p,1) = mean(behdata.response_freq(low_trials&oktrials), "omitnan");
    response_pitch(p,2) = mean(behdata.response_freq(high_trials&oktrials), "omitnan");

    %% get behavioural effect as function of target pitch
    frequencies = [300, 316, 332, 350, 368, 408, 429, 451, 475, 500];

    i = 0;
    for freq = frequencies
        i = i + 1;

        trial_sel = behdata.target_pitch == freq;

        dt_pitches(p,i) = mean(behdata.idle_reaction_time_in_ms(trial_sel&oktrials), "omitnan");
        rt_pitches(p,i) = mean(behdata.response_time_in_ms(trial_sel&oktrials), "omitnan");
        response_pitches(p,i) = mean(behdata.response_freq(trial_sel&oktrials), "omitnan");
        error_pitches(p,i) = mean(behdata.performance(trial_sel&oktrials), "omitnan");
        abs_error_pitches(p,i) = mean(behdata.performance_abs(trial_sel&oktrials), "omitnan");
    end
    
end

if plot_averages
 %% check performance
    figure; 
    figure_nr = figure_nr+1;
    subplot(4,1,1);
    bar(ppnum, overall_dt(:,1));
    title('overall decision time');
    ylim([0 900]);
    xlabel('pp #');

    subplot(4,1,2);
    bar(ppnum, overall_error(:,1));
    title('overall error');
    xlabel('pp #');

    subplot(4,1,3);
    hold on
    bar(ppnum, overall_abs_error(:,1));
    plot([0, max(ppnum)], [250 250]);
    title('overall abs error');
    xlabel('pp #');

    subplot(4,1,4);
    bar(ppnum, percentageok);
    title('percentage ok trials');
    ylim([90 100]);
    xlabel('pp #');

    %% effect of target pitch category on behaviour
    figure(figure_nr);
    figure_nr = figure_nr+1;
    bar(mean(dt_pitch, 1));
    xticklabels(labels)
    ylabel('Decision time (ms)');

    figure(figure_nr);
    figure_nr = figure_nr+1;
    bar(mean(error_pitch, 1));
    xticklabels(labels)
    ylabel('Reproduction error (a.u.)');

    figure(figure_nr);
    figure_nr = figure_nr+1;
    bar(mean(response_pitch, 1));
    xticklabels(labels)
    ylabel('Reproduced pitch (Hz)');

    %% effect of target pitch on behaviour
    figure(figure_nr);
    figure_nr = figure_nr+1;
    bar(mean(dt_pitches, 1));
    xticklabels(frequencies);
    xlabel('Target frequency (Hz)');
    ylabel('Decision time (ms)');
    
    figure(figure_nr);
    figure_nr = figure_nr+1;
    bar(mean(rt_pitches, 1));
    xticklabels(frequencies);
    xlabel('Target frequency (Hz)');
    ylabel('Response time (ms)');

    figure(figure_nr);
    figure_nr = figure_nr+1;
    hold on
    plot(frequencies, response_pitches', '-o');
    plot(frequencies, frequencies, '-o');
    xticks(frequencies);
    xticklabels(frequencies);
    xlabel('Target frequency (Hz)');
    ylabel('Responded frequency (Hz)');
    legend({'p1', 'ideal pp'});

    figure(figure_nr);
    figure_nr = figure_nr+1;
    bar(mean(error_pitches, 1));
    xticklabels(frequencies);
    xlabel('Target frequency (Hz)');
    ylabel('Reproduction error (a.u.)');

    figure(figure_nr);
    figure_nr = figure_nr+1;
    bar(mean(abs_error_pitches, 1));
    xticklabels(frequencies);
    xlabel('Target frequency (Hz)');
    ylabel('ABS reproduction error (a.u.)');

end
