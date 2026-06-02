clear all
close all
clc

%% set parameters and loops
display_percentage_ok = 1;
plot_individuals = 0;
plot_averages = 1;

pp2do = [1:10];
p = 0;

subplot_size = 4;

for pp = pp2do
    p = p+1;
    ppnum(p) = pp;
    figure_nr = 1;
    
    param = getSubjParam(pp);
    disp(['getting data from ', param.subjName]);
    
    %% load actual behavioural data
    auditory_data = readtable(param.auditory_beh);
    visual_data = readtable(param.visual_beh);

    %% check percentage oktrials
    % select trials with reasonable decision times
    a_oktrials = abs(zscore(auditory_data.idle_reaction_time_in_ms))<=3;
    v_oktrials = abs(zscore(visual_data.idle_reaction_time_in_ms))<=3;
    
    % calculate percentage OK trials for each task type
    percentageok(p,1) = mean(a_oktrials)*100;
    percentageok(p,2) = mean(v_oktrials)*100;

    % display average percentage ok trials
    if display_percentage_ok
        fprintf('%s has %.2f%% oktrials\n\n', param.subjName, mean(percentageok(p,:)))
    end

    %% basic data checks, each pp in own subplot
    if plot_individuals
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(auditory_data.idle_reaction_time_in_ms,50);
        title(['AUDITORY decision time - pp', num2str(pp2do(p))]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(visual_data.idle_reaction_time_in_ms,50);
        title(['VISUAL decision time - pp', num2str(pp2do(p))]);
        
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(auditory_data.response_time_in_ms,50);
        title(['AUDITORY response time - pp', num2str(pp2do(p))]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(visual_data.response_time_in_ms,50);
        title(['VISUAL response time - pp', num2str(pp2do(p))]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(auditory_data.performance,50);
        title(['AUDITORY performance - pp', num2str(pp2do(p))]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(visual_data.performance,50);
        title(['VISUAL performance - pp', num2str(pp2do(p))]);
    end
    
    %% %%%% AUDITORY DATA EXTRACTION %%%%
    %% auditory trial selections
    a_left_trials = ismember(auditory_data.target_position, {'left'});
    a_right_trials = ismember(auditory_data.target_position, {'right'});

    a_first_target_trials = auditory_data.target_item == 1;
    a_second_target_trials = auditory_data.target_item == 2;

    a_low_trials = ismember(auditory_data.target_pitch_cat, {'low'});
    a_high_trials = ismember(auditory_data.target_pitch_cat, {'high'});

    a_premature_trials = ismember(auditory_data.premature_pressed, {'True'});
    
    %% extract auditory data of interest
    a_overall_dt(p,1) = mean(auditory_data.idle_reaction_time_in_ms(a_oktrials), "omitnan");
    a_overall_rt(p,1) = mean(auditory_data.response_time_in_ms(a_oktrials), "omitnan");
    a_overall_abs_error(p,1) = mean(auditory_data.performance_abs(a_oktrials), "omitnan");
    a_overall_error(p,1) = mean(auditory_data.performance(a_oktrials), "omitnan");
    
    a_labels = {'low pitch', 'high pitch'};

    % get reaction time as function of pitch category
    a_dt_pitch(p,1) = mean(auditory_data.idle_reaction_time_in_ms(a_low_trials&a_oktrials), "omitnan");
    a_dt_pitch(p,2) = mean(auditory_data.idle_reaction_time_in_ms(a_high_trials&a_oktrials), "omitnan");
    
    % get error as function of pitch category
    a_error_pitch(p,1) = mean(auditory_data.performance_abs(a_low_trials&a_oktrials), "omitnan");
    a_error_pitch(p,2) = mean(auditory_data.performance_abs(a_high_trials&a_oktrials), "omitnan");

    % get responded frequency as function of pitch category
    a_response_pitch(p,1) = mean(auditory_data.response_freq(a_low_trials&a_oktrials), "omitnan");
    a_response_pitch(p,2) = mean(auditory_data.response_freq(a_high_trials&a_oktrials), "omitnan");

    %% get behavioural effect as function of target pitch
    frequencies = [300, 316, 332, 350, 368, 408, 429, 451, 475, 500];

    i = 0;
    for freq = frequencies
        i = i + 1;

        pitch_sel = auditory_data.target_pitch == freq;

        a_dt_pitches(p,i) = mean(auditory_data.idle_reaction_time_in_ms(pitch_sel&a_oktrials), "omitnan");
        a_rt_pitches(p,i) = mean(auditory_data.response_time_in_ms(pitch_sel&a_oktrials), "omitnan");
        a_response_pitches(p,i) = mean(auditory_data.response_freq(pitch_sel&a_oktrials), "omitnan");
        a_error_pitches(p,i) = mean(auditory_data.performance(pitch_sel&a_oktrials), "omitnan");
        a_abs_error_pitches(p,i) = mean(auditory_data.performance_abs(pitch_sel&a_oktrials), "omitnan");
    end
    
    %% %%%% VISUAL DATA EXTRACTION %%%%
    %% visual trial selections
    v_left_trials = ismember(visual_data.target_position, {'left'});
    v_right_trials = ismember(visual_data.target_position, {'right'});

    v_first_target_trials = visual_data.target_item == 1;
    v_second_target_trials = visual_data.target_item == 2;

    v_low_trials = ismember(visual_data.target_pitch_cat, {'low'});
    v_high_trials = ismember(visual_data.target_pitch_cat, {'high'});

    v_premature_trials = ismember(visual_data.premature_pressed, {'True'});
    
    %% extract visual data of interest
    v_overall_dt(p,1) = mean(visual_data.idle_reaction_time_in_ms(v_oktrials), "omitnan");
    v_overall_rt(p,1) = mean(visual_data.response_time_in_ms(v_oktrials), "omitnan");
    v_overall_abs_error(p,1) = mean(visual_data.performance_abs(v_oktrials), "omitnan");
    v_overall_error(p,1) = mean(visual_data.performance(v_oktrials), "omitnan");
    
    v_labels = {'green hue', 'red hue'};

    % get reaction time as function of colour category
    v_dt_hue(p,1) = mean(visual_data.idle_reaction_time_in_ms(v_low_trials&v_oktrials), "omitnan");
    v_dt_hue(p,2) = mean(visual_data.idle_reaction_time_in_ms(v_high_trials&v_oktrials), "omitnan");
    
    % get error as function of colour category
    v_error_hue(p,1) = mean(visual_data.performance_abs(v_low_trials&v_oktrials), "omitnan");
    v_error_hue(p,2) = mean(visual_data.performance_abs(v_high_trials&v_oktrials), "omitnan");

    % get responded hue as function of colour category
    v_response_hue(p,1) = mean(str2double(erase(visual_data.response_colour(v_low_trials&v_oktrials), ["[", ", 0.2, 0.5]"])), "omitnan");
    v_response_hue(p,2) = mean(str2double(erase(visual_data.response_colour(v_high_trials&v_oktrials), ["[", ", 0.2, 0.5]"])), "omitnan");

    %% get behavioural effect as function of target hue
    hues = [105, 90, 75, 60, 45, 0, 345, 330, 315];

    i = 0;
    for hue = hues
        i = i + 1;

        hue_sel = str2double(erase(visual_data.target_colour,["[", ", 0.2, 0.5]"])) == hue;

        v_dt_hues(p,i) = mean(visual_data.idle_reaction_time_in_ms(hue_sel &v_oktrials), "omitnan");
        v_rt_hues(p,i) = mean(visual_data.response_time_in_ms(hue_sel &v_oktrials), "omitnan");
        v_response_hues(p,i) = mean(str2double(erase(visual_data.response_colour(hue_sel&v_oktrials), ["[", ", 0.2, 0.5]"])), "omitnan");
        v_error_hues(p,i) = mean(visual_data.performance(hue_sel &v_oktrials), "omitnan");
        v_abs_error_hues(p,i) = mean(visual_data.performance_abs(hue_sel &v_oktrials), "omitnan");
    end
end

if plot_averages
 %% check performance
    figure(figure_nr);
    figure_nr = figure_nr+1;
    subplot(4,2,1);
    bar(ppnum, a_overall_dt(:,1));
    title('AUDITORY overall decision time');
    ylim([0,1000]);
    xlabel('pp #');

    subplot(4,2,3);
    bar(ppnum, a_overall_rt(:,1));
    title('overall response time');
    ylim([0,4000]);
    xlabel('pp #');

    subplot(4,2,5);
    bar(ppnum, a_overall_abs_error(:,1));
    title('overall error');
    xlabel('pp #');

    subplot(4,2,7);
    hold on
    bar(ppnum, a_overall_error(:,1));
    title('overall signed error');
    xlabel('pp #');
    
    subplot(4,2,2);
    bar(ppnum, v_overall_dt(:,1));
    title('VISUAL overall decision time');
    ylim([0,1000]);
    xlabel('pp #');

    subplot(4,2,4);
    bar(ppnum, v_overall_rt(:,1));
    title('overall response time');
    ylim([0,4000]);
    xlabel('pp #');

    subplot(4,2,6);
    bar(ppnum, v_overall_abs_error(:,1));
    title('overall error');
    xlabel('pp #');

    subplot(4,2,8);
    hold on
    bar(ppnum, v_overall_error(:,1));
    title('overall abs error');
    xlabel('pp #');

    %% effect of target pitch category on behaviour
    figure(figure_nr);
    figure_nr = figure_nr+1;
    subplot(1,2,1);
    hold on
    bar([1,2], mean(a_dt_pitch, 1));
    errorbar([mean(a_dt_pitch, 1)], std(a_dt_pitch, 1) / sqrt(size(pp2do,2)), 'LineStyle', 'none');
    xticks([1,2]);
    xticklabels([a_labels]);
    ylabel('Decision time (ms)');
    title('AUDITORY - DT');

    subplot(1,2,2);
    hold on
    bar([1,2], mean(a_error_pitch, 1));
    errorbar([mean(a_error_pitch, 1)], std(a_error_pitch, 1) / sqrt(size(pp2do,2)), 'LineStyle', 'none');
    xticks([1,2]);
    xticklabels([a_labels]);
    ylabel('Error (a.u.)')
    title('AUDITORY - ERROR');

    %% effect of target hue category on behaviour
    figure(figure_nr);
    figure_nr = figure_nr+1;
    subplot(1,2,1);
    hold on
    bar([1,2], mean(v_dt_hue, 1));
    errorbar([mean(v_dt_hue, 1)], std(v_dt_hue, 1) / sqrt(size(pp2do,2)), 'LineStyle', 'none');
    xticks([1,2]);
    xticklabels([v_labels]);
    ylabel('Decision time (ms)');
    title('VISUAL - DT');

    subplot(1,2,2);
    hold on
    bar([1,2], mean(v_error_hue, 1));
    errorbar([mean(v_error_hue, 1)], std(v_error_hue, 1) / sqrt(size(pp2do,2)), 'LineStyle', 'none');
    xticks([1,2]);
    xticklabels([v_labels]);
    ylabel('Error (a.u.)')
    title('VISUAL - ERROR');

    %% main confirmation that people do do auditory task
    figure(figure_nr);
    figure_nr = figure_nr+1;
    hold on
    plot([1:size(frequencies, 2)], mean(a_response_pitches));
    plot([1:size(frequencies, 2)], frequencies);
    errorbar([1:size(frequencies, 2)], [mean(a_response_pitches)], [std(a_response_pitches) ./ sqrt(size(pp2do,2))], 'LineStyle', 'none', 'Color', 'k');
    xticks([1:size(frequencies, 2)]);
    xticklabels(frequencies);
    xlabel("Item condition");
    ylabel("Reported frequency (Hz)");

    %% main confirmation that people do do visual task
    figure(figure_nr);
    figure_nr = figure_nr+1;
    hold on
    plot([1:size(hues, 2)], mean(v_response_hues));
    plot([1:size(hues, 2)], hues);
    errorbar([1:size(hues, 2)], [mean(v_respnse_hues)], [std(v_response_hues) ./ sqrt(size(pp2do,2))], 'LineStyle', 'none', 'Color', 'k');
    xticks([1:size(hues, 2)]);
    xticklabels(hues);
    xlabel("Item condition");
    ylabel("Reported hue (deg)");

    %% main confirmation that people do do visual task (with order changed to make more interpretable)
    order = order;
    
    figure(figure_nr);
    figure_nr = figure_nr+1;
    hold on
    plot([1:size(hues, 2)], mean(v_response_hues(:, order)));
    plot([1:size(hues, 2)], hues(order));
    errorbar([1:size(hues, 2)], [mean(v_response_hues(:, order))], [std(v_response_hues(:, order)) ./ sqrt(size(pp2do,2))], 'LineStyle', 'none', 'Color', 'k');
    xticks([1:size(hues, 2)]);
    xticklabels(hues(order));
    xlabel("Item condition");
    ylabel("Reported hue (deg)");
    
end
