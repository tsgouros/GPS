function varargout = gpsa_mne_stc(varargin)
% Make an STC movie file based on the primary conditions and inverse solution
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012.01.23 - Originally created as GPS1.6(-)/mne_stc.m
% 2012.05.30 - Last modified in GPS1.6(-)
% 2012.10.08 - Updated to GPS1.7 format
% 2012.10.10 - Correct for N == 0 in progress report
% 2012.11.08 - Subset specific now
% 2013.04.16 - GPS 1.8, Updated the status check to the new system and
% added gps_filename identifiers for files
% 2013.04.24 - Changed subset/subsubset to condition hierarchy
% 2013.04.26 - Directly finds the condition's # from the avefile
% 2013.05.01 - Modified status check
% 2013.06.20 - Reverted the status check to the individual system

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 1; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    study = gpsa_parameter(state, state.study);
    subject = gpsa_parameter(state, state.subject);
    condition = gpsa_parameter(state, state.condition);
    state.function = 'gpsa_mne_stc';
    tbegin = tic;
    
    %% Set some parameters
    
    if(~isfield(state, 'progressfid'))
        state.progressfid = 1; % stdout
    end
    
    flag_image = 1;
    
    if(flag_image)
        brain_file = sprintf('%s/brain.mat', subject.mri.dir);
        
        warning('off', 'MATLAB:getframe:RequestedRectangleExceedsFigureBounds');
        
        if(~exist(brain_file, 'file'))
            flag_image = 0;
        else
            brain = load(brain_file);
            
            megimdir = gps_filename(study, subject, 'meg_images_dir');
            if(~exist(megimdir, 'dir')); mkdir(megimdir); end
            
            mneimdir = gps_filename(study, subject, 'meg_images_dir');
            if(~exist(mneimdir, 'dir')); mkdir(mneimdir); end
        end
    end
    
    %% Compute Average Wave
    
    fprintf(state.progressfid, '\tComputing Average Wave\n');
    
    events = condition.event.code;
    
    % For each event that is part of the condition
    for i_event = 1:length(events)
        event = events(i_event);
        
        % Load the event file
        evokedfilename = gps_filename(study, subject, 'meg_evoked_event', ['event=' num2str(event)]);
        if(exist(evokedfilename, 'file'))
            evokedfile = load(evokedfilename);
            
            % Add its data to the matrix of all sensor data
            if(~exist('sensordata', 'var'))
                sensordata = cat(3, evokedfile.event_data.epoch);
            else
                sensordata = cat(3, sensordata, evokedfile.event_data.epoch);
            end
        end % if the file exists
        
    end % for each event
    
    if(~exist('evokedfile', 'var'))
        fprintf('Didn''t find evoked file for subject %s, events %s', subject.name, sprintf('%d ', events));
        return
    end
    
    % Get some data from the evokedfile (technically the last one)
    sample_times = evokedfile.sample_times;
    [N_channels, N_samples, N_trials] = size(sensordata); %#ok<ASGLU>
    
    % Average the trials
    sensordata_ave = squeeze(mean(sensordata, 3));
    
    % Baseline the data
    sample = @(time) find(sample_times >= time, 1, 'first');
    baseline_period = sample(condition.event.basestart) : sample(condition.event.basestop);
    sensordata_ave = sensordata_ave - repmat(mean(sensordata_ave(:, baseline_period), 2), 1, N_samples);
    
    % Plot EEG 030 (T7) Data reflecting the left auditory cortex
    i_channel = find(strcmp(evokedfile.channel_names, 'MEG 1332'));
    if(isempty(i_channel))
        i_channel = find(strcmp(evokedfile.channel_names, 'MEG1332'));
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
        
        stop_s = condition.event.focusstop / 1000;
        
        % All Trials
        figure(1)
        clf
        plot(sample_times(sample(0) : sample(stop_s)),...
            squeeze(sensordata(i_channel, sample(0) : sample(stop_s), :)))
        hold on
        plot(sample_times(sample(0) : sample(stop_s)),...
            squeeze(mean(sensordata(i_channel, sample(0) : sample(stop_s), :), 3)),...
            'k', 'LineWidth', 2)
        titlestr = sprintf('%s %s All Trials(%d) MEG 1332', subjname, subsname, N_trials);
        title(titlestr)
        xlabel('Time (seconds)')
        ylabel('Activation (Tesla)')
        xlim([0, stop_s]);
        
        filename = sprintf('%s/%s_%s_act_MEG1332_trials.png', megimdir, subject.name, condition.name);
        saveas(gcf, filename);
        
        % Average Trial
        figure(2)
        clf
        plot(sample_times(sample(0) : sample(stop_s)),...
            sensordata_ave(i_channel, sample(0) : sample(stop_s)),...
            'k', 'LineWidth', 2)
        titlestr = sprintf('%s %s Average MEG 1332', subjname, subsname);
        title(titlestr)
        xlabel('Time (seconds)')
        ylabel('Activation (Tesla)')
        xlim([0, stop_s]);
        
        filename = sprintf('%s/%s_%s_act_MEG1332_ave.png', megimdir, subject.name, condition.name);
        saveas(gcf, filename);
    end
    
    % Clean up the large variable
    clear sensordata
    
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
    [~, i_channels] = intersect(evokedfile.channel_names, inv.eigen_fields.col_names, 'stable');
    channel_names = evokedfile.channel_names(i_channels); %#ok<NASGU>
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
        filename = sprintf('%s/%s_%s_act_cortex.png', mneimdir, subject.name, condition.name);
        imwrite(frame.cdata, filename);
        
        clear drawdata options;
    end
    
    % Save as STC files
    folder = gps_filename(subject, 'mne_stc_dir');
    if(~exist(folder, 'dir')); mkdir(folder); end
    
    filename = gps_filename(subject, condition, 'mne_stc');
    
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
    
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    % Prerequisite: gpsa_mne_inv and gpsa_mne_evoked
    subject = gpsa_parameter(state, state.subject);
    condition = gpsa_parameter(state, state.condition);
    study = gpsa_parameter(state, state.study);
    if(sum(strcmp(condition.subjects, subject.name)))
        report.ready = (double(length(dir(gps_filename(study, subject, 'meg_evoked_gen'))) >= 1) + ...
            (~~exist(subject.mne.invfile, 'file'))) / 2;
        report.progress = ~~exist(gps_filename(subject, condition, 'mne_stc_lh'), 'file');
    else
        report.ready = 0; report.progress = 0; report.applicable = 0;
    end
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function