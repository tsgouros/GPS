function varargout = gpsa_mne_evoked(varargin)
% Extracts trial data from filtered raw MEG signals
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012.08.03 - Originally created as GPS1.6/wave_extract_blockfifs.m
% 2012.08.08 - Last modified in GPS1.6
% 2012.10.10 - Updated to GPS1.7 format
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
% 2013.04.25 - GPS1.8 Changed subset design to condition hierarchy
% 2013.04.30 - Moved GPS1.7/gpsa_granger_trials.m to MNE portion as
% GPS1.8/gpsa_mne_evoked.m
% 2013.05.03 - Asserts the check at the end of the process
%
% 2016.02.27 - [Seppo Ahlfors:] modified or commented out several lines..
% 2018.07.13 - [Seppo Ahlfors:] changed hard-wired time limits to study.mne.start and stop

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
    state.function = 'gpsa_mne_evoked';
    tbegin = tic;
    
    fprintf('\tGetting all evoked responses from filtered block files\n');
    
    %%%%%%%%%%%%%%%%% Modified by SA 2018-07-13  %%%%%%%%%%%%%%%%%%%%%
    %time_start = -0.3;
%%%%%%%% NOTE: these should probably not be hard-wired!!?? SA 2015-12-07 %%%%%%%
    %time_stop  = 1.2;
    time_start = study.mne.start / 1000; 
    time_stop  = study.mne.stop / 1000;
    
    for i_block = 1:length(subject.blocks)
        block = subject.blocks{i_block};
        fprintf('\t\tBlock %s', block);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%% commented out by SA 2016-02-27
        %block_trialdata = subject.meg.behav.trialdata(strcmp({subject.meg.behav.trialdata.block}, block));
        
        block_filename = gps_filename(subject, 'meg_scan_filtered_block', ['block=' block]); %#ok<NASGU>
        events_filename = gps_filename(subject, 'meg_events_grouped_block', ['block=' block]);
        events = load(events_filename);
        events_unique = unique(events(:,4));
        events_unique = setdiff(events_unique, [0 64 128 256 512]);
        
        % Clear response events and the null initial event
        for i_event = length(events):-1:1
            if(~sum(events(i_event, 4) == events_unique))
                events(i_event, :) = [];
            end
        end
        
        fprintf(' %3d eves ', length(events));
        
        [~, raw] = evalc('fiff_setup_read_raw(block_filename);');
        
        % Initialize the data block and get some information
        if(i_block == 1)
%             N_trials = (length(events) + 10) * length(subject.blocks);
            i_trial = 0;
            
            sfreq = raw.info.sfreq;
            channel_names = raw.info.ch_names;
            sample_times = (floor(time_start * sfreq) : ceil(time_stop  * sfreq)) / sfreq; %#ok<NASGU>
            
            %         data = zeros(N_channels, length(sample_times), N_trials);
        end
        
        i_channels = 1:length(channel_names); %#ok<NASGU>
        
        % Get epochs
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%% modified by SA 2016-02-27
        %for i_event = 1:length(events)
        for i_event = 1:length(events)-1
            fprintf('.');
            sample_start = floor(events(i_event, 1) + time_start * sfreq);
            sample_stop  =  ceil(events(i_event, 1) + time_stop  * sfreq);
            
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
            data(i_trial).sample_event = events(i_event, 1);
            data(i_trial).event = events(i_event, 4);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%% commented out by SA 2016-02-27
            %if(isfield(block_trialdata, 'sample'))
            %    data(i_trial).trialdata = block_trialdata([block_trialdata.sample] == data(i_trial).sample_event);
            %end
            %         end
        end
        
        fprintf('\n');
    end % for each block
    
    %% Break up the data by events
    fprintf('\tSaving by Events:');
    events_unique = unique([data.event]);
    
    folder = gps_filename(study, subject, 'meg_evoked_dir');
    if(~exist(folder, 'dir')); mkdir(folder); end
    
    for i_event = 1:length(events_unique)
        event = events_unique(i_event);
        fprintf(' %d', event);
        
        event_data = data([data.event] == event); %#ok<NASGU>
        output_file = gps_filename(study, subject, 'meg_evoked_event', ['event=' num2str(event)]);
        save(output_file, 'event_data', 'event', 'time_start', 'time_stop', 'sample_times', 'sfreq', 'channel_names', '-v7.3');
        
    end % for each event
    
    fprintf(' Done.\n');
    
    %% Save End
    
    fprintf('\tDone in %.1f seconds\n', toc(tbegin));
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    study = gpsa_parameter(state, state.study);
    subject = gpsa_parameter(state, state.subject);
    report.ready = max(length(dir(gps_filename(subject, 'meg_scan_filtered_gen'))) / length(subject.blocks), 1);
    report.progress = length(dir(gps_filename(study, subject, 'meg_evoked_gen'))) >= 1;
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var'));
    varargout{1} = report;
end

end % function
