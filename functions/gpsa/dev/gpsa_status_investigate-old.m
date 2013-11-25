function gpsa_status_investigate(varargin)
% Investigates the checks for the studies and subjects and such
% 
% Author: A. Conrad Nied
% 
% Changelog:
% 2013.04.10 - Created in GPS1.8
% 2013.04.12 - Adding more checks
% 2013.04.25 - Changed subset design to condition design
% 2013.04.29 - Changed folders of some files

%% Process input

% Process input arguments
for i_argin = 1:nargin
    if(isstruct(varargin{i_argin}))
        state = varargin{i_argin};
    else
        checks = varargin{i_argin};
    end
end % for all input arguments

% Verify input arguments
if(~exist('state', 'var'))
    state = gpsa_get;
end
if(~exist('checks', 'var'))
    error('Not given a check')
end

% Verify input contents
if(~iscell(state.subject))
    state.subject = {state.subject};
end
if(~iscell(state.condition))
    state.condition = {state.condition};
end
if(~iscell(checks))
    checks = {checks};
end
N_checks = length(checks);

%% Load the files

% Call the study's status matrix
study_status_filename = sprintf('%s/parameters/%s/status.mat', state.dir, state.study);
if(exist(study_status_filename, 'file'))
    study_status = load(study_status_filename);
end

% Get the study
study = gpsa_parameter(state, state.study);

% Get the subjects
N_subjects = length(state.subject);
for i_subject = 1:N_subjects
    subjects(i_subject) = gpsa_parameter(state, state.subject{i_subject}); %#ok<AGROW>
end % for each subject

% Get the conditions
N_conditions = length(state.condition);
for i_condition = 1:N_conditions
    conditions(i_condition) = gpsa_parameter(state, state.condition{i_condition}); %#ok<AGROW>
end % for each condition

%% Assert the checks

% Go through the checks
for i_check = 1:N_checks
    tic;
    check = checks{i_check};
    
    % Determine the function of the check
    switch check
        case 'hasRawMRI'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) length(dir(subject.mri.rawdir)) > 2;
        case 'hasMPRageFile'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) exist(subject.mri.first_mpragefile, 'file') == 2;
        case 'hasOrganizedMRI'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition)  ~~exist([subject.mri.dir '/mri/T1.mgz'], 'file');
        case 'hasCortexRecon'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) length(dir([subject.mri.dir '/surf'])) > 2;
        case 'hasCortexLabels'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) length(dir([subject.mri.dir '/label'])) > 6;
        case 'hasCortexSourceSpace'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) ~isempty(dir([subject.mri.dir '/bem/*-src.fif']));
        case 'preppedMRIMEGCoreg'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) ~~exist([subject.mri.dir '/mri/T1-neuromag/sets/COR.fif'], 'file');
        case 'hasBEM'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) ~~exist([subject.mri.dir '/bem/outer_skin.surf'], 'file');
        case 'hasBEMfif'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) ~isempty(dir([subject.mri.dir '/bem/*-bem.fif']));
        case 'hasCortexMat'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) ~~exist(sprintf('%s/brain.mat', subject.mri.dir), 'file');
        case 'hasAverageCortex'
            subjs = 0; conds = 0;
            test = @(state, study, subject, condition) length(dir([study.mri.dir '/' study.average_name])) > 2;
        case 'hasMEGScan'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) ~isempty(dir(gps_filename(subject, 'meg_scan_gen')));
        case 'hasMarkedBads'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) ~isempty(dir(gps_filename(subject, 'meg_channels_bad')));
        case 'hasEOGProjection'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) ~isempty(subject.meg.projfile) && ...
                subject.meg.projfile(end) ~= '/' && ...
                ~~exist(subject.meg.projfile, 'file');
        case 'hasMRIMEGCoreg'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) ~~exist(subject.mri.corfile, 'file') &&...
                ~strcmp(subject.mri.corfile(end-6 : end), 'COR.fif');
        case 'extractedMEGEvents'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) length(dir(gps_filename(subject, 'meg_events_gen'))) >= length(subject.blocks);
        case 'hasGroupedEvents'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) length(dir(gps_filename(subject, 'meg_events_grouped_gen'))) >= length(subject.blocks);
        case 'processedBehaviorals'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) double(~isempty(subject.meg.behav.trialdata));
        case 'hasMEGScansFiltered'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) length(dir(gps_filename(study, subject, 'meg_scan_filtered_gen'))) >= length(subject.blocks);
        case 'hasMEGEvoked'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) length(dir(gps_filename(study, subject, 'meg_evoked_gen'))) >= 1;
        case 'hasAveMEEGFile'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) ~~exist(subject.mne.avefile, 'file');
        case 'hasAveMEEGCovFile'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) ~~exist(subject.mne.covfile, 'file');
        case 'hasMNEForwardModel'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) ~~exist(subject.mne.fwdfile, 'file');
        case 'hasMNEInverseModel'
            subjs = 1; conds = 0;
            test = @(state, study, subject, condition) ~~exist(subject.mne.invfile, 'file');
        case 'hasSTCAct'
            subjs = 1; conds = 2;
            test = @(state, study, subject, condition) ~~exist(gps_filename(subject, condition, 'mne_stc_lh'), 'file');
        case 'hasSTCActAveProj'
            subjs = 1; conds = 2;
            test = @(state, study, subject, condition) ~~exist(gps_filename(subject, condition, 'mne_stc_avebrain_lh'), 'file');
        case 'hasSTCActStudyAve'
            subjs = 0; conds = 2;
            test = @(state, study, subject, condition) ~~exist(gps_filename(study, condition, 'mne_stc_avesubj_lh'), 'file');
        case 'hasSubjectROIs'
            subjs = 1; conds = 3;
            test = @(state, study, subject, condition) ~isempty(dir(sprintf('%s/rois/%s/%s/*.label', study.granger.dir, condition.cortex.roiset, subject.name)));
        case 'hasAverageROIs'
            subjs = 0; conds = 3;
            test = @(state, study, subject, condition) ~isempty(dir(sprintf('%s/rois/%s/*.label', study.granger.dir, condition.cortex.roiset)));
        case 'hasMNICoordinateFile'
            subjs = 1; conds = 3;
            test = @(state, study, subject, condition) ~~exist(gps_filename(study, state, condition, 'granger_mni_coordinates'), 'file');
        case 'hasSomeGrangerResults'
            subjs = 0; conds = 3;
            test = @(state, study, subject, condition) length(dir(sprintf('%s/results/%s*.mat', study.granger.dir, condition.name))) >= 1;
        otherwise
            error(['There is no check for' check '\n'])
    end % switching on the data
    
    % Scan through the subjects and conditions for the check
    local_state = state;
    N_subjects = length(state.subject) ^ subjs;
    N_conditions = length(state.condition) ^ (conds > 0);
    for i_subject = 1:N_subjects
        subject = state.subject{i_subject};
        local_state.subject = subject;
        
        for i_condition = 1:N_conditions
            condition = state.condition{i_condition};
            local_state.condition = condition;
            result = double(test(local_state, study, subjects(i_subject), conditions(i_condition)));
            study_status.(check).(subject).(condition) = result;
%             fprintf('%8s %21s %3d\n', subject, condition, result);
        end % for each condition (or the first if sufficient)
    end % for each subject (or the first if sufficient)
%     fprintf('%30s %3.3f\n\n', check, toc);
end % for each check

save(study_status_filename, '-struct', 'study_status');

end % function