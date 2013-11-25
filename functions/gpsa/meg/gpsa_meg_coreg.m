function varargout = gpsa_meg_coreg(varargin)
% Associations a custom coregistration file with the scan
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.11.28 - Originally created as GPS1.6(-)/.m
% 2012.03.07 - Last modified in GPS1.6(-)
% 2012.10.05 - Updated to GPS1.7 format
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
% 2013.04.12 - Corrected problem in meaning the ready status
% 2013.04.24 - Changed subset/subsubset to condition hierarchy
% 2013.06.25 - Reverted status check to older version
% 2013.07.02 - Added gps_filename default coreg file

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 0; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    subject = gpsa_parameter(state.subject);
    state.function = 'gpsa_meg_coreg';
    tbegin = tic;
    
    % Ask for the name of the file
    if(isfield(subject.mri,'corfile') && ~isempty(subject.mri.corfile))
        default = subject.mri.corfile;
    else
        default = gps_filename(subject, 'mri_coreg_default');
    end
    
    [file, direc] = uigetfile(default, 'Select the coregistration file');
    
    if(direc ~= 0)
        subject.mri.corfile = [direc file];
    end
    
    % Record the process
    gpsa_parameter(state, subject);
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    % Prerequisite: gpsa_meg_import and gpsa_mri_bem
    subject = gpsa_parameter(state, state.subject);
    report.ready = mean([~isempty(dir(gps_filename(subject, 'meg_scan_gen'))) ...
        ~~exist([subject.mri.dir '/bem/outer_skin.surf'], 'file')]);
    report.progress = ~~exist(subject.mri.corfile, 'file') && ...
        ~strcmp(subject.mri.corfile, gps_filename(subject, 'mri_coreg_default'));
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function