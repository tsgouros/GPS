function varargout = gpsa_util_tkmedit(varargin)
% Opens up the TKMedit utility from freesurfer to view a subject's MRI
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012.03.09 - GPS1.6/mri_tkmedit.m created
% 2012.09.19 - Updated to GPS1.7, first routine to be updated
% 2012.09.21 - Moved to util folder
% 2012.10.03 - Reformatted input, report, and error handling for do
% 2013.04.12 - GPS 1.8, Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition/subset
% 2013.07.02 - Reverted status check to function specific
% 2013.07.08 - Doesn't mark as finished now so it can always be redone

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
    state.function = 'gpsa_util_tkmedit';
    tbegin = tic;
    
    %% Open tkmedit (with explicit reference to fshome. -tsg)
    unix_command = sprintf('%s/bin/tkmedit %s T1.mgz &', ...
                           state.fshome, subject.name);
    unix(unix_command);
    
    % Record the process
    gpsa_log(state, toc(tbegin), unix_command);
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    % Prerequisite: gpsa_mri_orgmri
    subject = gpsa_parameter(state, state.subject);
    report.ready = ~~exist(gps_filename(subject, 'mri_mgz'), 'file');
    report.progress = ~isempty(dir(gps_filename(subject, 'mri_bem_fif_gen')));
    report.finished = (report.progress == 1) * 0.9;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function
