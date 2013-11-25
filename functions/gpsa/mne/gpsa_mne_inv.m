function varargout = gpsa_mne_inv(varargin)
% Compute the inverse operator for MNE based on the forward solution and
% noise covariance.
% 
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012.01.23 - Originally created as GPS1.6(-)/mne_inv.m
% 2012.07.03 - Last modified in GPS1.6(-)
% 2012.10.08 - Updated to GPS1.7 format
% 2013.04.12 - GPS1.8, Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition hierarchy
% 2013.04.30 - Updated folder names for new organization scheme
% 2013.06.25 - Reverted status check to older version

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 0; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    study = gpsa_parameter(state.study);
    subject = gpsa_parameter(state.subject);
    state.function = 'gpsa_mne_inv';
    tbegin = tic;
    
    study.mne.flag_eeg = 1;
    study.mne.flag_meg = 1;
    
    for i_eeg = 0:1 % Do this twice, with and without EEG
        study.mne.flag_eeg = i_eeg;
        
        % Process flags
        options = '';
        invfile = sprintf('%s/%s', subject.mne.dir, subject.name);
        if(study.mne.flag_depth)
            options = sprintf('%s --depth', options);
            invfile = sprintf('%s_depth', invfile);
        end
        if(study.mne.flag_meg)
            options = sprintf('%s --meg', options);
            invfile = sprintf('%s_meg', invfile);
        end
        if(study.mne.flag_eeg)
            options = sprintf('%s --eeg', options);
            invfile = sprintf('%s_eeg', invfile);
        end
        if(subject.mri.ico == 5)
            invfile = sprintf('%s_spacing5', invfile);
        end
        invfile = sprintf('%s-inv.fif', invfile);
        
        % Process unix command
        unix_command = sprintf('mne_do_inverse_operator --inv %s --fwd %s --senscov %s --subject %s --noiserankold --loose 0.2%s',...
            invfile, subject.mne.fwdfile, subject.mne.covfile, subject.name, options);
        unix(unix_command);
    end
    
    % Record the process
    subject.mne.invfile = invfile;
    gpsa_parameter(state, subject);
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state, state.subject);
    report.ready = ~~exist(subject.mne.fwdfile, 'file');
    report.progress = ~~exist(subject.mne.invfile, 'file');
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function