function varargout = gpsa_plv_trials_emptyroom(varargin)
% Extracts trial data from unfiltered raw emptyroom MEG signals
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.02.21 - Created based on GPS1.7/gpsa_plv_trials.m
% 2013.04.24 - GPS1.8, Changed subset/subsubset to condition/subset

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
    state.function = 'gpsa_plv_trials_emptyroom';
    tbegin = tic;
    
    fprintf('\tExtracting timeseries from raw emptyroom file\n');
    
    time_start = -0.3;
    time_stop  = 1.2;

    block = 'emptyroom';
%     block = 'IBI'; % use 4097 for the event #

    block_filename = sprintf('%s/raw_data/%s_%s_raw.fif',...
        subject.meg.dir, subject.name, block); %#ok<NASGU>

    [~, raw] = evalc('fiff_setup_read_raw(block_filename);');
    
    % Initialize the data block and get some information
    i_trial = 0;
    
    sfreq = raw.info.sfreq;
    channel_names = raw.info.ch_names;
    sample_times = (floor(time_start * sfreq) : ceil(time_stop  * sfreq)) / sfreq; %#ok<NASGU>
    
    % Get a sample every 2 seconds from the emptyroom file
    events = raw.first_samp : floor(2 * sfreq) : raw.last_samp;
    fprintf('\t\tGetting timeseries (%d) ', length(events) - 11);
    
    i_channels = 1:length(channel_names); %#ok<NASGU>

    % Get epochs (don't use the first few or the last one
    for i_event = 10:(length(events) - 1)
        fprintf('.');
        sample_start = floor(events(i_event) + time_start * sfreq);
        sample_stop  =  ceil(events(i_event) + time_stop  * sfreq);
        
        % Get the data from the raw stream
        [~, epoch] = evalc('fiff_read_raw_segment(raw, sample_start, sample_stop, i_channels)');
        
        % Save to data
        %         if(size(epoch, 2) < size(data, 2))
        %             fprintf('e'); % Stands for the round was too short (epsilon)
        %         else
        i_trial = i_trial + 1;
        %             data(:, :, i_trial) = epoch;
        %             all_events(end + 1, :) = [events(i_event, 1) events(i_event, 4)];
        data(i_trial).epoch = single(epoch);
        data(i_trial).sample_start = sample_start; %#ok<*AGROW>
        data(i_trial).sample_stop = sample_stop;
        data(i_trial).sample_event = events(i_event);
        data(i_trial).event = 4096;
        data(i_trial).trialdata = [];
        %         end
    end
    
    fprintf('\n');
    
    %% Break up the data by events
    fprintf('\tSaving file');
    
    folder = sprintf('%s/trials/%s', study.plv.dir, subject.name);
    if(~exist(folder, 'dir')); mkdir(folder); end
    
    event = 4096;
    event_data = data([data.event] == event); %#ok<NASGU>
    output_file = sprintf('%s/%s_eve%04d_evoked.mat',...
        folder, subject.name, event);
    save(output_file, 'event_data', 'event', 'time_start', 'time_stop', 'sample_times', 'sfreq', 'channel_names', '-v7.3');
    
    fprintf(' Done.\n');
    
    %% Save End
    
    fprintf('\tDone in %.1f seconds\n', toc(tbegin));
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    study = gpsa_parameter(state.study);
    subject = gpsa_parameter(state.subject);
    if(~isempty(subject))
        % Predecessor: meg_eveproc
        report.ready = length(dir([subject.meg.dir '/triggers/*.eve'])) >= length(subject.blocks);
        filespec = sprintf('%s/trials/%s/%s_eve4096_evoked.mat',...
            study.plv.dir, subject.name, subject.name);
        report.progress = length(dir(filespec)) >= 1;
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