function varargout = gpsa_meg_eveproc_SPhon(varargin)
% Processes events for behavioral figures and stimulus groups for SPhon
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.06.14 - Created based on GPS1.8/gpsa_meg_eveproc_AR1

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
    state.function = 'gpsa_meg_eveproc_SPhon';
    tbegin = tic;
    
    if(~isfield(state, 'processlog'))
        state.processlog = 1;
    end
    
    fprintf(state.processlog, '%s: Processing events for %s\n', state.function, state.subject);
    
    % Allocate the trialdata
    trialdata = struct('i_trial', 0, 'i_trial_overall', 0,...
        'i_stimulus', 0, 'i_event', 0, 'order', 0,...
        'order_in_group', 0, 'target', '', 'conda', '', 'present', '',...
        'sentence', '', 'word', '', 'pair', 0, 'filename', '',...
        'context_duration', 0, 'order_random', 0, 'experiment', '',...
        'sample', 0, 'time', 0, 'trigger', 0, 'correct', 0, 'group', 0,...
        'block', '');
    
    % Read in the stimuli table
    stimuli_file = sprintf('%s/%s/%s_stimuli.txt',...
        gps_presets('studyparameters'), study.name, study.name);
    
    [order, order_in_group, target, conda, present, sentence, word, pair,...
        filename, context_duration, order_random] = textread(stimuli_file,...
        '%d\t%d\t%s\t%s\t%s\t%[^\t]\t%s\t%d\t%s\t%f\t%d'); %#ok<REMFF1>
    % order: The number of the stimulus in the list of all
    % order_in_group: The number for the stimulus in the group (ie t_x_y)
    % target: The target consonant
    % conda: The condition the stimulus is in: eXperimental, Baseline, Distractor
    % present: Whether or not the target is present in this sentence
    % sentence: The sentence in the stimulus
    % word: The final word in the sentence
    % pair: The number for the pair it is in for experimental words
    % filename: The name of the soundfile
    % context_duration: The length of the context
    % order_random: The pseudorandomly arranged order that the stimuli will be
    % presented in.
    
    % Holding variables
    N_blocks = 6;
    i_trial_overall = 0;
    
    % Read in the subject's performance and the block commands
    for i_block = 1:length(subject.blocks)
        block = subject.blocks{i_block};
        
        % Determine which stimuli will be presented in this block.
        block_stimuli = [];
        switch block
            case {'B1', 'B2', 'B3', 'B4', 'B5', 'B6'}
                blocknumber = str2double(block(2));
                stimuli_per_block = length(order_random) / N_blocks;
                first = floor(stimuli_per_block * (blocknumber - 1)) + 1;
                last = floor(stimuli_per_block * blocknumber);
                
                j = 1;
                for i = first:last
                    block_stimuli(j) = find(order_random == i); %#ok<AGROW>
                    j = j + 1;
                end
            case {'All'}
                j = 1;
                for i = 1:length(order_random)
                    block_stimuli(j) = find(order_random == i); %#ok<AGROW>
                    j = j + 1;
                end
            case {'Inorder'}
                block_stimuli = 1:length(order_random);
            case {'Debug'}
                block_stimuli = [1 100 400];
            otherwise
                error('%s is not a valid block name')
        end
        
        evedata = load(gps_filename('meg_events_block', subject, ['block=' block]));
        evedata_grouped = zeros(size(evedata, 1) * 2, size(evedata, 2));
        fs = mean(diff(evedata(diff(evedata(:, 2)) > 1, 1)) ./ diff(evedata(diff(evedata(:, 2)) > 1, 2)));
        
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
                fprintf(state.processlog, '%s % 5d Saw initialization trigger 0 at beginning.\n', block, i_event);
            elseif event(3) > event (4)
                fprintf(state.processlog, '%s % 5d Trigger release %d to %d, ignoring.\n', block, i_event, event(3), event (4));
            elseif mod(event(4), 64) == 0
                response = [event(1:3) log(event(4)) / log(2) - 7];
                if(response(4) <= 0); response(4) = response(4) + 2; end
                fprintf(state.processlog, '%s % 5d Found a button press %d\n', block, i_event, response(4));
            elseif mod(event(4), 64) > 0
                % If we have an old trigger, mark a skipped trial
                if ~isempty(audonset) && (event(2) - audonset(2) > 0.01)
                    i_trial = i_trial + 1;
                    fprintf(state.processlog, '\tDidn''t find a response for trial %d, trigger %d\n', i_trial, audonset(4));
                end
                
                % Mark the new trigger
                audonset = [event(1:3) mod(event(4), 64)];
                response = [];
                fprintf(state.processlog, '%s % 5d Found an auditory event trigger %d\n', block, i_event, audonset(4));
            end
            i_event = i_event + 1;
            
            % If we are in a new trial
            if ~isempty(audonset) && ~isempty(response)
                i_trial = i_trial + 1;
                i_stimulus  = block_stimuli(i_trial);
                
                % Determine which trigger number was sent
                event = sprintf('%s_%s_%s', target{i_stimulus}, conda{i_stimulus}, present{i_stimulus});
                switch event
                    case 't_x_y'
                        trigger = 1;
                    case 'p_x_y'
                        trigger = 2;
                    case 'd_x_y'
                        trigger = 3;
                    case 'b_x_y'
                        trigger = 4;
                    case 't_b_y'
                        trigger = 5;
                    case 'p_b_y'
                        trigger = 6;
                    case 'd_b_y'
                        trigger = 7;
                    case 'b_b_y'
                        trigger = 8;
                    case 't_d_y'
                        trigger = 9;
                    case 'p_d_y'
                        trigger = 10;
                    case 'd_d_y'
                        trigger = 11;
                    case 'b_d_y'
                        trigger = 12;
                    case 't_d_n'
                        trigger = 13;
                    case 'p_d_n'
                        trigger = 14;
                    case 'd_d_n'
                        trigger = 15;
                    case 'b_d_n'
                        trigger = 16;
                    otherwise
                        error('%s is not a correct event', event);
                end
                
                % Check trial
                if trigger == audonset(4)
                    
                    %% Set up new auditory onset event
                    time = audonset(2);
                    sample = floor(time * fs);
                    trigger = audonset(4);
                    correct = trigger <= 12 && response(4) == 1 ||...
                              trigger > 12  && response(4) == 2;
                    
                    % Determine the group
                    switch trigger
                        case {1, 2, 3, 4}
                            if correct; group = 205; else group = 305; end
                            % Find out if it is 201/301 after matching
                            % pairs
                        case {5, 6, 7, 8}
                            if correct; group = 202; else group = 302; end
                        case {9, 10, 11, 12}
                            if correct; group = 203; else group = 303; end
                        case {13, 14, 15, 16}
                            if correct; group = 204; else group = 304; end
                    end
                    
                    % Save
                    i_event_grouped = i_event_grouped + 1;
                    evedata_grouped(i_event_grouped, :) = [sample time 0 group];
                    
                    %% Save data
                    % Trial word and phone
                    data.i_trial  = i_trial;
                    i_trial_overall = i_trial_overall + 1;
                    data.i_trial_overall  = i_trial_overall;
                    data.i_stimulus  = i_stimulus;
                    data.i_event  = i_event_grouped;
                    data.order    = order(i_stimulus);
                    data.order_in_group = order_in_group(i_stimulus);
                    data.target   = target{i_stimulus};
                    data.conda    = conda{i_stimulus};
                    data.present  = present{i_stimulus};
                    data.sentence = sentence{i_stimulus};
                    data.word     = word{i_stimulus};
                    data.pair     = pair(i_stimulus);
                    data.filename = filename{i_stimulus};
                    data.context_duration = context_duration(i_stimulus);
                    data.order_random = order_random(i_stimulus);
                    data.experiment = 'SPhon';
                    data.sample   = sample;
                    data.time     = time;
                    data.trigger  = trigger;
                    data.correct  = correct;
                    data.group    = group;
                    data.block    = block;
                    
                    % Save to the trial data structure
                    trialdata(i_trial_overall) = data;
                    fprintf(state.processlog, '\t Saved trial %d (overall %d)\n', i_trial, i_trial_overall);
                    
                    %% Set up new last word onset event
                    if(data.context_duration > 0)
                        time = time + data.context_duration;
                        sample = floor(time * fs);
                        group = group + 10;
                        
                        % Save
                        i_event_grouped = i_event_grouped + 1;
                        evedata_grouped(i_event_grouped, :) = [sample time 0 group];
                    end
                    
                    % Clear the response and audio onset
                    audonset = [];
                    response = [];
                else
                    fprintf(state.processlog, '\t Found the wrong trigger %d, expected %d\n', audonset(4), trigger);
                end
                
            end % if we have a new trigger & response
        end % For each event
        
        % Aggregate block data
        evedata_grouped(i_event_grouped + 1 : end, :) = [];
        blockdata.(block) = evedata_grouped;
        
    end % for each block
    
    %% Match experimental pairs
    N_pairs_correct = 0;
    N_pairs_incorrect = 0;
    N_pairs_aspirated = 0;
    N_pairs_voiced = 0;
    N_pairs_thrownout = 0;
    N_pairs = 54;%max([trialdata.pair]);
    for i_pair = 1:N_pairs
        pair = find([trialdata.pair] == i_pair);
        
        if(length(pair) == 2)
            % Compare the trials, see if they were both correct or both
            % wrong.
            trial1 = trialdata(pair(1));
            trial2 = trialdata(pair(2));
            
            newcode = 0;
            aspirated = 0;
            if(trial1.correct && trial2.correct)
                newcode = 201;
                N_pairs_correct = N_pairs_correct + 1;
            elseif(~trial1.correct && ~trial2.correct)
                newcode = 301;
                N_pairs_incorrect = N_pairs_incorrect + 1;
            else
                if((trial1.correct && sum(strcmp({'t', 'p', 'k'}, trial1.target))) || ...
                        (trial2.correct && sum(strcmp({'t', 'p', 'k'}, trial2.target))))
                    N_pairs_aspirated = N_pairs_aspirated + 1;
                    aspirated = 1;
                else
                    N_pairs_voiced = N_pairs_voiced + 1;
                end
            end
            
            % If we have a new code, change it in the trialdata and the
            % blockdata
            if newcode
                trialdata(pair(1)).group = newcode;
                trialdata(pair(2)).group = newcode;
                
                % Edit first in pair, sentence and word trigger
                evedata_grouped = blockdata.(trialdata(pair(1)).block);
                evedata_grouped(trialdata(pair(1)).i_event, 4) = newcode;
                evedata_grouped(trialdata(pair(1)).i_event + 1, 4) = newcode + 10;
                blockdata.(trialdata(pair(1)).block) = evedata_grouped;
                
                % Edit second in pair, sentence and word trigger
                evedata_grouped = blockdata.(trialdata(pair(2)).block);
                evedata_grouped(trialdata(pair(2)).i_event, 4) = newcode;
                evedata_grouped(trialdata(pair(2)).i_event + 1, 4) = newcode + 10;
                blockdata.(trialdata(pair(2)).block) = evedata_grouped;
            end
            
            switch newcode + aspirated
                case 201
                    fprintf(state.processlog, '% 3d\tCorrect  \t%s\t%s(%d)\t%s\t%s(%d)\n', i_pair,...
                        trialdata(pair(1)).word, trialdata(pair(1)).block, trialdata(pair(1)).i_trial,...
                        trialdata(pair(2)).word, trialdata(pair(2)).block, trialdata(pair(2)).i_trial);
                case 301
                    fprintf(state.processlog, '% 3d\tIncorrect\t%s\t%s(%d)\t%s\t%s(%d)\n', i_pair,...
                        trialdata(pair(1)).word, trialdata(pair(1)).block, trialdata(pair(1)).i_trial,...
                        trialdata(pair(2)).word, trialdata(pair(2)).block, trialdata(pair(2)).i_trial);
                case 1
                    fprintf(state.processlog, '% 3d\tUnvoiced \t%s\t%s(%d)\t%s\t%s(%d)\n', i_pair,...
                        trialdata(pair(1)).word, trialdata(pair(1)).block, trialdata(pair(1)).i_trial,...
                        trialdata(pair(2)).word, trialdata(pair(2)).block, trialdata(pair(2)).i_trial);
                case 0
                    fprintf(state.processlog, '% 3d\tVoiced   \t%s\t%s(%d)\t%s\t%s(%d)\n', i_pair,...
                        trialdata(pair(1)).word, trialdata(pair(1)).block, trialdata(pair(1)).i_trial,...
                        trialdata(pair(2)).word, trialdata(pair(2)).block, trialdata(pair(2)).i_trial);
            end
        elseif(length(pair) == 1)
            N_pairs_thrownout = N_pairs_thrownout + 1;
            fprintf(state.processlog, '% 3d\tMissing   \t%s\t%s(%d)\n', i_pair,...
                trialdata(pair(1)).word, trialdata(pair(1)).block, trialdata(pair(1)).i_trial);
        elseif(isempty(pair))
            N_pairs_thrownout = N_pairs_thrownout + 1;
            fprintf(state.processlog, '% 3d\tMissingBoth \n', i_pair);
        else
            N_pairs_thrownout = N_pairs_thrownout + 1;
            fprintf(state.processlog, '% 3d\tDuplicate \t \t \n', i_pair);
        end
    end % For each pair
    
    fprintf(state.processlog, 'All Stimuli       : %.2f%% Accuracy\n', ...
        mean([trialdata.correct]) * 100);
    fprintf(state.processlog, '\t%d Correct, %d Incorrect, %d Thrown Out\n', ...
        sum([trialdata.correct]),...
        sum(~[trialdata.correct]),...
        length(order) - length(trialdata));
    fprintf(state.processlog, 'Experimental Pairs: %.2f%% Accuracy\n', N_pairs_correct / (N_pairs - N_pairs_thrownout) * 100);
    fprintf(state.processlog, '\t%d Correct, %d Both Wrong, %d Unvoiced only, %d Voiced only, %d Thrown Out\n', ...
        N_pairs_correct, N_pairs_incorrect, N_pairs_aspirated, N_pairs_voiced, N_pairs_thrownout);
    fprintf(state.processlog, 'Baseline Stimuli  : %.2f%% Accuracy\n', ...
        mean([trialdata([trialdata.conda] == 'b').correct]) * 100);
    fprintf(state.processlog, '\t%d Correct, %d Incorrect, %d Thrown Out\n', ...
        sum([trialdata([trialdata.conda] == 'b').correct]),...
        sum(~[trialdata([trialdata.conda] == 'b').correct]),...
        N_pairs * 2 - sum([trialdata.conda] == 'b'));
    
    
    %% Write grouped block data
    for i_block = 1:length(subject.blocks)
        block = subject.blocks{i_block};
        evedata_grouped = blockdata.(block);
        
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
    
    N_trials = length(order);
    N_missed = N_trials - length(trialdata);
    
    % Organize experiment sets
    X  = [trialdata.conda] == 'x'; % Experimental Trials
    B  = [trialdata.conda] == 'b'; % Baseline
    DY = [trialdata.conda] == 'd' & [trialdata.present] == 'y'; % Distractor Present
    DN = [trialdata.conda] == 'd' & [trialdata.present] == 'n'; % Distractor Not Present
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
    subplot(2, 3, 1)
    bar([sum(X & C), sum(X & ~C); 0 0] / sum(X))
    ylabel('Fraction')
    set(gca, 'XTickLabel', {'Experimental'})
