function varargout = gpsa_meg_eveproc_ARTX1(varargin)
% Generic program to process event files, ie making new event codes based
% on both stimuli and response accuracy.
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.06.18 - Created in GPS1.8, based on gpsa_meg_eveproc_AR1.m

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
    trialdata = struct('audio', '', 'image', '', 'foil', '', 'correct', 0,...
        'sample', 0, 'time', 0, 'trigger', 0, 'entrynum', 0, 'ID', '',...
        'category', '', 'group', 0, 'i_trial', 0,...
        'block', '');
    
    % Read in the subject's performance and the block commands
    for i_block = 1:length(subject.blocks)
        block = subject.blocks{i_block};
        
        % Load in the block data
        filename = sprintf('%s/%s/%s_%s.txt', gps_presets('studyparameters'), study.name, study.name, block);
        fid = fopen(filename);
        blockdata = textscan(fid, '%[^\t]\t%[^\t]\t%[^\t]\t%[^\t\n\r]');
        fclose(fid);
        
        % Format of block data is a cell array of 3 entries, one for each
        % column.
        % blockdata{1} -> Image presented
        % blockdata{2} -> Audio presented
        % blockdata{3} -> Designation
        % blockdata{4} -> Category
        
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
                fprintf(state.processlog, '% 5d Saw initialization trigger 0 at beginning.\n', i_event);
                
                % Ignore all trigger releases
            elseif event(3) > event (4)
                fprintf(state.processlog, '% 5d Trigger release %d to %d, ignoring.\n', i_event, event(3), event (4));
                
                % Found a button press
            elseif mod(event(4), 256) == 0
                response = [event(1:3) log(event(4)) / log(2) - 7];
                if(response(4) <= 0); response(4) = response(4) + 2; end
                fprintf(state.processlog, '% 5d Found a button press %d\n', i_event, response(4));
                
                % Found a trigger that wasn't a button press -> probably an
                % auditory stimuli onset
            elseif mod(event(4), 256) > 0
                % If we have an old trigger waiting for a matched response,
                % the trial was probably skipped so just mark that
                if ~isempty(audonset)
                    i_trial = i_trial + 1;
                    fprintf(state.processlog, '\tDidn''t find a response for trial %d, trigger %d\n', i_trial, audonset(4));
                end
                
                % Mark the event as a trigger for an audio onset
                audonset = [event(1:3) mod(event(4), 256)];
                response = [];
                fprintf(state.processlog, '% 5d Found an auditory event trigger %d\n', i_event, audonset(4));
            end
            
            % Tell the program loop it can move on to the next event
            %   (after it checks matched triggers)
            i_event = i_event + 1;
            
            % See if triggers are matched - a stimulus trigger was followed
            % by a response
            if ~isempty(audonset) && ~isempty(response)
                i_trial = i_trial + 1;
                
                designation = blockdata{3}{i_trial};
                if(strcmp(designation(1:2), 'PI'))
                    foil = 'I';
                    trigger = 0 + str2double(designation(3:end));
                    entrynum = str2double(designation(3:end));
                elseif(strcmp(designation(1:2), 'PM'))
                    foil = 'V';
                    trigger = 32 + str2double(designation(3:end));
                    entrynum = str2double(designation(3:end));
                elseif(strcmp(designation(1:2), 'PF'))
                    foil = 'F';
                    trigger = 64 + str2double(designation(3:end));
                    entrynum = str2double(designation(3:end));
                elseif(strcmp(designation(1), 'S'))
                    foil = 'S';
                    trigger = 96 + str2double(designation(2:end));
                    entrynum = str2double(designation(2:end));
                elseif(strcmp(designation(1), 'M'))
                    foil = 'M';
                    trigger = 128 + str2double(designation(2:end));
                    entrynum = str2double(designation(2:end));
                end
                
                category = blockdata{4}{i_trial};
                switch category
                    case 'vegetable'
                        catnum = 1;
                    case 'furniture'
                        catnum = 2;
                    case 'bird'
                        catnum = 3;
                    case 'transportation'
                        catnum = 4;
                    case 'clothing'
                        catnum = 5;
                    case 'fruit'
                        catnum = 6;
                end
                
                % Verify that the trial code matches the expected one
                if trigger == audonset(4)
                    
                    %% Set up new auditory onset event
                    time = audonset(2);
                    sample = floor(time * fs);
                    trigger = audonset(4);
                    correct = trigger <  128 && response(4) == 1 ||...
                              trigger >= 128 && response(4) == 2;
                    
                    % Determine the group
                    switch foil
                        case 'I' % Phonetic initial picture mismatch
                            if correct; group = 201 + 6*(catnum-1); else group = 301 + 6*(catnum-1); end
                        case 'V' % Phonetic vowel  picture mismatch
                            if correct; group = 202 + 6*(catnum-1); else group = 302 + 6*(catnum-1); end
                        case 'F' % Phonetic final picture mismatch
                            if correct; group = 203 + 6*(catnum-1); else group = 303 + 6*(catnum-1); end
                        case 'S' % Semantic picture mismatch
                            if correct; group = 204 + 6*(catnum-1); else group = 304 + 6*(catnum-1); end
                        case 'M' % Real word-picture matches
                            if correct; group = 205 + 6*(catnum-1); else group = 305 + 6*(catnum-1); end
                    end
                    
                    % Save event in new event data
                    i_event_grouped = i_event_grouped + 1;
                    evedata_grouped(i_event_grouped, :) = [sample time 0 group];
                    
                    %% Save data
                    % Trial word and phone
                    data.audio    = blockdata{2}{i_trial};
                    data.image    = blockdata{1}{i_trial};
                    data.foil     = foil;
                    data.correct  = correct;
                    data.sample   = sample;
                    data.time     = time;
                    data.trigger  = trigger;
                    data.entrynum = entrynum;
                    data.ID       = designation;
                    data.category = category;
                    data.group    = group;
                    data.i_trial  = i_trial;
                    data.block    = block;
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
                    fprintf(state.processlog, '\t Found the wrong trigger %d, expected %d\n', audonset(4), trigger);
                end
                
            end % if we have a new trigger & response
        end % For each event
        
        evedata_grouped(i_event_grouped + 1 : end, :) = [];
        
        %% Write grouped event files
        filename = [gps_filename('meg_events_grouped_block', subject, ['block=' block]) '.new'];
        fid = fopen(filename, 'w');
        
        for i_event = 1:size(evedata_grouped, 1)
            fprintf(fid, '%6d%- 8.3f %6d %3d\n',...
                evedata_grouped(i_event, 1), evedata_grouped(i_event, 2), evedata_grouped(i_event, 3), evedata_grouped(i_event, 4));
        end % For Each event
        
        fclose(fid);
    end % For each block
    
    %% Save Trialdata
    
    N_trials_expected = 200;
    N_missed = N_trials_expected - length(trialdata);
    
    fprintf(state.processlog, '\tProduce figures\n');
    
    %% Figures
    
    FO = [trialdata.foil] == 'I';
    FV = [trialdata.foil] == 'V';
    FC = [trialdata.foil] == 'F';
    FS = [trialdata.foil] == 'S';
    FM = [trialdata.foil] == 'M';
    C = [trialdata.correct] == 1;
    
    % Other prep: format subject name
    fsubjName = subject.name;
    loc = find(fsubjName=='_');
    if(~isempty(loc)) % If we found an underscore in the subject's name
        fsubjName = [fsubjName(1:loc-1) '\' fsubjName(loc:end)];
    end
    
    % Show subgroup accuracy
    figure(6754010)
    clf(6754010)
    bar(([sum(FO & C) / sum(FO),...
        sum(FV & C) / sum(FV),...
        sum(FC & C) / sum(FC),...
        sum(FS & C) / sum(FS),...
        sum(FM & C) / sum(FM);...
        0, 0, 0, 0, 0])) % To provide for colors
    title([study.name ' Accuracy by Type of Stimulus, for ' fsubjName])
    ylabel('Fraction of Correct Observations')
    set(gca,'XTick',[0.70 0.85 1.00 1.15 1.30])
    set(gca,'XTickLabel',{'Initial', 'Vowel', 'Final', 'Semantic', 'Match'})
    text(1.15, -0.08, '<- Foils', 'HorizontalAlignment', 'Center')
    axis([0.55 1.45 0 1])
    
    megimdir = gps_filename(study, subject, 'meg_images_dir');
    if(~exist(megimdir, 'dir'))
        mkdir(megimdir);
    end
    image_file = sprintf('%s/%s_accuracy.png',...
        megimdir, subject.name);
    saveas(6754010, image_file);
    
    %% Clean up
    
    % Set other variables
    subject.meg.behav.N_trials = N_trials_expected;
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
