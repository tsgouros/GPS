function varargout = gpsa_granger_rtc_singlesubject(varargin)
% Gets average waves for a condition in a single subject study
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.01.11 - Created based off of GPS1.7/gpsa_granger_subset.m
% 2013.04.25 - GPS1.8 Changed subset design to condition hierarchy

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 1; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    study = gpsa_parameter(state.study);
    subject = gpsa_parameter(state.subject);
    subset = gpsa_parameter(state.subset);
    state.function = 'gpsa_granger_rtc_singlesubject';
    
    tbegin = tic;
    
    %% Set some parameters
    
    if(~isfield(state, 'progressfid'))
        state.progressfid = 1; % stdout
    end
    
    flag_image = 1;
    
    if(flag_image)
        brain_file = sprintf('%s/brain.mat', subject.mri.dir);
        brain = load(brain_file);
    
        imdir = sprintf('%s/trials/%s/images',...
            study.granger.dir, subject.name);
        if(~exist(imdir, 'dir')); mkdir(imdir); end
    end
    
    %% Compute Average Wave
    
    fprintf(state.progressfid, '\tComputing Average Wave\n');
    
    events = condition.event.code;
    
    % For each event that is part of the condition
    for i_event = 1:length(events)
        event = events(i_event);
        
        % Load the event file
        eventfilename = sprintf('%s/trials/%s/%s_eve%04d_evoked_filtered.mat',...
            study.granger.dir, subject.name, subject.name, event);
        if(exist(eventfilename, 'file'))
            eventfile = load(eventfilename);
            
            % Add its data to the matrix of all sensor data
            if(~exist('sensordata', 'var'))
                sensordata = cat(3, eventfile.event_data.epoch);
            else
                sensordata = cat(3, sensordata, eventfile.event_data.epoch);
            end
        end % if the file exists
        
    end % for each event
    
    % Get some data from the eventfile (technically the last one)
    sample_times = eventfile.sample_times;
