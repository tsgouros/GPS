function varargout = gpsa_mri_avesurf(varargin)
% Averages the MRI surface data for all subjects
%
% Author: A. Conrad Nied
%
% Changelog:
% 2011.12.29 - Originally created as GPS1.6(-)/ave_surface.m
% 2012.05.10 - Last modified in GPS1.6(-)
% 2012.10.08 - Updated to GPS1.7 format
% 2012.10.11 - Creates average subject
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition/subset
% 2013.06.20 - Reverted the status check to the individual system
% 2013.07.02 - Added some gps_filename defaults
% 2013.07.10 - Condition brain instead of study brain

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 0; % Subject specific?
    report.spec_cond = 1; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    condition = gpsa_parameter(state, state.condition);
    state.function = 'gpsa_mri_avesurf';
    tbegin = tic;
    
    %% Average the MRI surfaces
    
    tlocal = tic;
    
    % Determine which subjects are being used
    subjects = condition.subjects;
    
    % Form UNIX command for freesurfer to make the average subject surface
    unix_command = sprintf('make_average_subject --out %s --subjects', condition.cortex.brain);
    
    % Append the names of each subject to the unix command
    for i_subject = 1:length(subjects)
        unix_command = sprintf('%s %s', unix_command, subjects{i_subject});
    end
    
    % Add overwrite if overwriting previous averaged subject
    if(isfield(state, 'override') && state.override)
        unix_command = sprintf('%s --force', unix_command);
    end % If overwrite
    
    % Execute the command
    unix(unix_command);
    gpsa_log(state, toc(tlocal), unix_command);
    
    %% Make average subject file and compute brain for that
    state.subject = condition.cortex.brain;
    subject = gpse_convert_subject(state.subject);
    gpsa_parameter(subject);
    
    % Save brain to matrix
    gpsa_mri_brain2mat(state);
    
    %% Make morph maps for each subject to the new average
    
    for i_subject = 1:length(subjects)
        state.subject = subjects{i_subject};
        
        tlocal = tic;
        unix_command = sprintf('mne_make_morph_maps --from %s --to %s', state.subject, condition.cortex.brain);
        [~, ~] = unix(unix_command);
        gpsa_log(state, toc(tlocal), unix_command);
    end
    
    % Record the process
    gpsa_log(state, toc(tbegin));
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    study = gpsa_parameter(state, state.study);
    condition = gpsa_parameter(state, state.condition);
    report.progress = length(dir(gps_filename(study, condition, 'mri_ave_dir'))) > 2;
    
    if(report.progress == 1)
        report.ready = 1;
    else
        report.ready = 0;
        for i_subject = 1:length(condition.subjects)
            subject = gpsa_parameter(state, condition.subjects{i_subject});
            report.ready = report.ready + double(length(gps_filename(subject, 'mri_label_aparc_gen')) >= 2) / length(condition.subjects);
        end
    end
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function