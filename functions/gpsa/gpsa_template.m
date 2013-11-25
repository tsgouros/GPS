function varargout = gpsa_template(varargin)
% Template function for all other functions
%
% Author: A. Conrad Nied
%
% Changelog:
% - Originally created as GPS1.6(-)/.m
% - Last modified in GPS1.6(-)
% 2012.10.11 - Updated to GPS1.7 format

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 0; % Subject specific?
    report.spec_subs = 0; % Subset specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
%     subject = gpsa_parameter(state.subject);
%     subset = gpsa_parameter(state.subset);
    state.function = 'gpsa_template';
    tbegin = tic;
    
    % Functional instructions
    
    % Record the process
%     gpsa_parameter(state, subject);
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state.subject);
%     subset = gpsa_parameter(state.subset);
    if(~isempty(subject))
        % Predecessor: 
        report.ready = 0;
        report.progress = 0;
        report.finished = report.progress == 1;
    else
        report.ready = 0;
        report.progress = 0;
        report.finished = 0;
    end
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function