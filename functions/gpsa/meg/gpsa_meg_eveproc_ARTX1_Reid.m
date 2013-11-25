function varargout = gpsa_meg_eveproc_ARTX1_Reid(varargin)
% Processes events for behavioral figures and stimulus groups for AR1
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.12.19 - Created from GPS1.7/gpsa_meg_eveproc_AR1

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_subs = 0; % Subset specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    study = gpsa_parameter(state.study);
    subject = gpsa_parameter(state.subject);
    state.function = 'gpsa_meg_eveproc_ARTX1';
    tbegin = tic;
    
    if(~isfield(state, 'processlog'))
        state.processlog = 1;
    end
    
    fprintf(state.processlog, '%s: Processing events for %s\n', state.function, state.subject);
    
    trialdata = struct('trigger', NaN, 'block', '', 'sample', NaN,...
        'response_time', NaN, 'response', '', 'foil', '', 'correct', NaN,...
         'text', '', 'phon', '', 'phonfile', '', 'imag', '', 'imagfile', '',...
         'voice', '', 'entrynum', '', 'category', '', 'cat', '', 'experiment', '',...
        'groupnum', NaN, 'groupname', '', 'i_trial', NaN, 'ID', NaN);
    N_trials = 0;
    i_trial = 0;
    
    % Are we doing the average or individual subject?
    if(strcmp(state.subject, study.average_name))
        folder = sprintf('%s/%s/behaviorals', study.meg.dir, study.average_name);
        if(~exist(folder, 'dir')); mkdir(folder); end
        
        % Load and concatenate subjects
        for i_subject = 1:length(study.subjects)
            asubject = gpsa_parameter(state, study.subjects{i_subject});
            
            trialdata = [trialdata asubject.meg.behav.trialdata];
            N_trials = N_trials + asubject.meg.behav.N_trials;
        end % For each subject
        
        % Also if the subject is empty, make a default average subject
        if(isempty(subject))
            subject = data_defaultsubject(study.average_name, study);
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
            
