function varargout = gpsa_mne_avesubj(varargin)
% Averages the MNE data for all subjects
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.12.29 - Originally created as GPS1.6(-)/ave_mne.m
% 2012.09.13 - Last modified in GPS1.6(-)
% 2012.10.09 - Updated to GPS1.7 format
% 2013.04.16 - GPS 1.8, Updated the status check to the new system and
% added gps_filename identifiers for files
% 2013.04.24 - Changed subset/subsubset to condition hierarchy
% 2013.04.30 - Gets filenames from gps_filename.m
% 2013.05.01 - Corrected error in gps_filename evocation
% 2013.06.20 - Reverted the status check to the individual system and
% creates MNE/ave directory now

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 0; % Subject specific?
    report.spec_cond = 1; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    study = gpsa_parameter(state.study);
    condition = gpsa_parameter(state.condition);
    state.function = 'gpsa_mne_avesubj';
    tbegin = tic;
    
    desc_filename = gps_filename(study, condition, 'mne_stc_avesubj_command');
    folder = desc_filename(1:find(desc_filename == '/', 1, 'last') - 1);
    if(~exist(folder, 'dir')); mkdir(folder); end
    desc_file = fopen(desc_filename, 'w');
    
    for i_subject = 1:length(condition.subjects)
        subject = gpsa_parameter(condition.subjects{i_subject});
        
        fprintf(desc_file, 'stc %s\n',...
            gps_filename(subject, condition, 'mne_stc_avebrain'));
    end % For each subject
    
    % Average Subject MNE
    folder = gps_filename(study, condition, 'mne_stc_avesubj_dir');
    if(~exist(folder, 'dir')); mkdir(folder); end
    fprintf(desc_file,'\ndeststc %s\n',...
        gps_filename(study, condition, 'mne_stc_avesubj'));
    unix_command = sprintf('mne_average_estimates --desc %s', desc_filename);
    unix(unix_command);
    
    % Record the process
    gpsa_log(state, toc(tbegin), unix_command);
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    study = gpsa_parameter(state, state.study);
    condition = gpsa_parameter(state, state.condition);
    
    if(strcmp(condition.subjects{1}, condition.cortex.brain))
        report.ready = 0; report.progress = 0; report.applicable = 0;
    else
        N_subjects = length(condition.subjects);
        report.ready = 0;
        for i_subject = 1:N_subjects
            subject = gpsa_parameter(state,condition.subjects{i_subject});
            filename = gps_filename(subject, condition, 'mne_stc_avebrain_lh');
            report.ready = report.ready + ~~exist(filename, 'file') / N_subjects;
        end
        report.progress = ~~exist(gps_filename(study, condition, 'mne_stc_avesubj_lh'), 'file');
    end
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function