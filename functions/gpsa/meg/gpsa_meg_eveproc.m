function varargout = gpsa_meg_eveproc(varargin)
% Generic program to process event files, ie making new event codes based
% on both stimuli and response accuracy.
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.06.18 - Created in GPS1.8, based on gpsa_meg_eveproc_AR1.m
% 2013.06.26 - Average subject now
% 2013.07.10 - Average subject is now condition.cortex.brain

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 0; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    study = gpsa_parameter(state, state.study);
    condition = gpsa_parameter(state, state.condition);
    state.function = 'gpsa_meg_eveproc';
    tbegin = tic;
    
    if(~isfield(state, 'processlog'))
        state.processlog = 1;
    end
    
    fprintf(state.processlog, '%s: Processing events for %s\n', state.function, state.subject);
    
    % Allocate the trialdata
    trialdata = struct('audio', '', 'image', '', 'foil', '', 'correct', 0,...
        'sample', 0, 'time', 0, 'trigger', 0, 'group', 0, 'i_trial', 0,...
        'block', '', 'response_time', 0);
    
    % Average subject or individual?
    if(strcmp(state.subject, condition.cortex.brain) && length(condition.subjects) > 1) % Has problem if single subject
        
        % Load and concatenate subjects
        for i_subject = 1:length(condition.subjects)
            asubject = gpsa_parameter(state, condition.subjects{i_subject});
            
            atrialdata = asubject.meg.behav.trialdata;
            for i_trial = 1:length(atrialdata)
                atrialdata(i_trial).subject = condition.subjects{i_subject};
            end
            
            if(i_subject == 1)
                trialdata = atrialdata;
                N_trials_expected = asubject.meg.behav.N_trials;
            else
                trialdata = [trialdata atrialdata]; %#ok<AGROW>
                N_trials_expected = N_trials_expected + asubject.meg.behav.N_trials;
            end
        end % For each subject
        
    else % Individual subject
        subject = gpsa_parameter(state.subject);
        
        % Read in the subject's performance and the block commands
        for i_block = 1:length(subject.blocks)
            block = subject.blocks{i_block};
            
            % Load in the block data
            filename = sprintf('%s/%s/%s.csv', gps_presets('parameters'), study.name, block);
            if(~exist(filename, 'file'))
                filename = sprintf('%s/GPS/%s.csv', gps_presets('parameters'), block);
            end
            fid = fopen(filename);
            blockdata = textscan(fid, '%[^,],%[^,],%c,%d');
            fclose(fid);
            
            % Format of block data is a cell array of 3 entries, one for each
            % column.
            % blockdata{1} -> Audio presented
            % blockdata{2} -> Picture presented
            % blockdata{3} -> Trigger sent to MEG machine
            
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
                    fprintf(state.processlog, '%s% 5d Saw initialization trigger 0 at beginning.\n', block, i_event);
                    
                    % Ignore all trigger releases
                elseif event(3) > event (4)
                    fprintf(state.processlog, '%s% 5d Trigger release %d to %d, ignoring.\n', block, i_event, event(3), event (4));
                    
                    % Found a button press
                elseif mod(event(4), 64) == 0
                    response = [event(1:3) log(event(4)) / log(2) - 7];
                    if(response(4) <= 0); response(4) = response(4) + 2; end
                    fprintf(state.processlog, '%s% 5d Found a button press %d\n', block, i_event, response(4));
                    
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
                    fprintf(state.processlog, '%s% 5d Found an auditory event trigger %d\n', block, i_event, audonset(4));
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
                        correct = (trigger == 4 && response(4) == 1) ||...
                            (trigger ~= 4 && response(4) == 2);
                        
                        % Determine the group
                        switch trigger
                            case {1, 2} % Phonetic picture mismatch
                                if correct; group = 201; else group = 301; end
                            case 3 % Semantic picture mismatch
                                if correct; group = 202; else group = 302; end
                            case 4 % Real word-picture matches
                                if correct; group = 203; else group = 303; end
                        end
                        if(sum(subject.name == 'b'))
                            group = group + 200;
                        end
                        
                        % Save event in new event data
                        i_event_grouped = i_event_grouped + 1;
                        evedata_grouped(i_event_grouped, :) = [sample time 0 group];
                        
                        %% Save data
                        % Trial word and phone
                        data.audio    = blockdata{1}{i_trial};
                        data.image    = blockdata{2}{i_trial};
                        data.foil     = blockdata{3}(i_trial);
                        if(data.foil == 'O'); data.foil = 'I'; end
                        if(data.foil == 'C'); data.foil = 'F'; end
                        data.correct  = correct;
                        data.sample   = sample;
                        data.time     = time;
                        data.trigger  = trigger;
                        data.group    = group;
                        data.i_trial  = i_trial;
                        data.block    = block;
                        data.response_time = response(2) - audonset(2);
                        
                        % Save to the trial data structure
                        trialdata(end + 1) = data; %#ok<AGROW>
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
                        fprintf(state.processlog, '\t Found the wrong trigger %d, expected %d\n', audonset(4), blockdata{4}(i_trial));
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
        
        N_trials_expected = 200;
        trialdata(1) = [];
        
    end % Average or regular subject?
    
    %% Save Trialdata
    
    N_missed = N_trials_expected - length(trialdata);
    
    fprintf(state.processlog, '\tProduce figures\n');
    
    %% Figures
    
    FI = [trialdata.foil] == 'I';
    FV = [trialdata.foil] == 'V';
    FF = [trialdata.foil] == 'F';
    FS = [trialdata.foil] == 'S';
    FM = [trialdata.foil] == 'M';
    C = [trialdata.correct] == 1;
    
    % Other prep: format subject name
    fsubjName = state.subject;
    loc = find(fsubjName=='_');
    if(~isempty(loc)) % If we found an underscore in the subject's name
        fsubjName = [fsubjName(1:loc-1) '\' fsubjName(loc:end)];
    end
    
    % Show subgroup accuracy
    figure(6754010)
    clf(6754010)
    bar(([sum(FI & C) / sum(FI),...
        sum(FV & C) / sum(FV),...
        sum(FF & C) / sum(FF),...
        sum(FS & C) / sum(FS),...
        sum(FM & C) / sum(FM);...
        0, 0, 0, 0, 0])) % To provide for colors
    title([study.name ' Accuracy by Type of Stimulus, for ' fsubjName])
    ylabel('Fraction of Correct Observations')
    set(gca,'XTick',[0.70 0.85 1.00 1.15 1.30])
    set(gca,'XTickLabel',{'Initial', 'Vowel', 'Final', 'Semantic', 'Match'})
    text(1.15, -0.08, '<- Foils', 'HorizontalAlignment', 'Center')
    axis([0.55 1.45 0 1])
    
    if(strcmp(state.subject, condition.cortex.brain))
        imdir = sprintf('%s/Images', study.basedir);
        if(~exist(imdir, 'dir'))
            mkdir(imdir);
        end
        image_file = sprintf('%s/gps_meg_behaviorals_%s_accuracy.png',...
            imdir, state.subject);
    else
        megimdir = gps_filename(study, subject, 'meg_images_dir');
        if(~exist(megimdir, 'dir'))
            mkdir(megimdir);
        end
        image_file = sprintf('%s/%s_accuracy.png',...
            megimdir, subject.name);
    end
    frame = getframe(6754010);
    %     saveas(6754010, image_file);
    imwrite(frame.cdata, image_file, 'png');
    
    %% Clean up
    
    % Save
    if(strcmp(state.subject, condition.cortex.brain))
        filename = sprintf('%s/%s/%s_behaviorals.csv', gps_presets('parameters'), study.name, study.name);
        
        struct2csv(trialdata, filename);
    else % Subject data to subject trialdata structure
        % Set other variables
        subject.meg.behav.N_trials = N_trials_expected;
        subject.meg.behav.N_missed = N_missed;
        subject.meg.behav.trialdata = trialdata;
        
        gpsa_parameter(state, subject);
    end
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
    % Do the average behaviorals if this is the last subject
    if(strcmp(study.subjects{end}, state.subject) && ~strcmp(state.subject, condition.cortex.brain) && length(condition.subjects) > 1)
        state.subject = condition.cortex.brain;
        gpsa_meg_eveproc(state);
    end
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state.subject);
    
    report.ready = min(length(dir(gps_filename(subject, 'meg_events_gen'))) / length(subject.blocks), 1);
    report.progress = min(length(dir(gps_filename(subject, 'meg_events_grouped_gen'))) / length(subject.blocks), 1);
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var'));
    varargout{1} = report;
end

end % function