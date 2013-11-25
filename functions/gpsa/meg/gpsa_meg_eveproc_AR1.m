function varargout = gpsa_meg_eveproc_AR1(varargin)
% Processes events for behavioral figures and stimulus groups for AR1
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.12.19 - Created from GPS1.7/gpsa_meg_eveproc_AR1
% 2013.04.24 - GPS1.8 Changed subset/subsubset to condition hierarchy
% 2013.06.11 - Updated based on new condition set
% 2013.06.13 - Finished, corrects some errors now

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
    state.function = 'gpsa_meg_eveproc_AR1';
    tbegin = tic;
    
    if(~isfield(state, 'processlog'))
        state.processlog = 1;
    end
    
    fprintf(state.processlog, '%s: Processing events for %s\n', state.function, state.subject);
    
    % Allocate the trialdata
    trialdata = struct('text', '', 'phon', '', 'phonfile', '', 'imag',...
        '', 'imagfile', '', 'voice', '', 'entrynum', '', 'category', '',...
        'foil', '', 'experiment', '', 'sample', 0, 'time', 0,...
        'trigger', 0, 'group', 0, 'i_trial', 0);
    
    % Read in the subject's performance and the block commands
    for i_block = 1:length(subject.blocks)
        block = subject.blocks{i_block};
        blockdata = gpsa_meg_eveproc_AR_readblockfile(block);
        
        evedata = load(gps_filename('meg_events_block', subject, ['block=' block]));
        evedata_grouped = zeros(size(evedata, 1) * 2, size(evedata, 2));
        fs = mean(diff(evedata(diff(evedata(:, 2)) > 1, 1)) ./ diff(evedata(diff(evedata(:, 2)) > 1, 2)));
        
        % construct evedata from the macdata
        %         macdata = sprintf('%s/%s/Subject Data/%s.mat', gps_presets('parameters'), study.name, subject.name);
        %         macdata = load(macdata, block);
        %         macdata = macdata.(block);
        
        N_events = length(evedata);
        
        i_event = 1;
        i_event_grouped = 0;
        i_trial = 0;
        
        audonset = [];
        response = [];
        
        while i_event <= N_events
            event = evedata(i_event, :);
            
            % Observe the 0 trigger event
            if event(4) == 0 && i_event == 1
                i_event_grouped = i_event_grouped + 1;
                evedata_grouped(i_event_grouped, :) = event;
                fprintf(state.processlog, '% 5d Saw initialization trigger 0 at beginning.\n', i_event);
            elseif event(3) > event (4)
                fprintf(state.processlog, '% 5d Trigger release %d to %d, ignoring.\n', i_event, event(3), event (4));
            elseif mod(event(4), 64) == 0
                response = [event(1:3) log(event(4)) / log(2) - 7];
                if(response(4) <= 0); response(4) = response(4) + 2; end
                fprintf(state.processlog, '% 5d Found a button press %d\n', i_event, response(4));
            elseif mod(event(4), 64) > 0
                % If we have an old trigger, mark a skipped trial
                if ~isempty(audonset)
                    i_trial = i_trial + 1;
                    fprintf(state.processlog, '\tDidn''t find a response for trial %d, trigger %d\n', i_trial, audonset(4));
                end
                
                % Mark the new trigger
                audonset = [event(1:3) mod(event(4), 64)];
                response = [];
                fprintf(state.processlog, '% 5d Found an auditory event trigger %d\n', i_event, audonset(4));
            end
            i_event = i_event + 1;
            
            % If we are in a new trial
            if ~isempty(audonset) && ~isempty(response)
                i_trial = i_trial + 1;
                
                % Check trial
                if blockdata(i_trial).code == audonset(4)
                    
                    %% Set up new auditory onset event
                    time = audonset(2);
                    sample = floor(time * fs);
                    trigger = audonset(4);
                    correct = trigger == 4 && response(4) == 1 ||...
                              trigger ~= 4 && response(4) == 2;
                    
                    % Determine the group
                    switch trigger
                        case {1, 2}
                            if correct; group = 201; else group = 301; end
                        case 3
                            if correct; group = 202; else group = 302; end
                        case 4
                            if correct; group = 203; else group = 303; end
                    end
                    
                    % Save
                    i_event_grouped = i_event_grouped + 1;
                    evedata_grouped(i_event_grouped, :) = [sample time 0 group];
                    
                    %% Save data
                    % Trial word and phone
                    data.text     = blockdata(i_trial).text;
                    data.phon     = blockdata(i_trial).phon;
                    data.phonfile = blockdata(i_trial).phonfile;
                    data.imag     = blockdata(i_trial).imag;
                    data.imagfile = blockdata(i_trial).imagfile;
                    data.voice    = blockdata(i_trial).voice;
                    data.entrynum = blockdata(i_trial).entrynum;
                    data.category = blockdata(i_trial).category;
                    data.foil     = blockdata(i_trial).foil;
                    data.experiment = 'AR1';
                    data.sample   = sample;
                    data.time     = time;
                    data.trigger  = trigger;
                    data.group    = group;
                    data.i_trial  = i_trial;
                    
                    % Save to the trial data structure
                    trialdata(i_trial) = data;
                    fprintf(state.processlog, '\t Saved trial %d\n', i_trial);
                    
                    %% Set up new visual onset event
                    time = time + 0.7;
                    sample = floor(time * fs);
                    group = group + 10;
                    
                    % Save
                    i_event_grouped = i_event_grouped + 1;
                    evedata_grouped(i_event_grouped, :) = [sample time 0 group];
                    
                    % Clear the response and audio onset
                    audonset = [];
                    response = [];
                else
                    fprintf(state.processlog, '\t Found the wrong trigger %d, expected %d\n', audonset(4), blockdata(i_trial).code);
                    %                 fprintf(state.processlog, '% 5d% 7d % 8.3f% 4d% 4d\n', i_event, event(1), event(2), event(3), event(4))
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
    
    return
    
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