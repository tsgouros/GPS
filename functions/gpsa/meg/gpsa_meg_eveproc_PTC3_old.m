function varargout = gpsa_meg_eveproc_PTC3(varargin)
% Processes events for behavioral figures and stimulus groups for PTC2
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.05 - Created from GPS1.7/gpsa_meg_eveproc_PTC2
% 2012.10.10 - Fixed a bug in the group name
% 2013.03.27 - Adds the subject names to the average behaviorals
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
% 2013.04.12 - Broke up progress condition
% 2013.04.24 - Changed subset/subsubset to condition hierarchy
% 2013.04.29 - Changed folders

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
    state.function = 'gpsa_meg_eveproc_PTC3';
    tbegin = tic;
    
    if(~isfield(state, 'processlog'))
        state.processlog = 1;
    end
    
    fprintf(state.processlog, '%s: Processing events for %s\n', state.function, state.subject);
    
    trialdata = struct('trigger', NaN, 'block', '', 'sample', NaN,...
        'realword', NaN, 'response_time', NaN, 'response', '', 'correct', NaN,...
         'neighdens', '', 'phonoprob', '', 'text', '', 'phon', '',...
        'groupnum', NaN, 'groupname', '', 'i_trial', NaN, 'ID', NaN, 'subject', '');
    N_trials = 0;
    i_trial = 0;
    
    % Are we doing the average or individual subject?
    if(strcmp(state.subject, study.average_name))
        folder = sprintf('%s/%s/images', study.meg.dir, study.average_name);
        if(~exist(folder, 'dir')); mkdir(folder); end
        
        % Load and concatenate subjects
        for i_subject = 1:length(study.subjects)
            asubject = gpsa_parameter(state, study.subjects{i_subject});
            
            subject_trialdata = asubject.meg.behav.trialdata;
            for j_trial = 1:length(subject_trialdata)
                subject_trialdata(j_trial).subject = study.subjects{i_subject};
            end
            
            trialdata = [trialdata subject_trialdata]; %#ok<AGROW>
            N_trials = N_trials + asubject.meg.behav.N_trials;
        end % For each subject
        
        % Also if the subject is empty, make a default average subject
        if(isempty(subject))
            subject = gpse_convert_subject(state, study.average_name);
        end
        
        % Remove allocated trial data block
        trialdata(1) = [];
        
    else % Regular subject
        fprintf(state.processlog, '\tExtracting data from blocks and reassigning:\n\t\t');
        
        % For each block
        for i_block = 1:length(subject.blocks)
            block = subject.blocks{i_block};
            fprintf(state.processlog, ' %s', block);
            
            % Load Stimuli File
            stimuli_file = sprintf('%s/parameters/%s/%s_%s.txt',...
                state.dir, study.name, study.name, block);
            [stim_text, stim_phon, stim_code] = textread(stimuli_file, '%*s\t%s\t%s\t%d');
            
            N_trials = N_trials + length(stim_code);
            
            % Load the events recorded by the machine
            event_file = gps_filename(subject, 'meg_events_block', ['block=' block]);
            events = load(event_file);
            events(:, 5) = events(:, 4);
            
            %% Parse Events
            % Find the start of every stimulus. Then look at the responses
            % following this trigger (and preceding the next one). Record all
            % trials
            
            stimuli_events = [find((events(:,4) > 0) & (events(:,4) <= 63))' size(events, 1)+1];
            
            if(length(stimuli_events) - 1 ~= length(stim_code))
                error('Incorrect amount of stimuli to events (probably a misrecord). Block: %s', block)
            end % If there are not enough events
            
            % For each stimulus
            for i_stimulus = 1:length(stim_text)
                set_start = stimuli_events(i_stimulus);
                set_stop  = stimuli_events(i_stimulus + 1) - 1;
                trial_set = events(set_start : set_stop, :);
                
                % Find their responses
                response_rows = find(~mod(trial_set(:, 4), 64));
                
                % Get stimulus parameters
                trigger_sent = stim_code(i_stimulus);
                trigger_rcvd = trial_set(1, 4);
                
                % Timing
                sample = trial_set(1, 1);
                
                % Check that the triggers match
                if (trigger_sent == trigger_rcvd)
                    
                    i_trial = i_trial + 1;
                    groupnum = 0;
                    
                    % Get typical data
                    data.trigger = trigger_sent;
                    data.block = block;
                    data.sample = sample;
                    
                    % Realword
                    switch data.trigger
                        case {8, 9, 10, 11}
                            data.realword = 'Y';
                        case {12, 13, 14, 15}
                            data.realword = 'N';
                        otherwise
                            data.realword = '?';
                    end
                    
                    % It will find their response (last, if any)
                    if(~isempty(response_rows))
                        response_time = response_rows(end);
                        
                        % Record the response time
                        time_start = trial_set(1, 2);
                        time_resp = trial_set(response_time, 2);
                        data.response_time = time_resp - time_start;
                        
                        % Find out if the response was yes or no
                        switch trial_set(response_time, 4)
                            case {64}
                                data.response = 'Y';
                            case {128}
                                data.response = 'N';
                            otherwise
                                data.response = '?';
                        end
                    else
                        groupnum = groupnum + 400;
                        data.response_time = 0;
                        data.response = '_';
                    end % if they responded
                    
                    % correct
                    switch [data.realword data.response]
                        case {'YY', 'NN'}
                            data.correct = 1;
                            groupnum = groupnum + 200;
                        case {'YN', 'NY'}
                            data.correct = 0;
                            groupnum = groupnum + 300;
                        otherwise
                            data.correct = 0;
                            groupnum = groupnum + 400;
                    end
                    
                    % neighdens
                    switch data.trigger
                        case {8, 9, 12, 13}
                            data.neighdens = 'HD';
                        case {10, 11, 14, 15}
                            data.neighdens = 'LD';
                        otherwise
                            data.neighdens = '?';
                    end
                    
                    % phonoprob
                    switch data.trigger
                        case {8, 10, 12, 14}
                            data.phonoprob = 'HP';
                        case {9, 11, 13, 15}
                            data.phonoprob = 'LP';
                        otherwise
                            data.phonoprob = '?';
                    end
                    
                    % Trial word and phone
                    data.text = stim_text{i_stimulus};
                    data.phon = stim_phon{i_stimulus};
                    
                    % Trial groups
                    data.groupnum = groupnum + data.trigger - 7;
                    data.groupname = sprintf('%s%s%s%s', data.realword, data.neighdens, data.phonoprob, data.response);
                    
                    % Unique event identifier
                    data.i_trial = i_trial;
                    data.ID = data.i_trial * 1000 + data.groupnum;
                    
                    % Save to the trial data structure
                    trialdata(i_trial) = data;
                    
                    % Reflect the new group number in the event list
                    events(set_start, 4) = data.ID;
                    events(set_start, 5) = data.groupnum;
                    
                else
                    % Check if it was not intentionally wrong (so throw error)
                    if ~(trigger_rcvd > 36)
                        error('Trigger Mismatch in block %s at sample %6g. Sent: %d Received: %d',...
                            block, sample, trigger_sent, trigger_rcvd);
                    end % If error
                end % If triggers match
                
            end % For each stimulus
            
            %% Write applied event files
            filename = sprintf('%s/events/%s_%s_all.eve',...
                subject.meg.dir, subject.name, block);
            fid = fopen(filename, 'w');
            filename = gps_filename(subject, 'meg_events_grouped_block', ['block=' block]);
            fid2 = fopen(filename, 'w');
            
            for i = 1:size(events, 1)
                fprintf(fid, '%6d %03.3f %6d %3d\n',...
                    events(i, 1), events(i, 2), events(i, 3), events(i, 4));
                fprintf(fid2, '%6d %03.3f %6d %3d\n',...
                    events(i, 1), events(i, 2), events(i, 3), events(i, 5));
            end % For Each event
            
            fclose(fid);
            fclose(fid2);
            
        end % For each block
        
        fprintf(state.processlog, '.\n');
    end % If for average or regular subject
    
    %% Save Trialdata
    
    N_missed = N_trials - length(trialdata);
    
    fprintf(state.processlog, '\tProduce figures\n');
    
    %% Figures
    
    RW = [trialdata.realword] == 'Y';
    NW = [trialdata.realword] == 'N';
    HD = strcmp({trialdata.neighdens}, 'HD');
    LD = strcmp({trialdata.neighdens}, 'LD');
    HP = strcmp({trialdata.phonoprob}, 'HP');
    LP = strcmp({trialdata.phonoprob}, 'LP');
%     RE = [trialdata.response] == 'Y';
    C = [trialdata.correct] == 1;
    
    % Other prep: format subject name
    fsubjName = subject.name;
    loc = find(fsubjName=='_');
    if(~isempty(loc)) % If we found an underscore in the subject's name
        fsubjName = [fsubjName(1:loc-1) '\' fsubjName(loc:end)];
    end
    
    % Show 8 subgroups accuracy
    figure(6754010);
    clf(6754010)
    bar(([sum(RW & HD & HP & C) / sum(RW & HD & HP),...
        sum(RW & HD & LP & C) / sum(RW & HD & LP),...
        sum(RW & LD & HP & C) / sum(RW & LD & HP),...
        sum(RW & LD & LP & C) / sum(RW & LD & LP),...
        sum(NW & HD & HP & C) / sum(NW & HD & HP),...
        sum(NW & HD & LP & C) / sum(NW & HD & LP),...
        sum(NW & LD & HP & C) / sum(NW & LD & HP),...
        sum(NW & LD & LP & C) / sum(NW & LD & LP);...
        0, 0, 0, 0, 0, 0, 0, 0])) % To provide for colors
    title(['PTC3 Accuracy by Type of Stimulus, for ' fsubjName])
    ylabel('Fraction of Correct Observations')
    set(gca,'XTick',[0.65 0.75 0.85 0.95 1.05 1.15 1.25 1.35])
    set(gca,'XTickLabel',{'HD-HP', 'HD-LP', 'LD-HP', 'LD-LP', 'HD-HP', 'HD-LP', 'LD-HP', 'LD-LP'})
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
    bar([mean(RTs(RW & HD & HP)) - 500,...
        mean(RTs(RW & LD & HP)) - 500;...
        mean(RTs(RW & HD & LP)) - 500,...
        mean(RTs(RW & LD & LP)) - 500])
    title('Words (Blue = HD, Red = LD)')
    ylabel('Reaction Time (ms)')
%     xlabel('Phonotactic Probability')
    set(gca,'XTick',[1 2])
    set(gca,'XTickLabel',{'High', 'Low'})
%     ylim([500 900])
    
    subplot(2, 2, 3)
    bar([mean(RTs(NW & HD & HP)) - 500,...
        mean(RTs(NW & LD & HP)) - 500;...
        mean(RTs(NW & HD & LP)) - 500,...
        mean(RTs(NW & LD & LP)) - 500])
    title('Words (Blue = HD, Red = LD)')
    ylabel('Reaction Time (ms)')
    xlabel('Phonotactic Probability')
    set(gca,'XTick',[1 2])
    set(gca,'XTickLabel',{'High', 'Low'})
%     ylim([500 900])
    
    % p577
    subplot(2, 2, 2)
    bar([mean(RTs(NW & HD & HP)) - mean(RTs(RW & HD & HP)),...
        mean(RTs(NW & LD & HP)) - mean(RTs(RW & LD & HP));...
        mean(RTs(NW & HD & LP)) - mean(RTs(RW & HD & LP)),...
        mean(RTs(NW & LD & LP)) - mean(RTs(RW & LD & LP))])
    title('Nonword - Word RT (Blue = HD, Red = LD)')
    ylabel('Difference in RT (ms)')
    xlabel('Phonotactic Probability')
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
    
    % Check that it has been performed
    gpsa_status_investigate(state, 'processedBehaviorals');
    
    % If this is the last subject, try to do the average behaviorals
    if(strcmp(state.subject, study.subjects{end}))
        state.subject = study.average_name;
        gpsa_meg_eveproc_PTC3(state, 'c');
    end
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    status = gpsa_status_verify(state, {'extractedMEGEvents', 'processedBehaviorals', 'hasGroupedEvents'});
    report.ready = status.('extractedMEGEvents');
    report.progress = mean([status.('processedBehaviorals'), status.('hasGroupedEvents')]);
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var'));
    varargout{1} = report;
end

end % function