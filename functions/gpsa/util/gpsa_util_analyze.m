function varargout = gpsa_util_analyze(varargin)
% Opens the MNE analysis GUI
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.12.06 - Originally created as GPS1.6(-)/.m
% 2012.02.28 - Last modified in GPS1.6(-)
% 2012.10.05 - Updated to GPS1.7 format
% 2013.04.12 - GPS 1.8, Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition/subset and cleanup
% 2013.07.02 - Reverted status check to function specific
% 2013.07.08 - Doesn't mark as finished now so it can always be redone
% 2013.07.10 - Changed prerequisite to gpsa_mne_bem

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
    state.function = 'gpsa_util_analyze';
    tbegin = tic;
    
    % Open up the analyzer program you do this in.
    %% (added explicit ref to mnehome -tsg)
    unix_command = sprintf('%s/bin/mne_analyze --cd %s --subject %s &', ...
                           state.mnehome, subject.meg.dir, subject.name);
    unix(unix_command);
    
    % Record the process
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
    report.finished = (report.progress == 1) * 0.9;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function
