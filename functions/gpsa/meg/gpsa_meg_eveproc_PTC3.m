function varargout = gpsa_meg_eveproc_PTC3(varargin)
% Generic program to process event files, ie making new event codes based
% on both stimuli and response accuracy.
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.06.21 - Created in GPS1.8, based on gpsa_meg_eveproc.m

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
    state.function = 'gpsa_meg_eveproc';
    tbegin = tic;
    
    if(~isfield(state, 'processlog'))
        state.processlog = 1;
    end
    
    fprintf(state.processlog, '%s: Processing events for %s\n', state.function, state.subject);
    
    % Allocate the trialdata
    trialdata = struct('audio', '', 'text', '', 'text_cpa', '', 'correct', 0,...
        'sample', 0, 'time', 0, 'trigger', 0, 'group', 0, 'i_trial', 0,...
        'block', '', 'neighdens', '', 'phonofreq', '', 'realword', '',...
        'response_time', 0);
    
    % Read in the subject's performance and the block commands
    for i_block = 1:length(subject.blocks)
        block = subject.blocks{i_block};
        
        % Load in the block data
        filename = sprintf('%s/%s/%s_%s.txt', gps_presets('parameters'), study.name, study.name, block);
        fid = fopen(filename);
        blockdata = textscan(fid, '%[^\t]\t%[^\t]\t%[^\t]\t%d');
        fclose(fid);
        
        % Format of block data is a cell array of 3 entries, one for each
        % column.
        % blockdata{1} -> Audio presented
        % blockdata{2} -> Audio text in English Orthography
        % blockdata{3} -> Audio text in CPA
        % blockdata{4} -> Trigger sent to MEG machine
        
        % Load the event data and allocate the new event data
        evedata = load(gps_filename('meg_events_block', subject, ['block=' block]));
        evedata_grouped = zeros(size(evedata, 1) * 2, size(evedata, 2));
        
        % Compute the sample frequency and number of events
        fs = mean(diff(evedata(diff(evedata(:, 2)) > 1, 1)) ./ diff(evedata(diff(evedata(:, 2)) > 1, 2)));
        N_events = length(evedata);
        
        % Set some pointers to be used while scanning the events
        i_event = 1;
        i_event_grouped = 0;
        i_trial = 0;
        
        % Allocate empty audio onset and response blocks
        audonset = [];
        response = [];
        
        % For each event (this will iterate down the list)
        while i_event <= N_events
            event = evedata(i_event, :);
            
            % Observe the initial status, seen as a trigger of 0
            if event(4) == 0 && i_event == 1
                i_event_grouped = i_event_grouped + 1;
                evedata_grouped(i_event_grouped, :) = event;
                fprintf(state.processlog, '%s % 5d Saw initialization trigger 0 at beginning.\n', block, i_event);
                
                % Ignore all trigger releases
            elseif event(3) > event (4)
                fprintf(state.processlog, '%s % 5d Trigger release %d to %d, ignoring.\n', block, i_event, event(3), event (4));
                
                % Found a button press
            elseif mod(event(4), 64) == 0
                response = [event(1:3) log(event(4)) / log(2) - 7];
                if(response(4) <= 0); response(4) = response(4) + 2; end
                fprintf(state.processlog, '%s % 5d Found a button press %d\n', block, i_event, response(4));
                
                % Found a trigger that wasn't a button press -> probably an
                % auditory stimuli onset
            elseif mod(event(4), 64) > 0
                % If we have an old trigger waiting for a matched response,
                % the trial was probably skipped so just mark that
                if ~isempty(audonset) && (event(2) - audonset(2) > 0.01)
                    i_trial = i_trial + 1;
                    fprintf(state.processlog, '\tDidn''t find a response for trial %d, trigger %d\n', i_trial, audonset(4));
                end
                
                % Mark the event as a trigger for an audio onset
                audonset = [event(1:3) mod(event(4), 64)];
                response = [];
                fprintf(state.processlog, '%s % 5d Found an auditory event trigger %d\n', block, i_event, audonset(4));
            end
            
            % Tell the program loop it can move on to the next event
            %   (after it checks matched triggers)
            i_event = i_event + 1;
            
            % See if triggers are matched - a stimulus trigger was followed
            % by a response
            if ~isempty(audonset) && ~isempty(response)
                i_trial = i_trial + 1;
                
                % Verify that the trial code matches the expected one
                if blockdata{4}(i_trial) == audonset(4)
                    
                    %% Set up new auditory onset event
                    time = audonset(2);
                    sample = floor(time * fs);
                    trigger = audonset(4);
                    correct = trigger  < 12 && response(4) == 1 ||...
                              trigger >= 12 && response(4) == 2;
                    
                    switch trigger
                        case 8
                            if correct; group = 201; else group = 301; end
                            neighdens = 'H'; phonofreq = 'H'; realword = 'Y';
                        case 9
                            if correct; group = 202; else group = 302; end
                            neighdens = 'H'; phonofreq = 'L'; realword = 'Y';
                        case 10
                            if correct; group = 203; else group = 303; end
                            neighdens = 'L'; phonofreq = 'H'; realword = 'Y';
                        case 11
                            if correct; group = 204; else group = 304; end
                            neighdens = 'L'; phonofreq = 'L'; realword = 'Y';
                        case 12
                            if correct; group = 205; else group = 305; end
                            neighdens = 'H'; phonofreq = 'H'; realword = 'N';
                        case 13
                            if correct; group = 206; else group = 306; end
                            neighdens = 'H'; phonofreq = 'L'; realword = 'N';
                        case 14
                            if correct; group = 207; else group = 307; end
                            neighdens = 'L'; phonofreq = 'H'; realword = 'N';
                        case 15
                            if correct; group = 208; else group = 308; end
                            neighdens = 'L'; phonofreq = 'L'; realword = 'N';
                    end
                    
                    % Save event in new event data
                    i_event_grouped = i_event_grouped + 1;
                    evedata_grouped(i_event_grouped, :) = [sample time 0 group];
                    
                    %% Save data
                    % Trial word and phone
                    data.audio    = blockdata{1}{i_trial};
                    data.text     = blockdata{2}{i_trial};
                    data.text_cpa = blockdata{3}{i_trial};
                    data.correct  = correct;
                    data.sample   = sample;
                    data.time     = time;
                    data.trigger  = trigger;
                    data.group    = group;
                    data.i_trial  = i_trial;
                    data.block    = block;
                    data.neighdens= neighdens;
                    data.phonofreq= phonofreq;
                    data.realword = realword;
                    data.response_time = response(2) - audonset(2);
                    
                    % Save to the trial data structure
                    trialdata(i_trial) = data;
                    fprintf(state.processlog, '\t Saved trial %d\n', i_trial);
                    
                    % Clear the response and audio onset
                    audonset = [];
                    response = [];
                else
                    fprintf(state.processlog, '\t Found the wrong trigger %d, expected %d\n', audonset(4),  blockdata{4}(i_trial));
                    
                    % Clear the response and audio onset
                    audonset = [];
                    response = [];
                end
                
            end % if we have a new trigger & response
        end % For each event
        
        evedata_grouped(i_event_grouped + 1 : end, :) = [];
        
        %% Write grouped event files
        filename = gps_filename('meg_events_grouped_block', subject, ['block=' block]);
        fid = fopen(filename, 'w');
        
        for i_event = 1:size(evedata_grouped, 1)
            fprintf(fid, '%6d%- 8.3f %6d %3d\n',...
                evedata_grouped(i_event, 1), evedata_grouped(i_event, 2), evedata_grouped(i_event, 3), evedata_grouped(i_event, 4));
        end % For Each event
        
        fclose(fid);
    end % For each block
    
    %% Save Trialdata
    
    N_trials = 360;
    N_missed = N_trials - length(trialdata);
    
    fprintf(state.processlog, '\tProduce figures\n');
    
    %% Figures
    
    RW = [trialdata.realword]  == 'Y';
    NW = [trialdata.realword]  == 'N';
    HD = [trialdata.neighdens] == 'H';
    LD = [trialdata.neighdens] == 'L';
    HF = [trialdata.phonofreq] == 'H';
    LF = [trialdata.phonofreq] == 'L';
    C  = [trialdata.correct]   == 1;
    
    % Other prep: format subject name
    fsubjName = subject.name;
    loc = find(fsubjName=='_');
    if(~isempty(loc)) % If we found an underscore in the subject's name
        fsubjName = [fsubjName(1:loc-1) '\' fsubjName(loc:end)];
    end
    
    % Show 8 subgroups accuracy
    figure(6754010);
    clf(6754010)
    bar(([sum(RW & HD & HF & C) / sum(RW & HD & HF),...
          sum(RW & HD & LF & C) / sum(RW & HD & LF),...
          sum(RW & LD & HF & C) / sum(RW & LD & HF),...
          sum(RW & LD & LF & C) / sum(RW & LD & LF),...
          sum(NW & HD & HF & C) / sum(NW & HD & HF),...
          sum(NW & HD & LF & C) / sum(NW & HD & LF),...
          sum(NW & LD & HF & C) / sum(NW & LD & HF),...
          sum(NW & LD & LF & C) / sum(NW & LD & LF);...
          0, 0, 0, 0, 0, 0, 0, 0])) % To provide for colors
    title(['PTC3 Accuracy by Type of Stimulus, for ' fsubjName])
    ylabel('Fraction of Correct Observations')
    set(gca,'XTick',[0.65 0.75 0.85 0.95 1.05 1.15 1.25 1.35])
    set(gca,'XTickLabel',{'HD-HF', 'HD-LF', 'LD-HF', 'LD-LF', 'HD-HF', 'HD-LF', 'LD-HF', 'LD-LF'})
    text(0.8, -0.08, 'Word', 'HorizontalAlignment', 'Center')
    text(1.2, -0.08, 'Nonword', 'HorizontalAlignment', 'Center')
    axis([0.55 1.45 0 1])
    
    image_file = sprintf('%s/images/%s_accuracy.png',...
        subject.meg.dir, subject.name);
    saveas(6754010, image_file);
    
    %% Response Time Figures
    % Emulating Luce et al's charts
    
    RTs = [trialdata.response_time] * 1000;
    
    % p572
    figure(6754011)
    clf(6754011)
    subplot(2, 2, 1)
    bar([mean(RTs(RW & HD & HF)) - 500,...
        mean(RTs(RW & LD & HF)) - 500;...
        mean(RTs(RW & HD & LF)) - 500,...
        mean(RTs(RW & LD & LF)) - 500])
    title('Words (Blue = HD, Red = LD)')
    ylabel('Reaction Time (ms)')
%     xlabel('Phonotactic Frequency')
    set(gca,'XTick',[1 2])
    set(gca,'XTickLabel',{'High', 'Low'})
%     ylim([500 900])
    
    subplot(2, 2, 3)
    bar([mean(RTs(NW & HD & HF)) - 500,...
        mean(RTs(NW & LD & HF)) - 500;...
        mean(RTs(NW & HD & LF)) - 500,...
        mean(RTs(NW & LD & LF)) - 500])
    title('Nonwords (Blue = HD, Red = LD)')
    ylabel('Reaction Time (ms)')
    xlabel('Phonotactic Frequency')
    set(gca,'XTick',[1 2])
    set(gca,'XTickLabel',{'High', 'Low'})
%     ylim([500 900])
    
    % p577
    subplot(2, 2, 2)
    bar([mean(RTs(NW & HD & HF)) - mean(RTs(RW & HD & HF)),...
        mean(RTs(NW & LD & HF)) - mean(RTs(RW & LD & HF));...
        mean(RTs(NW & HD & LF)) - mean(RTs(RW & HD & LF)),...
        mean(RTs(NW & LD & LF)) - mean(RTs(RW & LD & LF))])
    title('Nonword - Word RT (Blue = HD, Red = LD)')
    ylabel('Difference in RT (ms)')
    xlabel('Phonotactic Frequency')
    set(gca,'XTick',[1 2])
    set(gca,'XTickLabel',{'High', 'Low'})
    
    image_file = sprintf('%s/images/%s_RT.png',...
        subject.meg.dir, subject.name);
    saveas(6754011, image_file);
    
    % If this is the average, find aberrant words
%     if(strcmp(state.subject, study.average_name))
%         trial_words = {trialdata.text};
%         words = unique(trial_words);
%         
%         for i_trial = 1:length(trial_data)
%         end
%     end % If average subject
    
    %% Clean up
    
    % Set other variables
    subject.meg.behav.N_trials = N_trials;
    subject.meg.behav.N_missed = N_missed;
    subject.meg.behav.trialdata = trialdata;
    
    % Record the process
    gpsa_parameter(state, subject);
    gpsa_log(state, toc(tbegin));
     
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state.subject);
    
    report.ready = max(length(dir(gps_filename(subject, 'meg_events_gen'))) / length(subject.blocks), 1);
    report.progress = max(length(dir(gps_filename(subject, 'meg_events_grouped_gen'))) / length(subject.blocks), 1);
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var'));
    varargout{1} = report;
end

end % function