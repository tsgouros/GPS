function varargout = gpsa_meg_eog(varargin)
% Records the EOG projection information
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.11.30 - Originally created as GPS1.6(-)/meg_eog.m
% 2012.02.28 - Last modified in GPS1.6(-)
% 2012.10.03 - Updated to GPS1.7 format
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition hierarchy
% 2013.04.30 - Updated folder names for new organization scheme
% 2013.06.25 - Reverted status check to older version
% 2013.07.10 - Prompts browsing for the file now as opposed to writing it

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
    state.function = 'gpsa_meg_eog';
    tbegin = tic;
    
    % Prompt the user to find EOG projection file
    [filename, path] = uigetfile(gps_filename(subject, 'meg_fif_gen'), 'Indicate the file with the EOG projections saved', subject.meg.projfile);
    
    % Exit if no answer given
    if(isempty(filename) || isnumeric(filename))
        fprintf('EOG projection file identification cancelled\n')
        return;
    end
    
    % Format projection file
    projfile = [path filename];
    subject.meg.projfile = projfile;
    
    % Record the process
    gpsa_parameter(state, subject);
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state, state.subject);
    report.ready = ~isempty(dir(gps_filename(subject, 'meg_channels_bad')));
    report.progress = ~isempty(subject.meg.projfile) && ...
        subject.meg.projfile(end) ~= '/' && ...
        ~~exist(subject.meg.projfile, 'file');
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function