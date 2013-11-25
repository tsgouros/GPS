function varargout = gpsa_meg_eveext(varargin)
% Extracts event triggers
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.11.30 - Originally created as GPS1.6(-)/.m
% 2012.02.21 - Last modified in GPS1.6(-)
% 2012.10.03 - Updated to GPS1.7 format and added condition in case the STI
%                  channel is the new one
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition hierarchy
% 2013.04.30 - Gets filenames from gps_filename.m
% 2013.06.25 - Reverted status check to older version

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
    state.function = 'gpsa_meg_eveext';
    tbegin = tic;
    
    % Functional instructions
    fprintf('%s: Extracting events for %s\n\t', state.function, subject.name);
    
    trigger_channel = 'STI_014';
    
    % For Each Block
    for i_block = 1:length(subject.blocks)
        block = subject.blocks{i_block};
        fprintf('%s', block);
        
        % Run the MNE command to extract the events
        unix_command = sprintf('mne_process_raw --raw %s --allevents --eventsout %s --projon --digtrig %s',...
            gps_filename(subject, 'meg_scan_block', ['block=' block]),...
            gps_filename(subject, 'meg_events_block', ['block=' block]),...
            trigger_channel);
        [~, output] = unix(unix_command);
        fprintf(output)
        
        % Try a different trigger channel if the first one didn't work
        if(strfind(output, 'No events to save'))
            trigger_channel = 'STI101';
            
            unix_command = sprintf('mne_process_raw --raw %s --allevents --eventsout %s --projon --digtrig %s',...
                gps_filename(subject, 'meg_scan_block', ['block=' block]),...
                gps_filename(subject, 'meg_events_block', ['block=' block]),...
                trigger_channel);
            [~, output] = unix(unix_command);
            fprintf(output)
        end
        
        % If we still didn't find events, throw an error
        if(strfind(output, 'No events to save'))
            error('%s %s: No events to save', subject.name, block);
        end
        
        fprintf('.');
    end % For Each Block

    fprintf('\n');

    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state, state.subject);
    report.ready = ~isempty(dir(gps_filename(subject, 'meg_scan_gen')));
    report.progress = min(length(dir(gps_filename(subject, 'meg_events_gen'))) / length(subject.blocks), 1);
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function