%     text(1, -0.2, sprintf('%.0f%% (%d/%d)', sum(X & C) / sum(X) * 100, sum(X & C), sum(X)), 'HorizontalAlignment', 'Center');
    text(1, -0.2, sprintf('%.0f%%', sum(X & C) / sum(X) * 100), 'HorizontalAlignment', 'Center');
    text(0.85, sum(X  &  C) / sum(X ), num2str(sum(X  &  C)), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'BackgroundColor', 'White', 'Margin', .1);
    text(1.15, sum(X  & ~C) / sum(X ), num2str(sum(X  & ~C)), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'BackgroundColor', 'White', 'Margin', .1);
    text(1, 1.1, [study.name ' Accuracy by Type of Stimulus, for ' fsubjName])
    xlim([0.5 1.5])
    
    subplot(2, 3, 2:3)
    bar([N_pairs_correct N_pairs_aspirated N_pairs_voiced N_pairs_incorrect N_pairs_thrownout; 0 0 0 0 0])
    %     ylabel('Pairs')
    text(0.52, 27, 'Pairs', 'HorizontalAlignment', 'Center', 'Rotation', 90)
    set(gca,'XTick', [])
    text(0.70, -4, 'Correct' , 'HorizontalAlignment', 'Center', 'FontSize', 8);
    text(0.85, -4, 'Unvoiced', 'HorizontalAlignment', 'Center', 'FontSize', 8)
    text(1.00, -4, 'Voiced'  , 'HorizontalAlignment', 'Center', 'FontSize', 8)
    text(1.15, -4, 'Switched', 'HorizontalAlignment', 'Center', 'FontSize', 8)
    text(1.30, -4, 'Excluded', 'HorizontalAlignment', 'Center', 'FontSize', 8)
    text(0.70, -10, sprintf('%.0f%%', N_pairs_correct   * 100 / sum([N_pairs_correct N_pairs_aspirated N_pairs_voiced N_pairs_incorrect])), 'HorizontalAlignment', 'Center');
    text(0.85, -10, sprintf('%.0f%%', N_pairs_aspirated * 100 / sum([N_pairs_correct N_pairs_aspirated N_pairs_voiced N_pairs_incorrect])), 'HorizontalAlignment', 'Center');
    text(1.00, -10, sprintf('%.0f%%', N_pairs_voiced    * 100 / sum([N_pairs_correct N_pairs_aspirated N_pairs_voiced N_pairs_incorrect])), 'HorizontalAlignment', 'Center');
    text(1.15, -10, sprintf('%.0f%%', N_pairs_incorrect * 100 / sum([N_pairs_correct N_pairs_aspirated N_pairs_voiced N_pairs_incorrect])), 'HorizontalAlignment', 'Center');
    text(1.30, -10, '-', 'HorizontalAlignment', 'Center');
    xlim([0.6 1.4])
    ylim([0 54])
    text(0.70, N_pairs_correct  , num2str(N_pairs_correct)  , 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'BackgroundColor', 'White', 'Margin', .1);
    text(0.85, N_pairs_aspirated, num2str(N_pairs_aspirated), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'BackgroundColor', 'White', 'Margin', .1);
    text(1.00, N_pairs_voiced   , num2str(N_pairs_voiced)   , 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'BackgroundColor', 'White', 'Margin', .1);
    text(1.15, N_pairs_incorrect, num2str(N_pairs_incorrect), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'BackgroundColor', 'White', 'Margin', .1);
    text(1.30, N_pairs_thrownout, num2str(N_pairs_thrownout), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'BackgroundColor', 'White', 'Margin', .1);
    
    subplot(2, 3, 4:6)
    bar([sum(B & C) / sum(B),  sum(B  & ~C) / sum(B);...
        sum(DY & C) / sum(DY), sum(DY & ~C) / sum(DY);...
        sum(DN & C) / sum(DN), sum(DN & ~C) / sum(DN)])
    ylabel('Fraction')
    set(gca,'XTickLabel',{'Baseline', 'Target Present', 'Not Present'})
