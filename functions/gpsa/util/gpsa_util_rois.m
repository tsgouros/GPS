function varargout = gpsa_util_rois(varargin)
% Opens the GPS: ROIs GUI
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012.10.09 - Created based on GPS1.6(-)/gpsa_util_analyze.m
% 2013.04.12 - GPS 1.8, Updated the status check to the new system
% 2013.04.16 - Only reports as subject specific if the study is as such
% 2013.04.24 - Changed subset/subsubset to condition/subset
% 2013.05.01 - Changed progress report (will have to change again though)
% 2013.07.02 - Reverted status check to function specific
% 2013.07.08 - Doesn't mark as finished now so it can always be redone
% 2013.07.10 - Removed subject specificness, if you want a single subject
% study, just have one subject

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 0; % Subject specific?
    report.spec_cond = 1; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    state.function = 'gpsa_util_rois';
    tbegin = tic;
    
    % Open up the analyzer program you do this in
    GPS_rois(state);
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    % Prerequisite: gpsa_mne_stc
    study = gpsa_parameter(state, state.study);
    subject = gpsa_parameter(state, state.subject);
    condition = gpsa_parameter(state, state.condition);
    report.ready = ~~exist(gps_filename(subject, condition, 'mne_stc_lh'), 'file');
    report.progress = ~isempty(dir(gps_filename(study, condition, 'granger_rois_set_labels_gen')));
    report.finished = (report.progress == 1) * 0.9;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function