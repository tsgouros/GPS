function varargout = gpsa_meg_eveproc_CPLEX2(varargin)
% Generic program to process event files, ie making new event codes based
% on both stimuli and response accuracy.
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.06.18 - Created in GPS1.8, based on gpsa_meg_eveproc_AR1.m
% 2013.06.26 - Average subject now
% 2013.06.27

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
    state.function = 'gpsa_meg_eveproc';
    tbegin = tic;
    
    if(~isfield(state, 'processlog'))
        state.processlog = 1;
    end
    
    fprintf(state.processlog, '%s: Processing events for %s\n', state.function, state.subject);
    
    % Allocate the trialdata
    trialdata = struct('block', '', 'audio', '', 'image', '', ...
        'continuum', '', 'vowel', '', 'step', 0, 'bside', 0, ...
        'response', '', 'trigger', 0, 'group', 0, 'response_time', 0,...
        'sample', 0, 'time', 0, 'i_trial', 0, 'vinterval', 0);
    N_failures = 0;
    
    % Average subject or individual?
    if(strcmp(state.subject, study.average_name))
        
        % Load and concatenate subjects
        for i_subject = 1:length(study.subjects)
            asubject = gpsa_parameter(state, study.subjects{i_subject});
            
            atrialdata = asubject.meg.behav.trialdata;
            for i_trial = 1:length(atrialdata)
                atrialdata(i_trial).subject = study.subjects{i_subject};
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
            filename = sprintf('%s/%s/%s_%s_stimuli.txt', gps_presets('parameters'), study.name, study.name, block);
            fid = fopen(filename);
            blockdata = textscan(fid, '%[^\t]\t%c\t%c\t%d\t%d\t%d\t%[^\t\r\n]');
            fclose(fid);
            
            % Format of block data is a cell array of 3 entries, one for each
            % column.
            % blockdata{1} -> Audio file presented
            % blockdata{2} -> Left side character
            % blockdata{3} -> Right side character
            % blockdata{4} -> Side the b is on
            % blockdata{5} -> Variable ISI
            % blockdata{6} -> Trigger number
            % blockdata{7} -> Picture presented
            % IE:
            % BDAY5.wav	b	d	1	337	25	BDAY1.tiff
            
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
                        N_failures = N_failures + 1;
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
                    if blockdata{6}(i_trial) == audonset(4)
                        
                        %% Set up new auditory onset event
                        time = audonset(2);
                        sample = floor(time * fs);
                        trigger = audonset(4);
                        bside = blockdata{4}(i_trial);
                        respb = (bside == 1 && response(4) == 1) ||...
                            (bside == 0 && response(4) == 2);
                        
                        % Determine the step, vowel, and continuum
                        step = mod(trigger - 1, 5) + 1;
                        switch floor((trigger - 1) / 5)
                            case {0, 4}
                                vowel = 'e';
                            case {1}
                                vowel = 'i';
                            case {2, 6}
                                vowel = 'Q';
                            case {3, 7}
                                vowel = 'A';
                            case {5}
                                vowel = 'o';
                        end
                        if(trigger > 20)
                            group = 200 + step;
                            continuum = 'p';
                        else
                            group = 205 + step;
                            continuum = 'v';
                        end
                        if(respb)
                            respb = 'b';
                        else
                            respb = 'n';
                            group = group + 100;
                        end
                        
                        % Save event in new event data
                        i_event_grouped = i_event_grouped + 1;
                        evedata_grouped(i_event_grouped, :) = [sample time 0 group];
                        
                        %% Save data
                        % Trial word and phone
                        data.block    = block;
                        data.audio    = blockdata{1}{i_trial};
                        data.image    = blockdata{7}{i_trial};
                        data.continuum = continuum;
                        data.vowel    = vowel;
                        data.step     = step;
                        data.bside    = bside;
                        data.response = respb;
                        data.trigger  = trigger;
                        data.group    = group;
                        data.response_time = response(2) - audonset(2);
                        data.sample   = sample;
                        data.time     = time;
                        data.i_trial  = i_trial;
                        data.vinterval = blockdata{5}(i_trial);
                        
                        % Save to the trial data structure
                        if(trigger ~= 41)
                            trialdata(end + 1) = data; %#ok<AGROW>
                        end
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
                        fprintf(state.processlog, '\t Found the wrong trigger %d, expected %d\n', audonset(4), blockdata{6}(i_trial));
                        N_failures = N_failures + 1;
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
    vi = [trialdata.vowel]     == 'i';
    ve = [trialdata.vowel]     == 'e';
    vA = [trialdata.vowel]     == 'A';
    vQ = [trialdata.vowel]     == 'Q';
    vo = [trialdata.vowel]     == 'o';
    s1 = [trialdata.step]      == 1;
    s2 = [trialdata.step]      == 2;
    s3 = [trialdata.step]      == 3;
    s4 = [trialdata.step]      == 4;
    s5 = [trialdata.step]      == 5;
    cp = [trialdata.continuum] == 'p';
    cv = [trialdata.continuum] == 'v';
    rb = [trialdata.response]  == 'b';
    rn = [trialdata.response]  == 'n';
    re = rb | rn;
    
    % Other prep: format subject name
    fsubjName = state.subject;
    loc = find(fsubjName=='_');
    if(~isempty(loc)) % If we found an underscore in the subject's name
        fsubjName = [fsubjName(1:loc-1) '\' fsubjName(loc:end)];
    end
    
    % Initialize the figure
    figure(6754010)
    clf(6754010)
    
    % Show /b/-/!b/ continuum
    subplot(2,2,1);
    plot(sum([s1; s2; s3; s4; s5] & repmat(rb, 5, 1), 2) ./...
         sum([s1; s2; s3; s4; s5] & repmat(re, 5, 1), 2),...
        'Color', [0 0.75 0.75])
    title([fsubjName ' average /b/ IDs'])
    xlabel('Step')
    ylabel('Fraction of /b/ Observations')
    set(gca,'XTick',1:5)
    set(gca,'XTickLabel',{'b','.','.','.','!b'})
    legend('b','Location','Best');
    axis([1 5 0 1])
    
    % Show /b/-/d/ and /b/-/p/ continua

    subplot(2,2,2);
    plot(sum([s1; s2; s3; s4; s5] & repmat(rb & cv, 5, 1), 2) ./...
         sum([s1; s2; s3; s4; s5] & repmat(re & cv, 5, 1), 2),...
        'g')
    hold on
    plot(sum([s1; s2; s3; s4; s5] & repmat(rb & cp, 5, 1), 2) ./...
         sum([s1; s2; s3; s4; s5] & repmat(re & cp, 5, 1), 2),...
        'b')
    title([fsubjName ' /b/ IDs per continua'])
    xlabel('Step')
    ylabel('Fraction of /b/ Observations')
    set(gca,'XTick',1:5)
    set(gca,'XTickLabel',{'b','.','.','.','!b'})
    legend('b !p','b !d','Location','Best');
    axis([1 5 0 1])
    
    % Show /b/-/p/ continuum for based on vowel

    subplot(2,2,3);
    plot(sum([s1; s2; s3; s4; s5] & repmat(rb & cv & vi, 5, 1), 2) ./...
         sum([s1; s2; s3; s4; s5] & repmat(re & cv & vi, 5, 1), 2),...
        'Color', [.75 .75 0])
    hold on
    plot(sum([s1; s2; s3; s4; s5] & repmat(rb & cv & ve, 5, 1), 2) ./...
         sum([s1; s2; s3; s4; s5] & repmat(re & cv & ve, 5, 1), 2),...
        'Color', [1 .5 0])
    plot(sum([s1; s2; s3; s4; s5] & repmat(rb & cv & vA, 5, 1), 2) ./...
         sum([s1; s2; s3; s4; s5] & repmat(re & cv & vA, 5, 1), 2),...
        'Color', [1 0 0])
    plot(sum([s1; s2; s3; s4; s5] & repmat(rb & cv & vQ, 5, 1), 2) ./...
         sum([s1; s2; s3; s4; s5] & repmat(re & cv & vQ, 5, 1), 2),...
        'Color', [1 0 .5])
    title([fsubjName ' vowel /b/ IDs on b-p'])
    xlabel('Step')
    ylabel('Fraction of /b/ Observations')
    set(gca,'XTick', 1:5)
    set(gca,'XTickLabel', {'b','.','.','.','p'})
    legend('bi','be','bAt','bQk','Location','Best');
    axis([1 5 0 1])

    % Show /b/-/d/ continuum for based on vowel

    subplot(2,2,4);
    plot(sum([s1; s2; s3; s4; s5] & repmat(rb & cp & ve, 5, 1), 2) ./...
         sum([s1; s2; s3; s4; s5] & repmat(re & cp & ve, 5, 1), 2),...
        'Color', [1 .5 0])
    hold on
    plot(sum([s1; s2; s3; s4; s5] & repmat(rb & cp & vA, 5, 1), 2) ./...
         sum([s1; s2; s3; s4; s5] & repmat(re & cp & vA, 5, 1), 2),...
        'Color', [1 0 0])
    plot(sum([s1; s2; s3; s4; s5] & repmat(rb & cp & vQ, 5, 1), 2) ./...
         sum([s1; s2; s3; s4; s5] & repmat(re & cp & vQ, 5, 1), 2),...
        'Color', [1 0 .5])
    plot(sum([s1; s2; s3; s4; s5] & repmat(rb & cp & vo, 5, 1), 2) ./...
         sum([s1; s2; s3; s4; s5] & repmat(re & cp & vo, 5, 1), 2),...
        'Color', [1 0 1])
    title([fsubjName ' vowel /b/ IDs on b-d'])
    xlabel('Step')
    ylabel('Fraction of /b/ Observations')
    set(gca,'XTick', 1:5)
    set(gca,'XTickLabel',{'b','.','.','.','d'})
    legend('be','bAS','bQk','bo','Location','Best');
    axis([1 5 0 1])
    
    % Save
    if(strcmp(state.subject, study.average_name))
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
    saveas(6754010, image_file);
    
    %% Clean up
    
    fprintf('N_failures = %d\n', N_failures);
    
    % Save
    if(strcmp(state.subject, study.average_name))
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
    if(strcmp(study.subjects{end}, state.subject))
        state.subject = study.average_name;
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