%     set(gca,'XTickLabel',{sprintf('Baseline, %.0f%%', sum(B & C) / sum(B) * 100),...
%         sprintf('Target Present, %.0f%%', sum(DY & C) / sum(DY) * 100),...
%         sprintf('Not Present, %.0f%%', sum(DN & C) / sum(DN) * 100)})
%     text(1, -0.2, sprintf('%.0f%% (%d/%d)', sum(B  & C) / sum(B)  * 100, sum(B  & C), sum(B)), 'HorizontalAlignment', 'Center')
%     text(2, -0.2, sprintf('%.0f%% (%d/%d)', sum(DY & C) / sum(DY) * 100, sum(DY & C), sum(DY)), 'HorizontalAlignment', 'Center')
%     text(3, -0.2, sprintf('%.0f%% (%d/%d)', sum(DN & C) / sum(DN) * 100, sum(DN & C), sum(DN)), 'HorizontalAlignment', 'Center')
    text(1, -0.2, sprintf('%.0f%%', sum(B  & C) / sum(B)  * 100), 'HorizontalAlignment', 'Center')
    text(2, -0.2, sprintf('%.0f%%', sum(DY & C) / sum(DY) * 100), 'HorizontalAlignment', 'Center')
    text(3, -0.2, sprintf('%.0f%%', sum(DN & C) / sum(DN) * 100), 'HorizontalAlignment', 'Center')
    text(0.85, sum(B  &  C) / sum(B ), num2str(sum(B  &  C)), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'BackgroundColor', 'White', 'Margin', .1);
    text(1.15, sum(B  & ~C) / sum(B ), num2str(sum(B  & ~C)), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'BackgroundColor', 'White', 'Margin', .1);
    text(1.85, sum(DY &  C) / sum(DY), num2str(sum(DY &  C)), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'BackgroundColor', 'White', 'Margin', .1);
    text(2.15, sum(DY & ~C) / sum(DY), num2str(sum(DY & ~C)), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'BackgroundColor', 'White', 'Margin', .1);
    text(2.85, sum(DN &  C) / sum(DN), num2str(sum(DN &  C)), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'BackgroundColor', 'White', 'Margin', .1);
    text(3.15, sum(DN & ~C) / sum(DN), num2str(sum(DN & ~C)), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom', 'BackgroundColor', 'White', 'Margin', .1);
    text(2.38, 0.8, 'Distractors', 'HorizontalAlignment', 'Center')
    xlim([0.5 4.5])
    legend('Correct', 'Incorrect', 'Location', 'East')
    
    if(~exist([subject.meg.dir, '/images'], 'dir'));
        mkdir([subject.meg.dir, '/images']); end
    image_file = sprintf('%s/images/%s_accuracy.png',...
        subject.meg.dir, subject.name);
    saveas(6754010, image_file);
    
    % Set subject fields
    subject.meg.behav.N_trials = N_trials;
    subject.meg.behav.N_missed = N_missed;
    subject.meg.behav.trialdata = trialdata;
    
    % Record the process
    gpsa_parameter(state, subject);
    gpsa_log(state, toc(tbegin));
    
    % If this is the last subject, try to do the average behaviorals
     if(strcmp(state.subject, study.subjects{end}))
         state.subject = study.average_name;
         gpsa_meg_eveproc_AR1(state, 'c');
     end
    
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
