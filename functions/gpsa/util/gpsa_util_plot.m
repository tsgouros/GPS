function varargout = gpsa_util_plot(varargin)
% Opens the GPS: Plotting GUI
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012-10-11 Created based on GPS1.7/gpsa_util_rois.m
% 2013-04-12 GPS 1.8, Updated the status check to the new system
% 2013-04-24 Changed subset/subsubset to condition/subset
% 2013-07-02 Reverted status check to function specific
% 2013-07-08 Doesn't mark as finished now so it can always be redone
% 2013-07-15 Loads the new GUI now

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 0; % Subject specific?
    report.spec_cond = 1; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    state.function = 'gpsa_util_plot';
    tbegin = tic;
    
    % Open up the analyzer program you do this in
    GPSp(state);
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    % Prerequisite: gpsa_granger_compute
    study = gpsa_parameter(state, state.study);
    condition = gpsa_parameter(state, state.condition);
    report.ready = ~isempty(dir(gps_filename(study, condition, 'granger_analysis_rawoutput_gen')));
    report.progress = report.ready;
    report.finished = (report.progress == 1) * 0.9;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function