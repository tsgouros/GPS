function varargout = gpsa_meg_eveproc_PTC2(varargin)
% Processes events for behavioral figures and stimulus groups for PTC2
%
% Author: A. Conrad Nied
%
% Changelog:
% 2011.08    - Basis function GPS1.6(-)/meg_behaviorals_PTC2.m created
% 2012.08.28 - Last modification to in GPS1.6(-)/meg_eventproc_PTC2.m
% 2012.10.05 - Updated to GPS1.7 format
% 2013.04.24 - GPS1.8 Changed subset/subsubset to condition hierarchy

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
    state.function = 'gpsa_meg_eveproc_PTC2';
    tbegin = tic;
    
    if(~isfield(state, 'processlog'))
        state.processlog = 1;
    end
    
    fprintf(state.processlog, '%s: Processing events for %s\n', state.function, state.subject);
    
    trialdata = struct('trigger', NaN, 'block', '', 'sample', NaN,...
        'response_time', NaN, 'response', '', 'step', NaN, 'liquid', '',...
        'vowel', NaN, 'groupnum', NaN, 'groupname', '', 'i_trial', NaN,...
        'ID', NaN, 'subject', '');
    N_trials = 0;
    i_trial = 0;
    
    % Are we doing the average or individual subject?
    if(strcmp(state.subject, study.average_name))
        N_subjects = length(study.subjects);
        
        % Load and concatenate subjects
        for i_subject = 1:N_subjects
            asubject = gpsa_parameter(state, study.subjects{i_subject});
            
            subject_trialdata = asubject.meg.behav.trialdata;
            for j_trial = 1:length(subject_trialdata)
                subject_trialdata(j_trial).subject = study.subjects{i_subject};
            end
            
            trialdata = [trialdata subject_trialdata];
            N_trials = N_trials + asubject.meg.behav.N_trials;
        end % For each subject
        
        % Also if the subject is empty, make a default average subject
        if(isempty(subject))
            subject = data_defaultsubject(study.average_name, study);
        end
        
        trialdata(1) = [];
        
    else % Regular subject
        fprintf(state.processlog, '\tExtracting data from blocks and reassigning:\n\t\t');
        
        % For each block
        for i_block = 1:length(subject.blocks)
            block = subject.blocks{i_block};
            fprintf(state.processlog, ' %s', block);
            
            % Load Stimuli File
            stimuli_file = sprintf('%s/parameters/%s/%s_%s_stimuli.txt',...
                state.dir, study.name, study.name, block);
            stimuli = importdata(stimuli_file);
            stimuli = stimuli.data; % Column 1 is the side of the screen with the s and Column 3 is trigger code
            
            N_trials = N_trials + length(stimuli);
            
            % Load the events recorded by the machine
            event_file = sprintf('%s/triggers/%s_%s.eve',...
                subject.meg.dir, subject.name, block);
            events = load(event_file);
            events(:, 5) = events(:, 4);
            
            %% Parse Events
            % Find the start of every stimulus. Then look at the responses
            % following this trigger (and preceding the next one). Record all
            % trials
            
            stimuli_events = [find((events(:,4) > 0) & (events(:,4) <= 63))' size(events, 1)+1];
            
            if(length(stimuli_events) - 1 ~= length(stimuli))
                error('Incorrect amount of stimuli to events (probably a misrecord). Block: %s', block)
            end % If there are not enough events
            
            % For each stimulus
            for i_stimulus = 1:length(stimuli)
                set_start = stimuli_events(i_stimulus);
                set_stop  = stimuli_events(i_stimulus + 1) - 1;
                trial_set = events(set_start : set_stop, :);
                
                % Find their responses
                response_rows = find(~mod(trial_set(:, 4), 64));
                
                % Get stimulus parameters
                trigger_sent = stimuli(i_stimulus, 3);
                trigger_rcvd = trial_set(1, 4);
                sside = stimuli(i_stimulus, 1);
                sside = 128 - sside * 64; % Convert to 64/128 representations
                
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
                        response_time = response_rows(end);
                        
                        % Record the response time
                        time_start = trial_set(1, 2);
                        time_resp = trial_set(response_time, 2);
                        data.response_time = time_resp - time_start;
                        
                        % Find out if the response was an s or S
                        switch trial_set(response_time, 4) * 1000 + sside
                            case {128128, 64064}
                                data.response = 's';
                                groupnum = groupnum + 200;
                            case {128064, 64128}
                                data.response = 'S';
                                groupnum = groupnum + 300;
                            otherwise
                                groupnum = groupnum + 400;
                                data.response = '?';
                        end
                    else
                        groupnum = groupnum + 400;
                        data.response_time = 0;
                        data.response = 'n';
                    end % if they responded
                    
                    % Step
                    switch data.trigger
                        case {1, 6, 11, 16, 21, 26, 31, 33, 35}
                            data.step = 1;
                            groupnum = groupnum + 1;
                        case {2, 7, 12, 17, 22, 27}
                            data.step = 2;
                            groupnum = groupnum + 2;
                        case {3, 8, 13, 18, 23, 28}
                            data.step = 3;
                            groupnum = groupnum + 3;
                        case {4, 9, 14, 19, 24, 29}
                            data.step = 4;
                            groupnum = groupnum + 4;
                        case {5, 10, 15, 20, 25, 30, 32, 34, 36}
                            data.step = 5;
                            groupnum = groupnum + 5;
                        otherwise
                            data.step = 0;
                            if(groupnum < 400); groupnum = 400 + 1 + mod(groupnum, 100); end
                    end
                    
                    % Liquid
                    switch data.trigger
                        case {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
                            data.liquid = 'l';
%                             groupnum = groupnum + 0;
                        case {16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30}
                            data.liquid = 'r';
                            groupnum = groupnum + 15;
                        otherwise % inc. 31, 32, 33, 34, 35, 36
                            data.liquid = '_';
                            groupnum = groupnum + 30;
                    end
                    
                    % Vowel
                    switch data.trigger
                        case {1, 2, 3, 4, 5, 16, 17, 18, 19, 20, 31, 32}
                            data.vowel = 'i';
                            groupnum = groupnum + 0;
                        case {6, 7, 8, 9, 10, 21, 22, 23, 24, 25, 33, 34}
                            data.vowel = 'v';
                            groupnum = groupnum + 5;
                        case {11, 12, 13, 14, 15, 26, 27, 28, 29, 30, 35, 36}
                            data.vowel = 'e';
                            groupnum = groupnum + 10;
                        otherwise
                            data.vowel = '?';
                            if(groupnum < 400); groupnum = 400 + mod(groupnum, 100); end
                    end
                    
                    data.groupnum = groupnum;
                    data.groupname = sprintf('%d%s%s%s', data.step, data.liquid, data.vowel, data.response);
                    
                    % Unique event identifier
                    data.i_trial = i_trial;
                    data.ID = data.i_trial * 1000 + data.groupnum;
                    data.subject = subject.name;
                    
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
    
    ss = [trialdata.response] == 's';
    rs = [trialdata.liquid] == 'r';
    ls = [trialdata.liquid] == 'l';
    os = [trialdata.liquid] == '_';
    is = [trialdata.vowel] == 'i';
    es = [trialdata.vowel] == 'e';
    vs = [trialdata.vowel] == 'v';
    s1s = [trialdata.step] == 1;
    s2s = [trialdata.step] == 2;
    s3s = [trialdata.step] == 3;
    s4s = [trialdata.step] == 4;
    s5s = [trialdata.step] == 5;
    
    % Other prep: format subject name
    fsubjName = subject.name;
    loc = find(fsubjName=='_');
    if(~isempty(loc)) % If we found an underscore in the subject's name
        fsubjName = [fsubjName(1:loc-1) '\' fsubjName(loc:end)];
    end
    
    % Show each /s/-/sh/ continuum
    
    h = figure(1);
    clf(h)
    subplot(2,2,1);
    plot(1:5, [sum(s1s & ss & ls) / sum(s1s & ls)...
        sum(s2s & ss & ls) / sum(s2s & ls)...
        sum(s3s & ss & ls) / sum(s3s & ls)...
        sum(s4s & ss & ls) / sum(s4s & ls)...
        sum(s5s & ss & ls) / sum(s5s & ls)], 'b',...
        1:5, [sum(s1s & ss & rs) / sum(s1s & rs)...
        sum(s2s & ss & rs) / sum(s2s & rs)...
        sum(s3s & ss & rs) / sum(s3s & rs)...
        sum(s4s & ss & rs) / sum(s4s & rs)...
        sum(s5s & ss & rs) / sum(s5s & rs)], 'r',...
        [1 5], [sum(s1s & ss & os) / sum(s1s & os)...
        sum(s5s & ss & os) / sum(s5s & os)], 'g')
    title(['PTC2 /s/ IDs, vowels averaged, for ' fsubjName])
    ylabel('Fraction of /s/ Observations')
    legend('/sl/','/sr/','/s/','Location','Best');
    set(gca,'XTickLabel',{'s','.','.','.','sh'})
    axis([1 5 0 1])
    
    subplot(2,2,2);
    plot(1:5, [sum(s1s & ss & ls & is) / sum(s1s & ls & is)...
        sum(s2s & ss & ls & is) / sum(s2s & ls & is)...
        sum(s3s & ss & ls & is) / sum(s3s & ls & is)...
        sum(s4s & ss & ls & is) / sum(s4s & ls & is)...
        sum(s5s & ss & ls & is) / sum(s5s & ls & is)], 'b',...
        1:5, [sum(s1s & ss & rs & is) / sum(s1s & rs & is)...
        sum(s2s & ss & rs & is) / sum(s2s & rs & is)...
        sum(s3s & ss & rs & is) / sum(s3s & rs & is)...
        sum(s4s & ss & rs & is) / sum(s4s & rs & is)...
        sum(s5s & ss & rs & is) / sum(s5s & rs & is)], 'r',...
        [1 5], [sum(s1s & ss & os & is) / sum(s1s & os & is)...
        sum(s5s & ss & os & is) / sum(s5s & os & is)], 'g')
    title('Identifications with vowel /i/')
    legend('/sli/','/sri/','/si/','Location','Best');
    set(gca,'XTickLabel',{'s','.','.','.','sh'})
    axis([1 5 0 1])
    
    subplot(2,2,3);
    plot(1:5, [sum(s1s & ss & ls & vs) / sum(s1s & ls & vs)...
        sum(s2s & ss & ls & vs) / sum(s2s & ls & vs)...
        sum(s3s & ss & ls & vs) / sum(s3s & ls & vs)...
        sum(s4s & ss & ls & vs) / sum(s4s & ls & vs)...
        sum(s5s & ss & ls & vs) / sum(s5s & ls & vs)], 'b',...
        1:5, [sum(s1s & ss & rs & vs) / sum(s1s & rs & vs)...
        sum(s2s & ss & rs & vs) / sum(s2s & rs & vs)...
        sum(s3s & ss & rs & vs) / sum(s3s & rs & vs)...
        sum(s4s & ss & rs & vs) / sum(s4s & rs & vs)...
        sum(s5s & ss & rs & vs) / sum(s5s & rs & vs)], 'r',...
        [1 5], [sum(s1s & ss & os & vs) / sum(s1s & os & vs)...
        sum(s5s & ss & os & vs) / sum(s5s & os & vs)], 'g')
    title('Identifications with vowel /V/')
    xlabel('Step')
    ylabel('Fraction of /s/ Observations')
    legend('/slV/','/srV/','/sV/','Location','Best');
    set(gca,'XTickLabel',{'s','.','.','.','sh'})
    axis([1 5 0 1])
    
    subplot(2,2,4);
    plot(1:5, [sum(s1s & ss & ls & es) / sum(s1s & ls & es)...
        sum(s2s & ss & ls & es) / sum(s2s & ls & es)...
        sum(s3s & ss & ls & es) / sum(s3s & ls & es)...
        sum(s4s & ss & ls & es) / sum(s4s & ls & es)...
        sum(s5s & ss & ls & es) / sum(s5s & ls & es)], 'b',...
        1:5, [sum(s1s & ss & rs & es) / sum(s1s & rs & es)...
        sum(s2s & ss & rs & es) / sum(s2s & rs & es)...
        sum(s3s & ss & rs & es) / sum(s3s & rs & es)...
        sum(s4s & ss & rs & es) / sum(s4s & rs & es)...
        sum(s5s & ss & rs & es) / sum(s5s & rs & es)], 'r',...
        [1 5], [sum(s1s & ss & os & es) / sum(s1s & os & es)...
        sum(s5s & ss & os & es) / sum(s5s & os & es)], 'g')
    title('Identifications with vowel /e/')
    xlabel('Step')
    legend('/sle/','/sre/','/se/','Location','Best');
    set(gca,'XTickLabel',{'s','.','.','.','sh'})
    axis([1 5 0 1])
    
    image_file = sprintf('%s/behaviorals/%s_s_identifications.png',...
        subject.meg.dir, subject.name);
    saveas(h, image_file);
    
    %% Summary
    
    h = figure(3);
    clf(h)
    % plot(1:5, [sum(s1s & ss & ls) / sum(s1s & ls)...
    %     sum(s2s & ss & ls) / sum(s2s & ls)...
    %     sum(s3s & ss & ls) / sum(s3s & ls)...
    %     sum(s4s & ss & ls) / sum(s4s & ls)...
    %     sum(s5s & ss & ls) / sum(s5s & ls)], 'b',...
    %     1:5, [sum(s1s & ss & rs) / sum(s1s & rs)...
    %     sum(s2s & ss & rs) / sum(s2s & rs)...
    %     sum(s3s & ss & rs) / sum(s3s & rs)...
    %     sum(s4s & ss & rs) / sum(s4s & rs)...
    %     sum(s5s & ss & rs) / sum(s5s & rs)], 'r')
    plot(1:5, [sum(s1s & ss & ls) / sum(s1s & ls)...
        sum(s2s & ss & ls) / sum(s2s & ls)...
        sum(s3s & ss & ls) / sum(s3s & ls)...
        sum(s4s & ss & ls) / sum(s4s & ls)...
        sum(s5s & ss & ls) / sum(s5s & ls)], 'b',...
        'Marker', 'o', 'MarkerSize', 10);
    hold on
    plot(1:5, [sum(s1s & ss & rs) / sum(s1s & rs)...
        sum(s2s & ss & rs) / sum(s2s & rs)...
        sum(s3s & ss & rs) / sum(s3s & rs)...
        sum(s4s & ss & rs) / sum(s4s & rs)...
        sum(s5s & ss & rs) / sum(s5s & rs)], 'r',...
        'Marker', 'x', 'MarkerSize', 10);
    title(['PTC2 /s/ IDs, vowels averaged, for ' fsubjName])
    ylabel('Fraction of /s/ Observations')
    xlabel('Step')
    legend('/sl/','/sr/','Location','Best');
    set(gca,'XTickLabel',{'s','.','.','.','sh'})
    axis([1 5 0 1])
    
    image_file = sprintf('%s/behaviorals/%s_s_identifications_summary.png',...
        subject.meg.dir, subject.name);
    saveas(h, image_file);
    
    % Subject average with error bars
    
    % If we are studying the average subject
    if(strcmp(state.subject, study.average_name))
        trialdata_save = trialdata;
        subjectresults_l = zeros(N_subjects, 5);
        subjectresults_r = zeros(N_subjects, 5);
        
        % Load and concatenate subjects
        for i_subject = 1:N_subjects
            asubject = gpsa_parameter(state, study.subjects{i_subject});
            
            trialdata = asubject.meg.behav.trialdata;
            N_trials = N_trials + asubject.meg.behav.N_trials;
            
            ss = [trialdata.response] == 's';
            rs = [trialdata.liquid] == 'r';
            ls = [trialdata.liquid] == 'l';
            s1s = [trialdata.step] == 1;
            s2s = [trialdata.step] == 2;
            s3s = [trialdata.step] == 3;
            s4s = [trialdata.step] == 4;
            s5s = [trialdata.step] == 5;
            
            subjectresults_l(i_subject, :) = [sum(s1s & ss & ls) / sum(s1s & ls)...
                sum(s2s & ss & ls) / sum(s2s & ls)...
                sum(s3s & ss & ls) / sum(s3s & ls)...
                sum(s4s & ss & ls) / sum(s4s & ls)...
                sum(s5s & ss & ls) / sum(s5s & ls)];
            subjectresults_r(i_subject, :) = [sum(s1s & ss & rs) / sum(s1s & rs)...
                sum(s2s & ss & rs) / sum(s2s & rs)...
                sum(s3s & ss & rs) / sum(s3s & rs)...
                sum(s4s & ss & rs) / sum(s4s & rs)...
                sum(s5s & ss & rs) / sum(s5s & rs)];
        end % For each subject
        
        subjectresults_l = subjectresults_l * 100;
        subjectresults_r = subjectresults_r * 100;
        
        % Plot ls
        figure(4)
        clf
        set(gcf, 'Color', [1 1 1])
        hold on;
        errorbar((1:5), mean(subjectresults_l),...
            std(subjectresults_l)./sqrt(N_subjects), 'xk',...
            'LineStyle', '-',...
            'LineWidth', 2,...
            'MarkerSize', 10);
        errorbar(1:5, mean(subjectresults_r),...
            std(subjectresults_r)./sqrt(N_subjects), 'ok',...
            'LineStyle', '-.',...
            'LineWidth', 2,...
            'MarkerSize', 10);
        set(gca, 'FontSize', 16);
        title('Context')
        ylabel('Percent /s/ responses')
        xlabel('Step')
        legend('/-l/','/-r/','Location','Best');
        set(gca,'XTick', 1:5)
        set(gca,'XTickLabel',{'/s/','.','.','.','/S/'})
        axis([0.5 5.5 0 100])
%         xs = repmat((1:5), N_subjects, 1);
%         plot(xs(:),...
%             subjectresults_l(:),...
%             'LineStyle', 'none',...
%             'Marker', 'o',...
%             'MarkerEdgeColor', [0 .75 1]);
%         plot(xs(:),...
%             subjectresults_r(:),...
%             'LineStyle', 'none',...
%             'Marker', 'x',...
%             'MarkerEdgeColor', [1 .5 0]);
        
        trialdata = trialdata_save;
    end % Average graphs
    
    
    %% Response Times
    
    h = figure(2);
    hist([trialdata([trialdata.response] == 'S' | [trialdata.response] == 's').response_time]);
    
    image_file = sprintf('%s/behaviorals/%s_response_times.png',...
        subject.meg.dir, subject.name);
    saveas(h, image_file);
    
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