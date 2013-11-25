function varargout = gpsa_meg_eveproc_MPS1(varargin)
% Processes events for behavioral figures and stimulus groups for AR1
%
% Author: Reid Vancelette
%
% Changelog:
% 03.04.2013 - Created from GPS1.7/gpsa_meg_eveproc_MPS1
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
    state.function = 'gpsa_meg_eveproc_MPS1';
    tbegin = tic;
    
    responses_blocktype = zeros(8, 8, 4);
    responses = zeros(8,2);
    trialdata = struct('Sent_Num',[],'Sent_Let',[],'RT', [],'Ext_Type',[],'Plaus',[],'Response',[],'Reversibility', []);
    
    %Load determiner information for NP's
    determiner_file = sprintf('data/%s/Determiner length.csv',...
        study.name); %this function declares the Determiner length.csv file
    [sentence_type, determiner_one, determiner_two] = textread(determiner_file,'%s %f %f');
    
    %Load last noun (object of the main clause) information
    
    end_noun = sprintf('data/%s/Last Noun.csv',...
        study.name); %this function declares the Last Noun.csv file
    [~, last_noun] = textread(end_noun, '%s %f');
    
    % Load Each event file and remove errors
    
    for i_block = 1:length(subject.blocks)
        block = subject.blocks{i_block};
        
        % Load Stimuli from the file
        stimuli_file = sprintf('data/%s/%s_%s_stimuli.txt',...
            study.name, study.name, block); %the function sprintf prints out variables into a string
        [wavfile, plausibility] = textread(stimuli_file,'%s %d %*f %*f %*f %*f %*f %*f');
        
        % Load events observed file
        events = load([subject.meg.dir '/triggers/' subject.name '_' block '.eve']);
        events_new = events(1, :);
        events_condition = events(1, :);
        
        
        %In this section, we are going to partition the data into groups of
        %correct and incorrect responses and futhermore into responses for
        %plausiblity, implausibility, subject extracted relative clauses, and
        %object extracted relative clauses.
        Trialstarts = [find(mod(events (:,4),6) ==1)' length(events)+1];
        
        for i = 1:40
            j = Trialstarts(i);
            j2 = Trialstarts(i+1);
            set = events(j:(j2-1),:);
            
            resps = ~mod(set(:,4),64); %this is assigning a variable to resps that contains a particular binary code (1 = 128 or 64) to identify where the responses are located within the data.
            
            %the following code will apply for responses that contain one
            %response and do not have the throw out code "49"
            
            name = wavfile{i};
            letter = name(end - 4);
            sentence_group = name (1:end-4);
            sentence_number = str2double(name(1:end-5));
            
            row = letter - 96; %row corresponds to the 8 different sentence types
            responses_blocktype(i_block, row, 4) = responses_blocktype(i_block, row, 4) + 1;
            
            if(sum(resps) >= 1)
                responses_blocktype(i_block, row, 3) = responses_blocktype(i_block, row, 3) + 1;
            end
            
            % Preallocates a cell to store names of applicable conditions
            conditions = cell(0, 1);
            
            if (sum(resps) == 1 && set(1, 4) ~= 49)
                %            fprintf('One Response!\n')
                plaus = 64 + 64 * plausibility(i);
                
                %the following code will apply for responses that are correct
                
                if (plaus == set(resps, 4))
                    %                 fprintf('Correct Response! row: %d, plaus: %d\n', row, plaus)
                    responses(row, 1) = responses(row, 1) + 1;
                    responses_blocktype(i_block, row, 1) = responses_blocktype(i_block, row, 1) + 1;
                    
                    % Rewrite stimulus trigger in eve file according to conditions
                    if(isfield(handles.flags, 'applyconditions') && handles.flags.applyconditions == 1)
                        
                        %% This will give a specific number to reversible and irreversible sentences
                        
                        set_new = zeros(0, 4);
                        % For each event in the set
                        for i_set = length(set):-1:1 % Work backwards since we will be changing indexing
                            event = set(i_set, :);
                            trig_num = event(4);
                            
                            % For each condition
                            for i_condition = 1:study.N_conditions
                                condition = data_load(handles,study.conditions{i_condition});
                                
                                event_codes = condition.meg.triggers;
                                
                                if (sum(trig_num == event_codes)) %
                                    %                                 events(j + i_set - 1, 4) = 200 + i_condition;
                                    if i_condition > 12 %This is going to assign the code number for the main clause verb and main clause object noun.
                                        if sentence_number >= 21
                                            event(4) = 202 + i_condition;
                                        else
                                            event(4) = 200 + i_condition;
                                        end
                                    else
                                        
                                        if sentence_number >= 21 %assigning code for reversible sentences
                                            event(4) = 206 + i_condition;
                                        else
                                            event(4) = 200 + i_condition; %assigning code for irreversible sentences
                                        end
                                    end
                                    break;
                                end
                                
                            end % For each condition
                            
                            
                            
                            % Correct for determiners
                            switch trig_num
                                
                                case {1, 25, 7, 31}
                                    time = events(j +i_set -1, 2);
                                    sample_number = events(j+i_set -1, 1);
                                    find_determiner = find (strcmp(sentence_group,sentence_type));
                                    determiner_length = determiner_one(find_determiner);
                                    time_new = determiner_length + time;
                                    sample_number_new = sample_number + round(determiner_length * 1209.833496093750);
                                    %                                 events(j+i_set -1, 2) = time_new;
                                    %                                 events(j+i_set -1, 1) = sample_number_new;
                                    
                                    event_new = [sample_number_new time_new 0 event(4)]; % event_new = the Noun and event(4) is the determiner.
                                    event(4) = event(4) + 1000;
                                    
                                    set_new = [event; event_new; set_new];
                                    
                                case {4, 28, 9, 33}
                                    time = events(j +i_set -1, 2);
                                    sample_number = events(j+i_set -1, 1);
                                    find_determiner = find (strcmp(sentence_group,sentence_type));
                                    determiner_length = determiner_two(find_determiner);
                                    time_new = determiner_length + time;
                                    sample_number_new = sample_number + round(determiner_length * 1209.833496093750);
                                    %                                 events(j+i_set -1, 2) = time_new;
                                    %                                 events(j+i_set -1, 1) = sample_number_new;
                                    
                                    event_new = [sample_number_new time_new 0 event(4)];
                                    event(4) = event(4) + 1000;
                                    
                                    set_new = [event; event_new; set_new];
                                    
                                case {5, 11, 29, 35}
                                    time = event(2);
                                    sample_number = event( 1);
                                    find_lastnoun = find (strcmp(sentence_group,sentence_type));
                                    lastnoun_length = last_noun(find_lastnoun);
                                    time_new = lastnoun_length + time;
                                    sample_number_new = sample_number + round(lastnoun_length * 1209.833496093750);
                                    %                                 events(j+i_set -1, 2) = time_new;
                                    %                                 events(j+i_set -1, 1) = sample_number_new;
                                    
                                    event_new = [sample_number_new time_new 0 event(4) + 4]; % event_new = the main clause object noun
                                    
                                    set_new = [event; event_new; set_new];
                                    
                                otherwise
                                    set_new = [event; set_new];
                            end % Switched based on determiners
                            
                        end % for each event in the set
                        events_condition = [events_condition; set_new];
                    end % If applying conditions
                    
                    %incorrect responses
                    
                else
                    %                 fprintf('Incorrect Response! row: %d, plaus: %d\n', row, plaus)
                    responses(row, 2) = responses(row, 2) + 1;
                    responses_blocktype(i_block, row, 2) = responses_blocktype(i_block, row, 2) + 1;
                    %                 events_new = [events_new; set];
                    events_condition = [events_condition; set];
                end
                
                % Record Response Time
                %response_time = set(resps, 2) - set(1, 2); % From begining
                
                if(sum(mod(set(:, 4), 6) == 0) > 0) %If the end of the sentence exists, then...
                    AA = find(mod(set(:, 4), 6) == 0);
                    if(length(AA) >= 2)
                        fprintf('End Trigger Mismatch. Block: %s, Set #: %d, Set:', block, j);
                        set
                        return
                    end
                    
                    response_time = set(resps, 2) - set(find(mod(set(:, 4), 6) == 0), 2); % From End
                    
                end
                
                ntrialdata=length(trialdata);
                trialdata(ntrialdata+1).Sent_Num = str2double(sentence_group(1:end-1));
                trialdata(ntrialdata+1).Sent_Let = row;
                trialdata(ntrialdata+1).RT = response_time;
                trialdata(ntrialdata+1).Ext_Type = 1-mod(row,2); % 0 = SS; 1 =SO
                trialdata(ntrialdata+1).Plaus = (plaus == 64); % 0 = Implausible; 1 = Plausible
                trialdata(ntrialdata+1).Response = (plaus == set(resps, 4)); % 0 = Incorrect; 1 = Correct
                trialdata(ntrialdata+1).Reversibility = (str2double(sentence_group(1:end-1))>= 20); % 0 = Irreversible; 1 = Reversible
                trialdata(ntrialdata+1).block = block;
                trialdata(ntrialdata+1).conditions = conditions;
                letters = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'};
                trialdata(ntrialdata+1).stimulus = sprintf('%2d%s',...
                    trialdata(ntrialdata+1).Sent_Num, letters{row});
                trialdata(ntrialdata+1).sample = s
                
            else % If we threw out the trial include the events to just have them
                %             events_new = [events_new; set];
                events_condition = [events_condition; set];
            end % if they responded once and we are using this trial
            
        end % for each trial
        
        
        % Write file with the applied conditions (if asked for)
        if(isfield(handles.flags,'applyconditions') && handles.flags.applyconditions)trialdata(1) = []; %erases the first element in our matrix
            
            file_out = sprintf('%s/triggers/%s_%s_grand.eve',...
                subject.meg.dir, subject.name, block);
            fid = fopen(file_out, 'w');
            
            for i = 1:size(events_condition, 1)
                %             fprintf('%6d %3.3f %6d %3d\n',...
                %                 events_new(i, 1), events_new(i, 2), events_new(i, 3), events_new(i, 4));
                fprintf(fid, '%6d %3.3f %6d %3d\n',...
                    events_condition(i, 1), events_condition(i, 2), events_condition(i, 3), events_condition(i, 4));
            end % For Each event
            
            fclose(fid);
            
        end % If applying conditions
    end % For each block
    
    trialdata(1) = []; %erases the first element in our matrix
    
    C = [trialdata.Response] ==1; % Correct responses
    P = [trialdata.Plaus] ==1; %Plausible
    R = [trialdata.Reversibility] ==1; %Reversible
    E = [trialdata.Ext_Type] == 0; %SS
    
    SS_Rev_Pl1 = sum(C & E & P & R)/sum(E & P & R)
    SO_REV_Pl1 = sum(C & ~E & P & R)/sum(~E & P & R)
    SS_Irrev_Pl1 = sum(C & E & P & ~R)/sum(E & P & ~R)
    SO_Irrev_Pl1 = sum(C & ~E & P & ~R)/sum(~E & P & ~R)
    SS_Rev_Impl1 = sum(C & E & ~P & R)/sum(E & ~P & R)
    SO_Rev_Impl1 = sum(C & ~E & ~P & R)/sum(~E & ~P & R)
    SS_Irrev_Impl1 = sum(C & E & ~P & ~R)/sum(E & ~P & ~R)
    SO_Irrev_Impl1 = sum(C & ~E & ~P & ~R)/sum(~E & ~P & ~R)
    TotalAcc = mean(C)
    
    
    SS_Rev_Pl_RT = mean([trialdata([trialdata.Response]==1 & [trialdata.Ext_Type] ==0 & [trialdata.Plaus] ==1 & [trialdata.Reversibility] == 1).RT])
    SO_Rev_Pl_RT = mean([trialdata([trialdata.Response]==1 & [trialdata.Ext_Type] ==1 & [trialdata.Plaus] ==1 & [trialdata.Reversibility] == 1).RT])
    SS_Irrev_Pl_RT = mean([trialdata([trialdata.Response]==1 & [trialdata.Ext_Type] ==0 & [trialdata.Plaus] ==1 & [trialdata.Reversibility] == 0).RT])
    SO_Irrev_Pl_RT = mean([trialdata([trialdata.Response]==1 & [trialdata.Ext_Type] ==1 & [trialdata.Plaus] ==1 & [trialdata.Reversibility] == 0).RT])
    SS_Rev_Impl_RT = mean([trialdata([trialdata.Response]==1 & [trialdata.Ext_Type] ==0 & [trialdata.Plaus] ==0 & [trialdata.Reversibility] == 1).RT])
    SO_Rev_Impl_RT = mean([trialdata([trialdata.Response]==1 & [trialdata.Ext_Type] ==1 & [trialdata.Plaus] ==0 & [trialdata.Reversibility] == 1).RT])
    SS_Irrev_Impl_RT = mean([trialdata([trialdata.Response]==1 & [trialdata.Ext_Type] ==0 & [trialdata.Plaus] ==0 & [trialdata.Reversibility] == 0).RT])
    SO_Irrev_Impl_RT = mean([trialdata([trialdata.Response]==1 & [trialdata.Ext_Type] ==1 & [trialdata.Plaus] ==0 & [trialdata.Reversibility] == 0).RT])
    Total_RT = mean([trialdata([trialdata.Response] == 1).RT])
    % Other prep: format subject name
    fsubjName = subject.name;
    loc = find(fsubjName=='_');
    if(~isempty(loc)) % If we found an underscore in the subject's name
        fsubjName = [fsubjName(1:loc-1) '\' fsubjName(loc:end)];
    end
    
    %% Display Statistics for Each Trial
    
    % Table in Command Window
    responses

    responses2(1,1) = sum([trialdata.Sent_Let] == 'a'-'a' & [trialdata.Response]==1);
    
    trial_RT = zeros(8,2); % placing trial information into a matrix
    
    for i=1:length(trialdata);
        trial = trialdata(i);
        
        if trial.Response
            
            trial_RT(trial.Sent_Let,1) = trial_RT(trial.Sent_Let,1)+1; %increases the number of trials by sentence type
            trial_RT(trial.Sent_Let,2) = trial_RT(trial.Sent_Let,2)+trial.RT; %adds response time into a partial sum
            
        end
    end
    
    RT_stats = trial_RT(:,2)./trial_RT(:,1)
    
    % Bar Graph of Correctness
    h = figure(1);
    
    subplot(2,1,1);
    bar(responses)
    
    
    % Create xlabel
    xlabel('Sentence Type');
    
    % Create ylabel
    ylabel('Number of Responses');
    
    %Create title
    title([fsubjName ' Correct vs Incorrect Responses']);
    % Create legend
    legend1 = legend('Correct','Incorrect','Location', 'NorthEastOutside');
    
    % Histograms of Response Time
    subplot(2,1,2);
    
    h_bins_min = min([trialdata.RT]); % time window if considering from begining of sentence
    h_bins_max = max([trialdata.RT]); % time window if from end of sentence
    h_bins = h_bins_min:0.15:h_bins_max;
    h_plaus = hist([trialdata(find([trialdata.Plaus])).RT], h_bins);
    h_implaus = hist([trialdata(find(~[trialdata.Plaus])).RT], h_bins);
    
    bar(h_bins, [h_plaus' h_implaus']);
    xlim([min(h_bins)-0.2,max(h_bins)+0.2])
    
    % Create xlabel
    xlabel('Response Time');
    
    % Create ylabel
    ylabel('Frequency');
    
    %Create title
    title([fsubjName ' Histogram of Plausible and Implausible Responses']);
    % Create legend
    legend2 = legend('Plausible', 'Implausible', 'Location', 'NorthEastOutside');
    
    % Save for average analysis
    
    image_file = sprintf('data/figures/%s_figures.jpg',...
        subject.name);
    saveas(h, image_file);
    image_file = sprintf('%s/behaviorals/%s_behaviorals.jpg',...
        subject.meg.dir, subject.name);
    saveas(h, image_file);
    
    
    %% Save Subject
    
    subject.meg.behav.N_trials = length(subject.blocks)*40;
    subject.meg.behav.N_missed = subject.meg.behav.N_trials - sum(sum(responses));
    subject.meg.behav.responses = responses;
    subject.meg.behav.rts = [trialdata.RT];
    subject.last_edited = datestr(now, 'yyyymmdd_HHMMSS');
    subject.meg.behav.trialdata = trialdata;
    
    data_save(handles, subject);
    
    table_file = sprintf('%s/behaviorals/%s_RT.mat',...
        subject.meg.dir, subject.name);
    save(table_file,'trialdata');
    
    % Record the process
    gpsa_parameter(state, subject);
    gpsa_log(state, toc(tbegin));
    
    
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