%             [stim_text, stim_phon, stim_code] = textread(stimuli_file, '%*s\t%s\t%s\t%d');
% Plasticity Recovery Observation experiment on Acute Aphasics
                experiment = 'ARTX1';
                % ferry.jpg	ferry.wav	M31	transportation
                [stim_imagfile, stim_phonfile, stim_ID, stim_category] = textread(stimuli_file, '%s\t%s\t%s\t%s');
                
                N_trials_local = length(stim_imagfile);
                stim_text = cell(N_trials_local, 1);
                stim_phon = cell(N_trials_local, 1);
                stim_imag = cell(N_trials_local, 1);
                stim_code = zeros(N_trials_local, 1);
                stim_voice = cell(N_trials_local, 1);
                stim_foil = zeros(N_trials_local, 1);
                stim_entrynum = zeros(N_trials_local, 1);
                stim_foilnum = zeros(N_trials_local, 1);
                stim_catnum = zeros(N_trials_local, 1);
                for i_trial_local = 1:N_trials_local
                    stim_text{i_trial_local} = stim_phonfile{i_trial_local}(1:end - 4);
                    stim_phon{i_trial_local} = stim_phonfile{i_trial_local}(1:end - 4);
                    stim_imag{i_trial_local} = stim_imagfile{i_trial_local}(1:end - 4);
                    stim_voice{i_trial_local} = 'T';
                    
                    trigger = stim_ID{i_trial_local};
                    if(strcmp(trigger(1:2), 'PI'))
                        stim_foil(i_trial_local) = 'I';
                        stim_code(i_trial_local) = 0 + str2double(trigger(3:end));
                        stim_entrynum(i_trial_local) = str2double(trigger(3:end));
                        stim_foilnum(i_trial_local) = 1;
                    elseif(strcmp(trigger(1:2), 'PM'))
                        stim_foil(i_trial_local) = 'V';
                        stim_code(i_trial_local) = 32 + str2double(trigger(3:end));
                        stim_entrynum(i_trial_local) = str2double(trigger(3:end));
                        stim_foilnum(i_trial_local) = 2;
                    elseif(strcmp(trigger(1:2), 'PF'))
                        stim_foil(i_trial_local) = 'F';
                        stim_code(i_trial_local) = 64 + str2double(trigger(3:end));
                        stim_entrynum(i_trial_local) = str2double(trigger(3:end));
                        stim_foilnum(i_trial_local) = 3;
                    elseif(strcmp(trigger(1), 'S'))
                        stim_foil(i_trial_local) = 'S';
                        stim_code(i_trial_local) = 96 + str2double(trigger(2:end));
                        stim_entrynum(i_trial_local) = str2double(trigger(2:end));
                        stim_foilnum(i_trial_local) = 4;
                    elseif(strcmp(trigger(1), 'M'))
                        stim_foil(i_trial_local) = 'M';
                        stim_code(i_trial_local) = 128 + str2double(trigger(2:end));
                        stim_entrynum(i_trial_local) = str2double(trigger(2:end));
                        stim_foilnum(i_trial_local) = 5;
                    end
                    
                    % Shorten the category name
                    switch stim_category{i_trial_local}
                        case 'vegetable'
                            stim_cat(i_trial_local) = 'V';
                            stim_catnum(i_trial_local) = 1;
                        case 'furniture'
                            stim_cat(i_trial_local) = 'N';
                            stim_catnum(i_trial_local) = 2;
                        case 'bird'
                            stim_cat(i_trial_local) = 'B';
                            stim_catnum(i_trial_local) = 3;
                        case 'transportation'
                            stim_cat(i_trial_local) = 'T';
                            stim_catnum(i_trial_local) = 4;
                        case 'clothing'
                            stim_cat(i_trial_local) = 'C';
                            stim_catnum(i_trial_local) = 5;
                        case 'fruit'
                            stim_cat(i_trial_local) = 'F';
                            stim_catnum(i_trial_local) = 6;
                    end
                end
            
            % Convert stimuli cell arrays into filenames
            
            N_trials = N_trials + length(stim_code);
            
            % Load the events recorded by the machine
            event_file = sprintf('%s/triggers/%s_%s.eve',...
                subject.meg.dir, subject.name, block);
            events = load(event_file);
            events(:, 5) = events(:, 4);
            
            %% Parse Events
            % Find the start of every stimulus. Then look at the responses
            % following this trigger (and preceding the next one). Record all
            % trials
            
            max_event = max(events(:, 4));
            max_stimulus = 63;
            if(max_event >= 256); max_stimulus = 255; end
            stimuli_events = [find((events(:,4) > 0) & (events(:,4) <= max_stimulus))' size(events, 1)+1];
            length(stimuli_events)
            length(stim_code)
            
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
                    
                    % It will find their response (last, if any)
                    if(~isempty(response_rows))
                        response_time = response_rows(1);
                        
                        % Record the response time
                        time_start = trial_set(1, 2);
                        time_resp = trial_set(response_time, 2);
                        data.response_time = time_resp - time_start;
                        
                        % Find out if the response was yes or no
                        switch trial_set(response_time, 4)
                            case {64, 256}
                                data.response = 'M';
                            case {128, 512}
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
                    data.foil = stim_foil(i_stimulus);
                    switch [data.foil data.response]
                        case {'MM', 'IN', 'VN', 'FN', 'SN'}
                            data.correct = 1;
                            groupnum = groupnum + 200;
                        case {'MN', 'IM', 'VM', 'FM', 'SM'}
                            data.correct = 0;
                            groupnum = groupnum + 300;
                        otherwise
                            data.correct = 0;
                            groupnum = groupnum + 400;
                    end
                    
                    % Trial word and phone
                    data.text = stim_text{i_stimulus};
                    data.phon = stim_phon{i_stimulus};
                    data.phonfile = stim_phonfile{i_stimulus};
                    data.imag = stim_imag{i_stimulus};
                    data.imagfile = stim_imagfile{i_stimulus};
                    data.voice = stim_voice{i_stimulus};
                    data.entrynum = stim_entrynum(i_stimulus);
                    data.category = stim_category{i_stimulus};
                    data.cat = stim_cat(i_stimulus);
                    data.experiment = experiment;
                    
                    % Trial groups
                    data.groupnum = groupnum + stim_foilnum(i_stimulus) + stim_catnum(i_stimulus) * 5;
                    data.groupname = sprintf('%s%s%s', data.foil, data.cat, data.response);
                    
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
%                     if ~(trigger_rcvd > 36)
                        error('Trigger Mismatch in block %s at sample %6g. Sent: %d Received: %d',...
                            block, sample, trigger_sent, trigger_rcvd);
%                     end % If error
                end % If triggers match
                
            end % For each stimulus
            
            %% Write applied event files
            filename = sprintf('%s/triggers/%s_%s_all.eve',...
                subject.meg.dir, subject.name, block);
            fid = fopen(filename, 'w');
            filename = sprintf('%s/triggers/%s_%s_grouped.eve',...
                subject.meg.dir, subject.name, block);
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
    
    FI = [trialdata.foil] == 'I';
    FV = [trialdata.foil] == 'V';
    FF = [trialdata.foil] == 'F';
    FS = [trialdata.foil] == 'S';
    FM = [trialdata.foil] == 'M';
    FN = [trialdata.foil] ~= 'M';
    TX = strcmp({trialdata.experiment}, 'ARTX1');
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
    bar(([sum(FI & ~TX & C) / sum(FI & ~TX),...
        sum(FV & ~TX & C) / sum(FV & ~TX),...
        sum(FF & ~TX & C) / sum(FF & ~TX),...
        sum(FS & ~TX & C) / sum(FS & ~TX),...
        sum(FM & ~TX & C) / sum(FM & ~TX);...
        0, 0, 0, 0, 0])) % To provide for colors
    title(['AR1 Accuracy by Type of Stimulus, for ' fsubjName])
    ylabel('Fraction of Correct Observations')
    set(gca,'XTick',[0.70 0.85 1.00 1.15 1.30])
    set(gca,'XTickLabel',{'Initial', 'Vowel', 'Final', 'Semantic', 'Match'})
    text(1.15, -0.08, '<- Foils', 'HorizontalAlignment', 'Center')
%     text(1.2, -0.08, 'Nonword', 'HorizontalAlignment', 'Center')
    axis([0.55 1.45 0 1])
    
    image_file = sprintf('%s/behaviorals/%s_accuracy.png',...
        subject.meg.dir, subject.name);
    saveas(6754010, image_file);
    
    if(sum(TX))
        % Show 8 subgroups accuracy
        figure(6754011);
        clf(6754011)
        bar(([sum(FI & TX & C) / sum(FI & TX),...
            sum(FV & TX & C) / sum(FV & TX),...
            sum(FF & TX & C) / sum(FF & TX),...
            sum(FS & TX & C) / sum(FS & TX),...
            sum(FM & TX & C) / sum(FM & TX);...
            0, 0, 0, 0, 0])) % To provide for colors
        title(['AR1 Accuracy by Type of Stimulus, for ' fsubjName])
        ylabel('Fraction of Correct Observations')
        set(gca,'XTick',[0.70 0.85 1.00 1.15 1.30])
        set(gca,'XTickLabel',{'Initial', 'Vowel', 'Final', 'Semantic', 'Match'})
        text(1.15, -0.08, '<- Foils', 'HorizontalAlignment', 'Center')
        %     text(1.2, -0.08, 'Nonword', 'HorizontalAlignment', 'Center')
        axis([0.55 1.45 0 1])
        
        image_file = sprintf('%s/behaviorals/%s_accuracy_tx.png',...
            subject.meg.dir, subject.name);
        saveas(6754011, image_file);
    end
    
    %% Response Time Figures
    % Emulating Luce et al's charts
    
%     RTs = [trialdata.response_time] * 1000;
%     
%     % p572
%     figure(6754011)
%     clf(6754011)
%     subplot(2, 2, 1)
%     bar([mean(RTs(RW & HD & HP)) - 500,...
%         mean(RTs(RW & LD & HP)) - 500;...
%         mean(RTs(RW & HD & LP)) - 500,...
%         mean(RTs(RW & LD & LP)) - 500])
%     title('Words (Blue = HD, Red = LD)')
%     ylabel('Reaction Time (ms)')
% %     xlabel('Phonotactic Probability')
%     set(gca,'XTick',[1 2])
%     set(gca,'XTickLabel',{'High', 'Low'})
% %     ylim([500 900])
%     
%     subplot(2, 2, 3)
%     bar([mean(RTs(NW & HD & HP)) - 500,...
%         mean(RTs(NW & LD & HP)) - 500;...
%         mean(RTs(NW & HD & LP)) - 500,...
%         mean(RTs(NW & LD & LP)) - 500])
%     title('Words (Blue = HD, Red = LD)')
%     ylabel('Reaction Time (ms)')
%     xlabel('Phonotactic Probability')
%     set(gca,'XTick',[1 2])
%     set(gca,'XTickLabel',{'High', 'Low'})
% %     ylim([500 900])
    
%     % p577
%     subplot(2, 2, 2)
%     bar([mean(RTs(NW & HD & HP)) - mean(RTs(RW & HD & HP)),...
%         mean(RTs(NW & LD & HP)) - mean(RTs(RW & LD & HP));...
%         mean(RTs(NW & HD & LP)) - mean(RTs(RW & HD & LP)),...
%         mean(RTs(NW & LD & LP)) - mean(RTs(RW & LD & LP))])
%     title('Nonword - Word RT (Blue = HD, Red = LD)')
%     ylabel('Difference in RT (ms)')
%     xlabel('Phonotactic Probability')
%     set(gca,'XTick',[1 2])
%     set(gca,'XTickLabel',{'High', 'Low'})
%     
%     image_file = sprintf('%s/behaviorals/%s_RT.png',...
%         subject.meg.dir, subject.name);
%     saveas(6754011, image_file);
    
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
    
    % If this is the last subject, try to do the average behaviorals
%     if(strcmp(state.subject, study.subjects{end}))
%         state.subject = study.average_name;
%         gpsa_meg_eveproc_AR1(state, 'c');
%     end
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state.subject);
    if(~isempty(subject))
        % Predecessor: meg_eveext
        report.ready = length(dir([subject.meg.dir '/triggers/*.eve'])) >= 1;
        report.progress = (double(length(dir([subject.meg.dir '/behaviorals'])) > 2) ...
            + double(~isempty(subject.meg.behav.trialdata))...
            + double(length(dir([subject.meg.dir '/triggers/*grouped.eve'])) >= length(subject.blocks))) / 3;
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