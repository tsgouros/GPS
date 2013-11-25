function varargout = gpsa_plv_compute(varargin)
% Computes the Phase Locking Values using Sheraz's code
%
% Author: Conrad Nied, Sheraz Khan
%
% Input: Optional: Granger processing stream variable structure
%
% Changelog:
% 2012.07 - Created by Sheraz Khan as cluster/calvin/2/dgow/sample_code.m
% 2012.07.18 - Adapted to loosely to GPS1.6 by Conrad Nied as
% cluster/calvin/2/dgow/plv_compute_sheraz2.m
% 2012.10.25 - Started to formally adapt to GPS1.7/gpsa_plv_compute.m
% 2012.10.28 - Trial import framework
% 2012.10.29 - Finished PLV
% 2012.11.02 - Added additional options to the program, visualizations
% 2012.11.30 - Played around with source covariance
% 2013.01.09 - Updated to better handle data
% 2013.01.15 - Trying to make it work!
% 2013.02.22 - Added emptyroom clause
% 2013.04.24 - GPS1.8 Changed subset/subsubset to condition/subset

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 1; % Condition specific?
    report.spec_subs = 1; % Subset specific
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    study = gpsa_parameter(state.study);
    subject = gpsa_parameter(state.subject);
    condition = gpsa_parameter(state.condition);
    state.function = 'gpsa_plv_compute';
    tbegin = tic;
    
    frequency  = 40; % Will want to restore this to study parameter field
    time_start = -0.1;
    time_stop  = 0.8;
    
    if(strcmp(state.subset, 'emptyroom'))
        condition.name = 'emptyroom';
        condition.event.code = 4096;
    elseif(strcmp(state.subset, 'IBI'))
        condition.name = 'IBI';
        condition.event.code = 4097;
    end
    
    showProgress = 1;
    if(showProgress); fprintf('PLV Computation for %s %s\n', subject.name, condition.name); end
    
    [~, hostname] = unix('hostname');
    
    if(sum(strcmp({'huygens', 'wittgen', 'norbert'}, hostname(1:7))))
        flag_image = 1;
    else
        flag_image = 0;
    end
    
    %% Collect trial information for the subject
    
    if(showProgress); fprintf('\t1/6: Sensor Data'); end
    
    events = condition.event.code;
    sensor_data = []; % Holds the sensor_data, channels x samples x trials
    N_trials = 0;
    
    for i_event = 1:length(events)
        event = events(i_event);
        
        filename = sprintf('%s/trials/%s/%s_eve%04d_evoked.mat',...
            study.plv.dir, subject.name, subject.name, event);
        if(exist(filename, 'file'))
            eventfile = load(filename);
            
            if(i_event == 1)
                [N_channels, N_samples] = size(eventfile.event_data(1).epoch);
                sensor_data = zeros(N_channels, N_samples, 1, 'single');
            end
            
            for i_trial = 1:length(eventfile.event_data)
                N_trials = N_trials + 1;
                sensor_data(:, :, N_trials) = single(eventfile.event_data(i_trial).epoch);
            end % for each trial
        end % If it the file exists
    end % for each event
    
    % Get other data from the eventfile and then clear it to save space
    sample_times = eventfile.sample_times;
    sfreq = eventfile.sfreq;
    channel_names = eventfile.channel_names;
    
    clear eventfile;
    
    if(showProgress); fprintf('.\n'); end
    
    %% Load the inverse solution and select channels
    
    if(showProgress); fprintf('\t2/6: Inverse Solution'); end
    
    % Load the non-eeg inverse solution
    inv_filename = subject.mne.invfile;
    inv_filename = inv_filename(1:find(inv_filename == '/', 1, 'last'));
%     inv_filename = sprintf('%s%s_depth_meg_spacing5-inv.fif', inv_filename, subject.name);
%     inv_filename = sprintf('%s%s_depth_meg-inv.fif', inv_filename, subject.name);
    inv_filename = sprintf('%s%s_meg-inv.fif', inv_filename, subject.name);
%     i_eeg = strfind(inv_filename, '_eeg');
%     if(~isempty(i_eeg)); inv_filename(i_eeg:(i_eeg + 3)) = []; end
    
    inv = gpsa_mne_getinv(inv_filename);
    
    % Only use channels in the inverse solution from the data
    [channel_names, i_channels] = intersect(channel_names, inv.eigen_fields.col_names, 'stable');
    sensor_data = sensor_data(i_channels, :, :);
