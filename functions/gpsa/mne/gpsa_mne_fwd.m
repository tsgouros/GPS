function varargout = gpsa_mne_fwd(varargin)
% Compute the forward solution for MNE based on the ave files and
% coordinate geometry
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012.01.23 - Originally created as GPS1.6(-)/mne_fwd.m
% 2012.03.09 - Last modified in GPS1.6(-)
% 2012.10.08 - Updated to GPS1.7 format
% 2013.01.15 - Added plv spacing routines
% 2013.04.12 - GPS1.8, Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition hierarchy
% 2013.04.30 - Updated folder names for new organization scheme
% 2013.05.15 - Added routine to get subset for MEG or EEG only fwd solution
% 2013.06.25 - Reverted status check to older version
% 2013.07.02 - Updated bem check to gps_filename

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
    state.function = 'gpsa_mne_fwd';
    tbegin = tic;
    
    spacing = subject.mri.ico;
    
    % If we are overwriting the data set it up so the unix command will
    if(isfield(state, 'override') && state.override)
        overstring = ' --overwrite';
    else
        overstring = '';
    end
    
    if(spacing == 5)
        subject.mne.fwdfile = sprintf('%s/%s_spacing5-fwd.fif', subject.mne.dir, subject.name);
    else
        subject.mne.fwdfile = gps_filename(subject, 'mne_fwd');
    end
    
    if(isfield(state, 'subset') && strcmpi(state.subset, 'meg'))
        exclstring = ' --megonly';
        subject.mne.fwdfile = gps_filename(subject, 'mne_fwd_meg');
%     elseif(isfield(state, 'subset') && strcmpi(state.subset, 'eeg'))
%         exclstring = ' --eegonly'
%         subject.mne.fwdfile = gps_filename(subject, 'mne_fwd_eeg');
    else
        exclstring = '';
    end % If the subset is MEG or EEG only
    
    % Process unix command.  (Added explicit mnehome. -tsg)
    unix_command = sprintf('%s/bin/mne_do_forward_solution --fwd %s --spacing %d --meas %s --subject %s --mri %s%s%s',...
        state.mnehome, subject.mne.fwdfile, spacing, subject.mne.avefile, subject.name, subject.mri.corfile, overstring, exclstring);
    unix(unix_command);
    
    % Record the process
    if(~(isfield(state, 'subset') && strcmpi(state.subset, 'meg')))
        gpsa_parameter(state, subject);
    end
    gpsa_log(state, toc(tbegin), unix_command);
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state, state.subject);
    report.ready = mean([~isempty(dir(gps_filename(subject, 'mri_bem_fif_gen'))) ... % BEM fif file
        ~isempty(subject.meg.projfile) && ... EOG
        subject.meg.projfile(end) ~= '/' && ... EOG
        ~~exist(subject.meg.projfile, 'file') ... EOG
        ~~exist(subject.mne.avefile, 'file')]); % Ave file
    report.progress = ~~exist(subject.mne.fwdfile, 'file');
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function
