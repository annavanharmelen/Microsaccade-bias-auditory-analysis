function param = getSubjParam(pp)

%% participant-specific notes

%% set path and pp-specific file locations
unique_numbers = [68, 43, 75, 79, 29, 63, 77, 66, 13, 27]; %needs to be in the right order

param.path = '\\scistor.vu.nl\shares\FGB-ETP-CogPsy-ProactiveBrainLab\core_lab_members\Anna\Data\m6.2 - auditory vs visual\';

if pp < 10
    param.subjName = sprintf('pp0%d', pp);
else
    param.subjName = sprintf('pp%d', pp);
end

param.auditory_beh = [param.path, sprintf('data_session_%d_%s.csv', pp, "a")];
param.visual_beh = [param.path, sprintf('data_session_%d_%s.csv', pp, "v")];

param.auditory_eye = [param.path, sprintf('%d_%d_%s.asc', pp, unique_numbers(pp), "a")];
param.visual_eye = [param.path, sprintf('%d_%d_%s.asc', pp, unique_numbers(pp), "v")];