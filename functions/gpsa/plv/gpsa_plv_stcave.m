function varargout = gpsa_plv_stcave(varargin)
% Make an average brain STC movie file based on the primary condition and
% inverse solution for the phase locking values
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.11.01 - Created based on GPS1.7/gpsa_mne_stcave.m
% 2013.04.24 - GPS1.8 Changed subset/subsubset to condition/subset

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 1; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    subject = gpsa_parameter(state.subject);
    study = gpsa_parameter(state.study);
    condition = gpsa_parameter(state.condition);
    state.function = 'gpsa_plv_stcave';
    tbegin = tic;
    
    smooth_level = 5;
    
    % Specify Filenames
    folder = sprintf('%s/subject_results/%s',...
        study.plv.dir, condition.name);
    stcfilename_orig = sprintf('%s/%s_plv_LSTG1_40Hz',...
        folder, subject.name);
    stcfilename = sprintf('%s/%s_plv_LSTG1_40Hz_avebrain',...
        folder, subject.name);
    
    inv_filename = subject.mne.invfile;
    i_eeg = strfind(inv_filename, '_eeg');
    if(~isempty(i_eeg)); inv_filename(i_eeg:(i_eeg + 3)) = []; end
    
    unix_command = sprintf('mne_make_movie --inv %s --stcin %s --smooth %d --morph %s  --surface inflated --stc %s --subject %s',...
        inv_filename, stcfilename_orig, smooth_level, study.average_name, stcfilename, subject.name);
    
    gpsa_log(state, unix_command);
    unix(unix_command);
    
    % Now save a .mat version of this so we can compare subjects
    
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    study = gpsa_parameter(state.study);
    subject = gpsa_parameter(state.subject);
    condition = gpsa_parameter(state.condition);
    if(~isempty(subject) && ~isempty(condition))
        % Predecessor: gpsa_plv_compute
        stcfilename = sprintf('%s/subject_results/%s/%s_plv_LSTG1_40Hz*',...
            study.plv.dir, condition.name, subject.name);
        report.ready = ~isempty(dir(stcfilename));
        stcfilename = sprintf('%s/subject_results/%s/%s_plv_LSTG1_40Hz_avebrain*',...
            study.plv.dir, condition.name, subject.name);
        report.progress = ~isempty(dir(stcfilename));
        report.finished = report.progress == 1;
    else
        report.ready = 0;
        report.progress = 0;
        report.finished = 0;
    end
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function