function rois_metrics_compute(hObject, GPSR_vars)
% Computes the metric given the settings
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI
%
% Date Created: 2012.06.18
% Last Modified: 2012.06.21
% 2012.10.09 - Superficially adapted to GPS1.7
% 2012.11.02 - Interpolates timeseries when combining
% 2013.06.28 - GPS1.8, doesn't draw the figures if autoredraw is off

%% Load the structure

% Metric Identifier
num = get(GPSR_vars.metrics_list, 'Value');
switch num
    case 1; type = 'mne';
    case 2; type = 'plv';
    case 3; type = 'custom';
    case 4; type = 'maxact';
    case 5; type = 'sim';
end

fprintf('Computing %s\n', type);

% Get structures
metric = getappdata(GPSR_vars.datafig, type);
flag_figures = ~get(GPSR_vars.quick_pauseautoredraw, 'Value');

%% Get Raw Data

fprintf('\tretrieve raw data\n');
    
switch type
    case 'maxact';
        switch metric.basis.one
            case 1; basis = 'none'; % not working atm
            case 2; basis = 'mne';
            case 3; basis = 'plv';
            case 4; basis = 'custom';
        end
        basismetric = getappdata(GPSR_vars.datafig, basis);
        data = basismetric.data.stnd;
        timeseries = basismetric.data.timeseries;
        
        % Second basis?
        if(metric.basis.combine)
            switch metric.basis.two
                case 1; basis2 = 'mne';
                case 2; basis2 = 'plv';
                case 3; basis2 = 'custom';
            end
            basis2metric = getappdata(GPSR_vars.datafig, basis2);
            data2 = basis2metric.data.stnd;
            timeseries2 = basis2metric.data.timeseries;
            
            t1_min = ceil(min(timeseries));
            t2_min = ceil(min(timeseries2));
            t1_max = max(timeseries);
            t2_max = max(timeseries2);
            
            % Interpolate data to smooth out sampling rate (to 1000Hz)
            sfreq = mean(1./diff(timeseries));
            if(sfreq ~= 1)
                data = interp1(timeseries, data', t1_min:t1_max)';
                timeseries = t1_min:t1_max;
            end % Interpolate!
            
            sfreq = mean(1./diff(timeseries2));
            if(sfreq ~= 1)
                data2 = interp1(timeseries2, data2', t2_min:t2_max)';
                timeseries2 = t2_min:t2_max;
            end % Interpolate!
            
            % Time intersection
            [timeseries, data1keep, data2keep] = intersect(timeseries, timeseries2, 'stable');
            data = data(:, data1keep) + data2(:, data2keep);
            
        end % Second basis
        
        % Save to structure
        metric.data.raw = data;
        metric.data.timeseries = timeseries;
    case 'sim'
        % Get MNE and points
        basismetric = getappdata(GPSR_vars.datafig, 'mne');
        points = getappdata(GPSR_vars.datafig, 'points');
        data = basismetric.data.raw;
        
        % Get timeseries
        timeseries = basismetric.data.timeseries;
        metric.data.timeseries = timeseries;
        
    otherwise % mne, plv, custom
        data = metric.data.raw;
        timeseries = ((1:size(data, 2)) - 1) .* (metric.data.tstep * 1000) + (metric.data.tmin * 1000);
        if(strcmp(type, 'plv'))
            timeseries = timeseries - 99.9;
        end
        metric.data.timeseries = timeseries;
end

%% Configure Time Window

start = str2num(metric.time.start_text);
stop  = str2num(metric.time.stop_text); %#ok<*ST2NM>
metric.time.start = start;
metric.time.stop  = stop;

% If the lengths are different the user is probably adding them so just
% display in the standard out that it had to fail
N_timewindows = length(start);

if(N_timewindows ~= length(stop))
    fprintf('\nNumber of starts and stops is uneven\n\n');
    set(GPSR_vars.metrics_time_comp2, 'enable', 'on');
    guidata(GPSR_vars.metrics_time_comp2, GPSR_vars);
    return;
end

% Convert start and stop to sample numbers
samp_start = zeros(N_timewindows, 1);
samp_stop  = zeros(N_timewindows, 1);
for i = 1:N_timewindows
    samp_start(i) = find(timeseries >= start(i), 1, 'first');
    samp_stop(i)  = find(timeseries <= stop(i) , 1, 'last');
end

metric.time.samp_start = samp_start;
metric.time.samp_stop  = samp_stop;

%% Standardize Waves

if(metric.stnd.use && metric.stnd.scope <= 3)
    fprintf('\tstandardizing\n');

        % Mean
        switch metric.stnd.scope
            case {1, 4} % Globally
            data = data - mean(mean(data));
            case {2, 5} % Vertex Based
            data = data - repmat(mean(data, 2), 1, size(data, 2));
            case {3, 6} % Time Sample Based
            data = data - repmat(mean(data, 1), size(data, 1), 1);
        end

        % Standard Deviation
        if(~metric.stnd.meanonly)
            switch metric.stnd.scope
                case {1, 4} % Globally
                data = data ./ std(data(:));
                case {2, 5} % Vertex Based
                data = data ./ repmat(std(data, 1, 2), 1, size(data, 2));
                case {3, 6} % Time Sample Based
                data = data ./ repmat(std(data, 1, 1), size(data, 1), 1);
            end
        end % And STDEV?
elseif(metric.stnd.use)
    fprintf('\tstandardizing\n');
    
    data_o = data; % Save the data
    
    for i = 1:N_timewindows
        data = data_o(:, samp_start(i):samp_stop(i));
        
        % Mean
        switch metric.stnd.scope
            case {1, 4} % Globally
            data = data - mean(mean(data));
            case {2, 5} % Vertex Based
            data = data - repmat(mean(data, 2), 1, size(data, 2));
            case {3, 6} % Time Sample Based
            data = data - repmat(mean(data, 1), size(data, 1), 1);
        end

        % Standard Deviation
        if(~metric.stnd.meanonly)
            switch metric.stnd.scope
                case {1, 4} % Globally
                data = data ./ std(data(:));
                case {2, 5} % Vertex Based
                data = data ./ repmat(std(data, 1, 2), 1, size(data, 2));
                case {3, 6} % Time Sample Based
                data = data ./ repmat(std(data, 1, 1), size(data, 1), 1);
            end
        end % And STDEV?
        
        data_o(:, samp_start(i):samp_stop(i)) = data;
    end % For each time window
    
    data = data_o;
    clear data_o;
end % If there are one or many time windows and we are standardizing

% Save the data of the standardized stage for use in the maxact possibly
metric.data.stnd = data;

%% Similarity: Find the difference

if(strcmp(type, 'sim'))
    
    % Extract the particular point
    point = points(metric.sim.point);
    data = data - repmat(data(point.decIndex, :), size(data, 1), 1);
    
    % Find the norm
    switch metric.sim.norm
        case 1; data = abs(data);
        case 2; data = power(data, 2);
    end
end

%% Graph the Waves

fprintf('\tgraphing\n');

if(flag_figures)
    figure(metric.num + 6752)
    set(gcf, 'Name', [metric.type ' distribution for GPS plot']);
    set(gcf, 'Numbertitle', 'off');
    GPSR_vars.axes_wave = subplot(2, 1, 1);
    cla(GPSR_vars.axes_wave);
    hold(GPSR_vars.axes_wave, 'on');
    title(GPSR_vars.axes_wave, [type ' time windows, mean, median, and .25/.75 quantiles']);
end

if(strcmp(type, 'sim'))
%     switch metric.sim.norm
%         case 1; data_show = data;
%         case 2; data_show = sqrt(data);
%     end
    data_ave = mean(-data, 1);
    data_medians = quantile(-data, [0.25 0.50 0.75]);
else
    data_ave = mean(data, 1);
    data_medians = quantile(data, [0.25 0.50 0.75]);
end

data_min = min(min([data_ave; data_medians]));
data_max = max(max([data_ave; data_medians]));

if(flag_figures)
    for i = 1:N_timewindows
        fill([start(i) start(i) stop(i) stop(i)],...
            [data_min data_max data_max data_min],...
            [.9 1 .9],...
            'Parent', GPSR_vars.axes_wave,...
            'HitTest', 'off');
    end
    
    % plot(timeseries, data,...
    %     'Parent', GPSR_vars.axes_wave,...
    %     'HitTest', 'off');
    % waveheat(data);
    line(timeseries, data_ave,...
        'Color', [0 0 1],...
        'Parent', GPSR_vars.axes_wave,...
        'HitTest', 'off',...
        'LineWidth', 2);
    line(timeseries, data_medians(1, :),...
        'Color', [0 .75 .75],...
        'Parent', GPSR_vars.axes_wave,...
        'HitTest', 'off',...
        'LineWidth', 2);
    line(timeseries, data_medians(2, :),...
        'Color', [0 .5 1],...
        'Parent', GPSR_vars.axes_wave,...
        'HitTest', 'off',...
        'LineWidth', 2);
    line(timeseries, data_medians(3, :),...
        'Color', [0 .75 .75],...
        'Parent', GPSR_vars.axes_wave,...
        'HitTest', 'off',...
        'LineWidth', 2);
    
    for i = 1:N_timewindows
        line([start(i) start(i)], [data_min data_max],...
            'Color', 'g',...
            'Parent', GPSR_vars.axes_wave,...
            'HitTest', 'off');
        line([stop(i) stop(i)], [data_min data_max],...
            'Color', 'g',...
            'Parent', GPSR_vars.axes_wave,...
            'HitTest', 'off');
    end
    
    axis(GPSR_vars.axes_wave, [min(timeseries) max(timeseries) data_min data_max]);
    % axis(GPSR_vars.axes_wave, 'tight');
    axis(GPSR_vars.axes_wave, 'on');
    % clear data_show;
end

%% Do for each Local Region

if(metric.regional)
    warndlg('Not ready use local regions');
    return
end

%% Limit the time and set single values for each vertex

fprintf('\ttime window averaging\n');

% Regularize the Norm
if(strcmp(type, 'sim'))
    data = -data;
end

if(N_timewindows > 1) % Combining multiple windows
    data2 = zeros(size(data, 1), N_timewindows);
    for i = 1:N_timewindows
        data_w = data(:, samp_start(i):samp_stop(i));
            
        switch metric.time.comp
            case 1; data_w = mean(data_w, 2);
            case 2; data_w = median(data_w, 2);
            case 3; data_w = max(data_w, [], 2);
        end

        data2(:, i) = data_w;
    end

    data = data2;
    clear data2 data_w;
    
    switch metric.time.comp2
        case 1; data = mean(data, 2);
        case 2; data = median(data, 2);
        case 3; data = max(data, [], 2);
    end
    
%     set(GPSR_vars.metrics_time_comp2, 'enable', 'on');
else % there is only the one time window
    data = data(:, samp_start:samp_stop);
    
    switch metric.time.comp
        case 1; data = mean(data, 2);
        case 2; data = median(data, 2);
        case 3; data = max(data, [], 2);
    end
    
%     set(GPSR_vars.metrics_time_comp2, 'enable', 'off');
end

% Regularize the Norm
if(strcmp(type, 'sim'))
    switch metric.sim.norm
        case 1; data = data;
        case 2; data = -sqrt(-data);
    end
end

metric.data.decVerts = data;

%% Do additional Similarity computations

brain = getappdata(GPSR_vars.datafig, 'brain');

if(strcmp(type, 'sim'))
    fprintf('\tcomputing additional similarity computations\n');

    data = data * (1 - metric.sim.act_weight - metric.sim.local_weight);
    fprintf('\t\tsim:\tmean=%1.3f\tmin=%1.3f\tmax=%1.3f\n', mean(data), min(data), max(data));
    
    % Add activity?
    if(metric.sim.act_weight > 0)
        switch metric.sim.act
            case 1; act = getappdata(GPSR_vars.datafig, 'mne');
            case 2; act = getappdata(GPSR_vars.datafig, 'plv');
            case 3; act = getappdata(GPSR_vars.datafig, 'custom');
            case 4; act = getappdata(GPSR_vars.datafig, 'maxact');
        end
        
        act = act.data.decVerts;
        act = act - act(point.decIndex);
        act = act / std(act);
        act = act / 4;
%         act = sqrt(abs(act)) .* (1 - 2 .* (act < 0));
        fprintf('\t\tact:\tmean=%1.3f\tmin=%1.3f\tmax=%1.3f\n', mean(act), min(act), max(act));
        data = data + act * metric.sim.act_weight;
    end
    
    % Add locality?
    if(metric.sim.local_weight > 0)
        spatial = -distL2(brain.origcoords(point.index, :), brain.origcoords(brain.decIndices, :));
        spatial = spatial - max(spatial);
        spatial = spatial / std(spatial);
        fprintf('\t\tspatial:\tmean=%1.3f min=%1.3f\tmax=%1.3f\n', mean(spatial), min(spatial), max(spatial));
        data = data + spatial * metric.sim.local_weight;
    end
    
    metric.data.simDecVerts = data;
    data = 10 + data; % adjust for smoothing
    
    %% Plot Similar Waves

    if(flag_figures)
        fprintf('\tplot similar waves\n');
        
        figure(6758)
        set(gcf, 'Name', 'sim waves for GPS plot');
        set(gcf, 'Numbertitle', 'off');
        axes_wave2 = subplot(2, 1, 1);
        cla(axes_wave2);
        hold(axes_wave2, 'on');
        %     title(axes_wave2, [type ' time windows, mean, median, and .25/.75 quantiles']);
        
        thresh = str2double(get(GPSR_vars.metrics_vis_t3, 'String'));
        wave_point = metric.data.stnd(data == 10, :);
        wave_group = metric.data.stnd(data > (10 + thresh), :);
        
        data_min = min(min([wave_point; wave_group]));
        data_max = max(max([wave_point; wave_group]));
        
        for i = 1:N_timewindows
            fill([start(i) start(i) stop(i) stop(i)],...
                [data_min data_max data_max data_min],...
                [.9 1 .9],...
                'Parent', axes_wave2,...
                'HitTest', 'off');
        end
        
        % plot(timeseries, data,...
        %     'Parent', GPSR_vars.axes_wave,...
        %     'HitTest', 'off');
        % waveheat(wave_point);
        line(timeseries, wave_group,...
            'Color', [0 .75 .75],...
            'Parent', axes_wave2,...
            'HitTest', 'off',...
            'LineWidth', 1);
        line(timeseries, wave_point,...
            'Color', [0 .75   0],...
            'Parent', axes_wave2,...
            'HitTest', 'off',...
            'LineWidth', 2);
        
        for i = 1:N_timewindows
            line([start(i) start(i)], [data_min data_max],...
                'Color', 'g',...
                'Parent', axes_wave2,...
                'HitTest', 'off');
            line([stop(i) stop(i)], [data_min data_max],...
                'Color', 'g',...
                'Parent', axes_wave2,...
                'HitTest', 'off');
        end
        
        axis(axes_wave2, [min(timeseries) max(timeseries) data_min data_max]);
        % axis(GPSR_vars.axes_wave, 'tight');
        axis(axes_wave2, 'on');
    end
end % If similarity

%% 

%% Apply to whole cortical surface for visualizing

fprintf('\tsmoothing over whole cortex\n');

% Left Brain
measure = zeros(brain.N,1);
measure(brain.decIndices) = data;

face = brain.lface;
coords = brain.origcoords(1:brain.N_L,:);
ldata = measure(1:brain.N_L);
ldata = rois_metrics_smooth(ldata, face', coords');
% ldata = inverse_smooth('','value',ldata,'step',5,'face',double(face'-1),'vertex',coords');

% Right Brain
face = brain.rface;
coords = brain.origcoords((brain.N_L+1):end,:);
rdata = measure((brain.N_L+1):end);
rdata = rois_metrics_smooth(rdata, face', coords');

% Synthesize
metric.data.cort = [ldata; rdata];
if(strcmp(type, 'sim')) metric.data.cort = metric.data.cort - 10; end

% Update the data fig
setappdata(GPSR_vars.datafig, type, metric);

%% Update GUI buttons

% Unlock some buttons
button = sprintf('quick_%s', type);
set(GPSR_vars.(button), 'Enable', 'on');

% Update the GUI
% guidata(hObject, GPSR_vars);
rois_metrics_thresh(hObject, GPSR_vars);

fprintf('\tdone\n');
            
end % function