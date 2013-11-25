function varargout = gpsa_mri_bemmne(varargin)
% Sets up the Boundary Element Model for MNE
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012.01.23 - GPS1.6/mri_bemmne.m created
% 2012.09.19 - Updated to GPS1.7
% 2012.09.21 - Report.order added
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
    state.function = 'gpsa_mri_bemmne';
    tbegin = tic;
    
    %% Setup Forward Model
    
    % If we are overwriting the data set it up so the unix command will
    if(isfield(state, 'override') && state.override)
        overstring = ' --overwrite';
    else
        overstring = '';
    end
    
    % Process unix command (use --homog?)
    unix_command = sprintf('mne_setup_forward_model --subject %s --surf --ico 4%s',...
        subject.name, overstring);
    unix(unix_command);
    
    % Record the process
    gpsa_log(state, toc(tbegin), unix_command);
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    % Prerequisite: gpsa_mri_bem
    subject = gpsa_parameter(state, state.subject);
    report.ready    = ~isempty(dir(gps_filename(subject, 'mri_bem_surf_gen')));
    report.progress = ~isempty(dir(gps_filename(subject, 'mri_bem_fif_gen')));
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function