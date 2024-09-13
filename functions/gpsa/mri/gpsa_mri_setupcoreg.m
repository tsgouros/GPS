function varargout = gpsa_mri_setupcoreg(varargin)
% Uses the MNE command to setup the MRI for MEEG Coregistration
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.11.28 - GPS1.6/mri_setupcoreg.m created
% 2012.09.21 - Updated to GPS1.7
% 2012.10.03 - Updated layout for new format
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition/subset
% 2013.07.02 - Reverted status check to function specific
% 2019.01-03 - Added explicit pathname references to environment vars.  -tsg

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
    state.function = 'gpsa_mri_setupcoreg';
    tbegin = tic;
    
    %% Setup MRI for Source Space
    
    % If we are overwriting the data set it up so the unix command will
    if(isfield(state, 'override') && state.override)
        overstring = ' --overwrite';
    else
        overstring = '';
    end
    
    % Run the unix command (with explicit reference to mnehome.  -tsg)
    unix_command = sprintf('%s $MNE_ROOT/bin/mne_setup_mri%s --subject %s',...
                           state.setenv, overstring, subject.name);
    unix(unix_command);
    
    % Record the process
    gpsa_log(state, toc(tbegin), unix_command);
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    % Prerequisite: gpsa_mri_srcspace
    subject = gpsa_parameter(state, state.subject);
    report.ready    = ~isempty(dir(gps_filename(subject, 'mri_srcspace_gen')));
    report.progress = ~~exist(gps_filename(subject, 'mri_coreg_default'), 'file');
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function