%        sensor_data = sensor_data(:, :, 1:5); % Limit it to 5 trials for now
    
    [N_channels, ~, N_epochs] = size(sensor_data);
    N_sources = inv.nsource;
    
    sourcov = inv.source_cov.data(1:3:end);
    
    if(showProgress); fprintf('.\n'); end
    
    %% Get Frequency Data and focus time data
    
    if(showProgress); fprintf('\t3/6: Frequency Data'); end
    
    sensor_freq_data = zeros(size(sensor_data), 'single');
    for i_channel = 1:N_channels
        sensor_freq_data(i_channel, :, :) = single(squeeze(...
            computeWaveletTransform(squeeze(sensor_data(i_channel, :, :)), sfreq, frequency, 3 ,'morlet')))';
    end
    
    % Do analysis on many frequencies
%     frequencies = 20:2:60;
%     N_freq = length(frequencies);
%     sensor_freq_data_all = zeros([size(sensor_data), N_freq], 'single');
%     matlabpool 8
%     fprintf('\t\tFrequency Analysis');
%     parfor i_freq = 1:N_freq
%         fprintf(' %d', frequencies(i_freq));
%         for i_channel = 1:N_channels
%             sensor_freq_data_all(i_channel, :, :, i_freq) = single(squeeze(...
%                 computeWaveletTransform(squeeze(sensor_data(i_channel, :, :)), sfreq, frequencies(i_freq), 3 ,'morlet')))';
%         end
%     end % for each frequency 
%     matlabpool close
%     fprintf('\n');
    
    
%     if(flag_image)
%         
%         imdir = sprintf('%s/trials/%s/images',...
%             study.plv.dir, subject.name);
%         if(~exist(imdir, 'dir')); mkdir(imdir); end
%         
%         figure(1)
%         % Image this, first by taking the mean across sensor locations and
%         % epochs (will want to detect the right sensor later)
%         average_freq = squeeze(mean(mean(sensor_freq_data_all, 3), 1));
%         plot(abs(average_freq));
%         filename = sprintf('%s/%s_%s_plv_frequencies.png', imdir, subject.name, condition.name);
%         saveas(gcf, filename);
%         clf
%     end
%     clear sensor_freq_data_all;
%     
    clear sensor_data;
    
    % Limit time window
    sample_start = max(find(sample_times > time_start, 1, 'first') - 1, 1);
    sample_zero  = max(find(sample_times > 0,          1, 'first') - 1, 1);
    sample_stop  =     find(sample_times > time_stop , 1, 'first');
    sample_100   =     find(sample_times > 0.1       , 1, 'first');
    sample_400   =     find(sample_times > 0.4       , 1, 'first');
    
    i_samples = sample_start:sample_stop;
    
    sample_times = sample_times(i_samples);
    sensor_freq_data = sensor_freq_data(:, i_samples, :);
    N_time = length(sample_times);
    
    if(showProgress); fprintf('.\n'); end
    
    %% Import reference ROI
    
    if(showProgress); fprintf('\t4/6: Import Reference ROI'); end
    
    % Something is wrong with this
