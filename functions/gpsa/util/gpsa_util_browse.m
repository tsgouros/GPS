function varargout = gpsa_util_browse(varargin)
% Opens mne_browse_raw
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.11.28 - Originally created as GPS1.6(-)/.m
% 2012.02.17 - Last modified in GPS1.6(-)
% 2012.10.03 - Updated to GPS1.7 format
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

if(~isempty(strfind(operation, 'c')))
    
    subject = gpsa_parameter(state.subject);
    state.function = 'gpsa_util_browse';
    tbegin = tic;

    %% Added explicit reference to mnehome.  -tsg
    unix_command = sprintf('%s/bin/mne_browse_raw --cd %s &',...
                           state.mnehome, gps_filename(subject, 'meg_scan_dir'));
    unix(unix_command);
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    % Prerequisite: gpsa_meg_import
    subject = gpsa_parameter(state, state.subject);
    report.ready = ~isempty(dir(gps_filename(subject, 'meg_scan_gen')));
    report.progress = mean([~isempty(dir(gps_filename(subject, 'meg_channels_bad'))) ...
        ~isempty(subject.meg.projfile) && ...
        subject.meg.projfile(end) ~= '/' && ...
        ~~exist(subject.meg.projfile, 'file')]);
    report.finished = (report.progress == 1) * 0.9;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function
