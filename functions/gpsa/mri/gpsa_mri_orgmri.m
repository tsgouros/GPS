function varargout = gpsa_mri_orgmri(varargin)
% Organize the MRI Data
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.11.29 - GPS1.6/mri_orgmri.m created
% 2012.09.21 - Updated to GPS1.7, first routine to be updated
% 2012.10.03 - Updated layout for new format
% 2013.04.05 - The ready condition is now a binary
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition/subset
% 2013.06.18 - Makes the study MRI dir if necessary
% 2013.07.02 - Reverted status check to function specific and deletes old
% MRI directory

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
    subject = gpsa_parameter(state, state.subject);
    study = gpsa_parameter(state, state.study);
    state.function = 'gpsa_mri_orgmri';
    tbegin = tic;
    
    % Make the study MRI dir if it doesn't exist
    if(~exist(study.mri.dir, 'dir'))
        mkdir(study.mri.dir)
    end
    
    % If overriding, delete any previous contents
    if(isfield(state, 'override') && state.override && length(dir(subject.mri.dir)) > 2)
        rmdir(subject.mri.dir, 's');
    end
    
    %% 1) Do the first freesurfer auto-recon
       %% Added explicit reference to fshome.  -tsg
    unix_command = sprintf('%s/bin/recon-all -autorecon1 -s %s -i %s',...
        state.fshome, subject.name, subject.mri.first_mpragefile);
    unix(unix_command);
    
    % Record the process
    gpsa_log(state, toc(tbegin), unix_command);
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state, state.subject);
    report.ready = ~~exist(subject.mri.first_mpragefile, 'file');
    report.progress = ~~exist(gps_filename(subject, 'mri_mgz'), 'file');
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function