%     % Determine filename
%     files = dir([condition.cortex.plvrefdir '/*.label']);
%     reference_roi_filename = sprintf('%s/%s',...
%         condition.cortex.plvrefdir, files(1).name); % later make it possible to do multiple
%     
%     % Read Labels and get indices
%     reference_vertices = read_label('', reference_roi_filename);
%     reference_vertices = squeeze(reference_vertices(:, 1)) + 1;
%     
%     if(strfind(reference_roi_filename, 'lh.'))
%         [~, ~, lsrcind] = intersect(reference_vertices, inv.src(1).vertno);
%         reference_decIndices = lsrcind;
%     elseif(strfind(reference_roi_filename, 'rh.'))
%         [~, ~, rsrcind] = intersect(reference_vertices, inv.src(2).vertno);
%         reference_decIndices = inv.src(1).nuse + int32(rsrcind);
%     end
%     N_refVerts = length(reference_decIndices);
    
    brain_file = sprintf('%s/brain.mat', subject.mri.dir);
    brain = load(brain_file);
    filename = sprintf('%s/%s/%s_plvref.mat', condition.cortex.plvrefdir, subject.name, subject.name);
    rois = load(filename);
    [~, reference_decIndices, ~] = intersect(brain.decIndices, rois.rois.vertices);
    N_refVerts = length(reference_decIndices);
    
    if(showProgress); fprintf('.\n'); end
    
    %% Get reference ROI activity
    
    if(showProgress); fprintf('\t5/6: Reference Activity'); end
    
    cortical_activity_ave = zeros(N_sources, N_time, 'single');
    
    % Gets reference activity
    reference_activity = zeros(N_refVerts, N_time, N_epochs);
    for i_epoch = 1:N_epochs
        cortical_activity = gps_sensor2cortex(sensor_freq_data(:, :, i_epoch), inv, 'dSPM', 'Fixed');
        cortical_activity_ave = cortical_activity_ave + single(cortical_activity);
        
        reference_activity(:, :, i_epoch) = cortical_activity(reference_decIndices, :);
    end % for each epoch
    
    % Finds orientation (based on labelmean.m from Sheraz)
    temp = mean(reference_activity, 3);
    [svd_orientation, ~, ~]= svd(temp', 'econ');
    multfactor = zeros(N_refVerts, 1);
    for i_refVert = 1:N_refVerts
        multfactor(i_refVert) = sign(dot(svd_orientation(:, 1), temp(i_refVert, :)'));
        reference_activity(i_refVert, :) = reference_activity(i_refVert, :) * multfactor(i_refVert);
    end
    
    if(showProgress); fprintf('.\n'); end
    
    %% Compute phase locking
    
    if(showProgress); fprintf('\t6/6: PLV Computation'); end
    
    eachRefVert_phase_locking = zeros(N_sources, N_time, N_refVerts);
    
    for i_epoch = 1:N_epochs
        if(showProgress && mod(i_epoch, 40) == 0); fprintf('\n\t'); end
        if(showProgress); fprintf('.'); end
        epoch_activity = gps_sensor2cortex(sensor_freq_data(:, :, i_epoch), inv, 'dSPM', 'Fixed');
        
        % For each reference vertex
        for i_refVert = 1:N_refVerts
            refVert_freq_data = repmat(squeeze(reference_activity(i_refVert, :, i_epoch)), [N_sources, 1]);
            %         refVert_freq_data = permute(refVert_freq_data, [2 1]);
            
            refVert_phase_locking = epoch_activity .* conj(refVert_freq_data);
            refVert_phase_locking = refVert_phase_locking ./ abs(refVert_phase_locking);
            refVert_phase_locking = refVert_phase_locking ./ repmat(sourcov, 1, N_time);
            eachRefVert_phase_locking(:, :, i_refVert) = eachRefVert_phase_locking(:, :, i_refVert) + refVert_phase_locking;
        end
    end % for each epoch
    
    if(showProgress); fprintf('.\n'); end
    
    % Combine reference vertices
    eachRefVert_phase_locking = eachRefVert_phase_locking / N_epochs;
    eachRefVert_phase_locking = abs(eachRefVert_phase_locking);
    phase_locking = mean(eachRefVert_phase_locking, 3);
    
    %% Normalized PLV
    
    phase_locking_mean =   mean(phase_locking(:, 1:sample_zero),    2);
    phase_locking_std  =    std(phase_locking(:, 1:sample_zero), 0, 2);
    phase_locking_mean = repmat(phase_locking_mean, 1, N_time);
    phase_locking_std  = repmat(phase_locking_std , 1, N_time);
    phase_locking_z = (phase_locking - phase_locking_mean) ./ phase_locking_std;
    
    %% Image
    
    if(flag_image)
        
        imdir = sprintf('%s/trials/%s/images',...
            study.plv.dir, subject.name);
        if(~exist(imdir, 'dir')); mkdir(imdir); end
        
%         figure(1)
%         clf
%         plot(sample_times, sum(phase_locking_z > 4, 1))
        
%         % Load Data
% %         brain_file = sprintf('%s/brain.mat', subject.mri.dir);
% %         brain = load(brain_file);
%         filename = sprintf('%s/%s/%s_plvref.mat', condition.cortex.plvrefdir, subject.name, subject.name);
%         rois = load(filename);
%         
%         % Change the decimated indices to the inverse solution used in PLV
%         brain.decIndices = [inv.src(1).vertno'; inv.src(2).vertno' + brain.N_L];
%         brain.decN_L = inv.src(1).nuse;
%         brain.decN_R = inv.src(2).nuse;
%         brain.decN = brain.decN_L + brain.decN_R;
        
        % Draw Brains
        figure(61053)
        clf
        set(gcf, 'Units', 'Pixels');
        set(gcf, 'Position', [10, 10, 850, 650]);
        set(gca, 'Units', 'Pixels');
        set(gca, 'Position', [25, 25, 800, 600]);
        
        % Set parameters
        drawdata = brain;
        drawdata.plv.p = [80 90 95];
        drawdata.points = rois.rois;
        options.overlays.name = 'plv';
        options.overlays.percentiled = 'p';
        options.overlays.decimated = 1;
        options.overlays.coloring = 'hot';
        options.shading = 1;
        options.curvature = 'bin';
        options.sides = {'ll', 'rl', 'lm', 'rm'};
        options.fig = gcf;
        options.axes = gca;
        options.centroids = 1;
        options.vertices = 1;
        
        % Draw mean plv
        drawdata.plv.data = mean(phase_locking(:, sample_100:sample_400), 2);
%         drawdata.plv.data = mean(epoch_activity(:, sample_100:sample_400), 2);

        gps_brain_draw(drawdata, options);
        
        frame = getframe(gcf);
        filename = sprintf('%s/%s_%s_plv_LSTG1_40Hz_cortex.png', imdir, subject.name, condition.name);
        imwrite(frame.cdata, filename);
        
        % Normalized
        figure(61054)
        clf
        set(gcf, 'Units', 'Pixels');
        set(gcf, 'Position', [300, 300, 850, 650]);
        set(gca, 'Units', 'Pixels');
        set(gca, 'Position', [25, 25, 800, 600]);
        options.fig = gcf;
        options.axes = gca;
        
        drawdata.plv.data = mean(phase_locking_z(:, sample_100:sample_400), 2);
        
        gps_brain_draw(drawdata, options);
        
        frame = getframe(gcf);
        filename = sprintf('%s/%s_%s_plv_LSTG1_40Hz_plz_cortex.png', imdir, subject.name, condition.name);
        imwrite(frame.cdata, filename);
        
%         % Cortical activity averaged across trials
%         data = abs(cortical_activity_ave);
%         drawdata.plv.data = mean(data(:, sample_100:sample_400), 2);
%         
%         gps_brain_draw(drawdata, options);
%         
%         frame = getframe(gcf);
%         filename = sprintf('%s/%s_%s_mne_cortex_ave.png', imdir, subject.name, condition.name);
%         imwrite(frame.cdata, filename);
%         
%         % Cortical activity from average wave dSPM
%         data = abs(gps_sensor2cortex(squeeze(mean(sensor_freq_data, 3)), inv, 'dSPM', 'Fixed'));
%         drawdata.plv.data = mean(data(:, sample_100:sample_400), 2);
%         
%         gps_brain_draw(drawdata, options);
%         
%         frame = getframe(gcf);
%         filename = sprintf('%s/%s_%s_mne_cortex_avewave_dSPM.png', imdir, subject.name, condition.name);
%         imwrite(frame.cdata, filename);
%         
%         % Not dSPM
%         data = abs(gps_sensor2cortex(squeeze(mean(sensor_freq_data, 3)), inv, 'Fixed'));
%         drawdata.plv.data = mean(data(:, sample_100:sample_400), 2);
%         
%         gps_brain_draw(drawdata, options);
%         
%         frame = getframe(gcf);
%         filename = sprintf('%s/%s_%s_mne_cortex_avewave_nodSPM.png', imdir, subject.name, condition.name);
%         imwrite(frame.cdata, filename);
        
    end % If imaging
    
    %% Save 
    
    % Mat
    folder = sprintf('%s/subject_results/%s',...
        study.plv.dir, condition.name);
    if(~exist(folder, 'dir')); mkdir(folder); end
    plv_filename = sprintf('%s/%s_%s_plv_LSTG1_40Hz.mat',...
        folder, subject.name, condition.name);
    save(plv_filename, 'phase_locking', 'sample_times');
    
    % STC
    filename_plv = sprintf('%s/%s_plv_LSTG1_40Hz',...
        folder, subject.name);
%     fprintf('saving STC [%s-lh.stc]...\n', filename_plv);
    inverse_write_stc(phase_locking(1:inv.src(1).nuse, :),...
        inv.src(1).vertno - 1, time_start * 1000, 1e3 / sfreq, [filename_plv '-lh.stc']);
    
%     fprintf('saving STC [%s-rh.stc]...\n', filename_plv);
    inverse_write_stc(phase_locking((inv.src(1).nuse + 1) : end, :),...
        inv.src(2).vertno - 1, time_start * 1000, 1e3 / sfreq, [filename_plv '-rh.stc']);



    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    study = gpsa_parameter(state.study);
    subject = gpsa_parameter(state.subject);
    condition = gpsa_parameter(state.condition);
    if(~isempty(subject) && ~isempty(condition))
        % Predecessor: gpsa_plv_trials.m and gpsa_plv_rois
        filespec = sprintf('%s/trials/%s/%s_eve*_evoked.mat',...
            study.plv.dir, subject.name, subject.name);
        report.ready = ~isempty(dir(filespec));
        filename = sprintf('%s/%s/%s*plvref.mat', condition.cortex.plvrefdir,...
            subject.name, subject.name);
        report.ready = (double(~isempty(dir(filename))) + double(report.ready))/2;
        
        filespec = sprintf('%s/subject_results/%s/%s_*',...
            study.plv.dir, condition.name, subject.name);
        report.progress = ~isempty(dir(filespec));
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


end % Function
