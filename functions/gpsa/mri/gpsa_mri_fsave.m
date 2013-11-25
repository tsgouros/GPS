function varargout = gpsa_mri_fsave(varargin)
% Compares the recently constructed surfaces for a subject to the average
% freesurfer model
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.11.28 - GPS1.6/mri_fsave.m created
% 2012.09.19 - Updated to GPS1.7
% 2012.09.21 - Added order
% 2012.10.03 - Reformatted input, report, and error handling for do
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition/subset
% 2013.07.02 - Reverted status check to function specific

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 0; % Condition specific?
end

%% Execute the process

% If it is proper to do the function
if(~isempty(strfind(operation, 'c')))
    
    subject = gpsa_parameter(state.subject);
    state.function = 'gpsa_mri_fsave';
    tbegin = tic;
    
    %% Do the third freesurfer auto-recon
    
    unix_command = sprintf('recon-all -autorecon3 -s %s',...
        subject.name);
    unix(unix_command);
    
    % Record the process
    gpsa_log(state, toc(tbegin), unix_command);
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    % Prerequisite: gpsa_mri_surf
    subject = gpsa_parameter(state, state.subject);
    report.ready =    ~isempty(dir(gps_filename(subject, 'mri_surf_inflated_gen')));
    report.progress = ~isempty(dir(gps_filename(subject, 'mri_label_aparc_gen')));
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end
    
end % function