%     sfreq = eventfile.sfreq;
%     channel_names = eventfile.channel_names;
    [N_channels, N_samples, N_trials] = size(sensordata); %#ok<ASGLU>
    
    % Break the trials into partition
    sensordata_all = sensordata;
    N_partitions = floor(N_trials / 10);
    
    for i_partition = 1:N_partitions
        sensordata = sensordata_all(:, :, (i_partition - 1) * 10 + (1:10));
        
        [N_channels, N_samples, N_trials] = size(sensordata); %#ok<ASGLU>

        % Average the trials
        sensordata_ave = squeeze(mean(sensordata, 3));

        % Baseline the data
        sample = @(time) find(sample_times >= time, 1, 'first');
        baseline_period = sample(condition.event.basestart) : sample(condition.event.basestop);
        sensordata_ave = sensordata_ave - repmat(mean(sensordata_ave(:, baseline_period), 2), 1, N_samples);

        % Plot EEG 030 (T7) Data reflecting the left auditory cortex
        i_channel = find(strcmp(eventfile.channel_names, 'MEG 1332'));
        if(isempty(i_channel))
            i_channel = find(strcmp(eventfile.channel_names, 'MEG1332'));
        end

        if(flag_image)
            % Format subject name
            subjname = subject.name;
            underscores = strfind(subjname, '_');
            for uloc = fliplr(underscores)
                subjname = [subjname(1:uloc - 1) '\' subjname(uloc:end)];
            end
            % Format condition name
            subsname = condition.name;
            underscores = strfind(subsname, '_');
            for uloc = fliplr(underscores)
                subsname = [subsname(1:uloc - 1) '\' subsname(uloc:end)];
            end

            % All Trials
            figure(1)
            clf
            plot(sample_times(sample(0) : sample(.6)),...
                squeeze(sensordata(i_channel, sample(0) : sample(.6), :)))
            hold on
            plot(sample_times(sample(0) : sample(.6)),...
                squeeze(mean(sensordata(i_channel, sample(0) : sample(.6), :), 3)),...
                'k', 'LineWidth', 2)
            titlestr = sprintf('%s %s All Trials(%d) MEG 1332', subjname, subsname, N_trials);
            title(titlestr)
            xlabel('Time (seconds)')
            ylabel('Activation (Tesla)')
            xlim([0, .6]);

            filename = sprintf('%s/%s_%s_part%02d_act_MEG1332_trials.png', imdir, subject.name, condition.name, i_partition);
            saveas(gcf, filename);

            % Average Trial
            figure(2)
            clf
            plot(sample_times(sample(0) : sample(.6)),...
                sensordata_ave(i_channel, sample(0) : sample(.6)),...
                'k', 'LineWidth', 2)
            titlestr = sprintf('%s %s Average MEG 1332', subjname, subsname);
            title(titlestr)
            xlabel('Time (seconds)')
            ylabel('Activation (Tesla)')
            xlim([0, .6]);

            filename = sprintf('%s/%s_%s_part%02d_act_MEG1332_ave.png', imdir, subject.name, condition.name, i_partition);
            saveas(gcf, filename);
        end

        % Clean up the large variable
    %     clear sensordata

        %% Map to the Cortex

        fprintf(state.progressfid, '\tMap onto Cortex\n');

        % Get the inverse operator
        [~, inv] = evalc('mne_read_inverse_operator(subject.mne.invfile)'); %#ok<NASGU>

        % Prepares other information for the inverse operator
        % Uses dSPM
        snr = 5;
        lambda2 = 1 / (snr * snr); %#ok<NASGU>
        [~, inv] = evalc('mne_prepare_inverse_operator(inv, inv.nave, lambda2, 1)');

        % Focus on channels used in the inverse operator
        [~, i_channels] = intersect(eventfile.channel_names, inv.eigen_fields.col_names, 'stable');
        channel_names = eventfile.channel_names(i_channels); %#ok<NASGU>
        sensordata_ave = sensordata_ave(i_channels, :);

        % Map data onto the cortex
        cortexdata = gps_sensor2cortex(sensordata_ave, inv);

        % Visualize Maps
        if(flag_image)
            figure(3)
            clf
            set(gcf, 'Units', 'Pixels');
            set(gcf, 'Position', [10, 10, 800, 600]);
            set(gca, 'Units', 'Pixels');
            set(gca, 'Position', [0, 0, 800, 600]);

            % Set parameters
            drawdata = brain;
            drawdata.act.p = [80 90 95];
            options.overlays.name = 'act';
            options.overlays.percentiled = 'p';
            options.overlays.decimated = 1;
            options.overlays.coloring = 'hot';
            options.shading = 1;
            options.curvature = 'bin';
            options.sides = {'ll', 'rl', 'lm', 'rm'};
            options.fig = gcf;
            options.axes = gca;

            % Draw mean activity
            drawdata.act.data = mean(cortexdata(:, sample(condition.event.focusstart / 1000) : ...
                sample(condition.event.focusstop / 1000)), 2);
            gps_brain_draw(drawdata, options);

            frame = getframe(gcf);
            filename = sprintf('%s/%s_%s_part%02d_act_cortex.png', imdir, subject.name, condition.name, i_partition);
            imwrite(frame.cdata, filename);

            % Draw maximal activity
            drawdata.act.data = max(cortexdata(:, sample(condition.event.focusstart / 1000) : ...
                sample(condition.event.focusstop / 1000)), [], 2);
            gps_brain_draw(drawdata, options);

            frame = getframe(gcf);
            filename = sprintf('%s/%s_%s_part%02d_act_cortex_max.png', imdir, subject.name, condition.name, i_partition);
            imwrite(frame.cdata, filename);

            clear drawdata options;
        end

        % Save as STC files
        filename = sprintf('%s/stcs/%s_%s_part%02d_act',...
            subject.meg.dir, subject.name, condition.name, i_partition);

        if((isfield(state, 'override') && state.override) || ~exist([filename '-rh.stc'], 'file'))
            fprintf('\t\tsaving STC [%s-lh.stc]...\n', filename);
            inverse_write_stc(cortexdata(1:inv.src(1).nuse, :), ...
                inv.src(1).vertno, ...
                sample_times(1) * 1000, ...
                mean(diff(sample_times)) * 1000, ...
                [filename '-lh.stc']);

            fprintf('\t\tsaving STC [%s-rh.stc]...\n', filename);
            inverse_write_stc(cortexdata((inv.src(1).nuse + 1) : end, :), ...
                inv.src(2).vertno, ...
                sample_times(1) * 1000, ...
                mean(diff(sample_times)) * 1000, ...
                [filename '-rh.stc']);
        end % If we are saving the files

        %% Get ROI data

    %     filename = sprintf('%s/%s/%s_%s_rois.mat', condition.cortex.roidir,...
    %         subject.name, subject.name, condition.name);
    %     if(~exist(filename, 'file'))
    %         filename = sprintf('%s/%s/%s_rois.mat', condition.cortex.roidir,...
    %             subject.name, subject.name);
    %     end
        filename = sprintf('%s/rois/%s/%s/%s_%s_rois.mat', study.granger.dir, condition.cortex.roiset,...
            subject.name, subject.name, condition.name);
        if(~exist(filename, 'file'))
            filename = sprintf('%s/rois/%s/%s/%s_rois.mat', study.granger.dir, condition.cortex.roiset,...
                subject.name, subject.name);
        end

        if(exist(filename, 'file'))
            fprintf(state.progressfid, '\tGet ROI data\n');
            rois = load(filename);

            roidata = cortexdata([rois.rois.decIndex], :);

            if(flag_image)
                figure(4)
                clf
                hold on;
                selected_rois = [];
                selected_roinames = {};
                for i_ROI = 1:length(rois.rois)
                    name = rois.rois(i_ROI).name;
                    if(sum(strcmp({'STG', 'MTG', 'SMG'}, rois.rois(i_ROI).area)))
                        selected_rois(end + 1) = i_ROI; %#ok<AGROW>
                        underscores = strfind(name, '_');
                        for uloc = fliplr(underscores)
                            name = [name(1:uloc - 1) '\' name(uloc:end)];
                        end
                        selected_roinames = cat(1, selected_roinames, name); 
                    end
                end
                plot(sample_times, roidata(selected_rois, :));
                xlim([0, .6]);
                xlabel('Time (s)');
                ylabel('Activation (Am)');
                titlestr = sprintf('%s %s Selected ROI Waves', subjname, subsname);
                title(titlestr);
                legend(selected_roinames)

                filename = sprintf('%s/%s_%s_part%02d_act_selectrois.png', imdir, subject.name, condition.name, i_partition);
                saveas(gcf, filename);
            end % If we are making images

            % Save ROI Data
            folder = sprintf('%s/roiwaves/%s', study.granger.dir, condition.name);
            if(~strcmp(condition.name, condition.cortex.roiset))
                folder = sprintf('%s/%s', folder, condition.cortex.roiset); end
            if(~exist(folder, 'dir')); mkdir(folder); end

            filename = sprintf('%s/%s_%s_part%02d_roiwaves.mat',...
                folder, subject.name, condition.name, i_partition);

            savedata.data = roidata;
            savedata.rois = rois.rois;
            savedata.sample_times = sample_times;
            savedata.study = study.name;
            savedata.subject = subject.name;
            savedata.condition = condition.name; %#ok<STRNU>
            save(filename, '-struct', 'savedata');
        end

    end % For each partition 
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    study = gpsa_parameter(state.study);
    subject = gpsa_parameter(state.subject);
    condition = gpsa_parameter(state.condition);
    if(~isempty(subject))
        % Predecessor: granger_trials
        filespec = sprintf('%s/trials/%s/%s_eve*_evoked_filtered.mat',...
            study.granger.dir, subject.name, subject.name);
        report.ready = length(dir(filespec)) >= 1;
        
        actfilename = sprintf('%s/stcs/%s_%s_act*.stc',...
            subject.meg.dir, subject.name, condition.name);
        folder = sprintf('%s/roiwaves/%s', study.granger.dir, condition.name);
        if(~strcmp(condition.name, condition.cortex.roiset))
            folder = sprintf('%s/%s', folder, condition.cortex.roiset); end
        roifilename = sprintf('%s/%s_%s_roiwaves.mat',...
            folder, subject.name, condition.name);
        report.progress = (double(length(dir(actfilename)) >= 2) + ...
            double(exist(roifilename, 'file') == 2)) / 2;
        
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