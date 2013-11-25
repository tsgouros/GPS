function plot_wave(GPSP_vars)
% Plots wave data from granger
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream Plotting variables/handle
% Output: 
%
% Date Created: 2012.07.09 from granger_plot_wave
% Last Modified: 2012.08.27
% 2012.10.11 - Loosely adapted to GPS1.7
% return
hObject = GPSP_vars.wave_draw;

%% Get Granger Data
granger = gpsp_get('granger');
rois = gpsp_get('rois');

% Get source/sink selection
[i_snks, i_srcs] = find(GPSP_vars.foci);
pairs_chosen = get(GPSP_vars.wave_list, 'Value');
wavelabels = get(GPSP_vars.wave_list, 'String');
wavelabels = wavelabels(pairs_chosen);
i_snks = i_snks(pairs_chosen);
i_srcs = i_srcs(pairs_chosen);
N_pairs = length(i_snks);

% Reflections
if(get(GPSP_vars.wave_reflections, 'Value'))
    i_snks = [i_snks; i_srcs];
    i_srcs = [i_srcs; i_snks];
    N_pairs = length(i_snks);
    
    wavelabels = cell(N_pairs, 1);
    for i_pair = 1:N_pairs
        wavelabels{i_pair} = sprintf('%s -> %s',...
            rois(i_srcs(i_pair)).name, rois(i_snks(i_pair)).name);
    end
end

% Get time window
tstart = str2double(get(GPSP_vars.frames_windowstart, 'String'));
tstop  = str2double(get(GPSP_vars.frames_windowstop, 'String'));
N_time = tstop - tstart + 1;

%% Make dataset

% Allocate
data_gci = zeros(N_pairs, N_time);
data_criterion = zeros(N_pairs, N_time);

% Get P-Values or GCIs
if ~isfield(granger, 'threshold')
    granger.threshold = 0.25;
end

if(get(GPSP_vars.cause_threshold_showp, 'Value')) % P Values
    data = granger.p_values;
    
    if(get(GPSP_vars.cause_signif, 'Value')) % P Value threshold
        data_basis = ones(size(granger.results)) * granger.quantile;
    else % GCI threshold
        data_basis = granger.uniformthreshold_p_values;
    end
else % GCI
    data = granger.results;
    
    if(get(GPSP_vars.cause_signif, 'Value')) % P Value threshold
        data_basis = granger.alpha_values;
    else % GCI threshold
        data_basis = ones(size(granger.results)) * granger.threshold;
    end
end % If showing p values or GCIs



% Select from the pairs of values
for i_pair = 1:N_pairs
    data_gci(i_pair, :) = data(i_snks(i_pair), i_srcs(i_pair), tstart:tstop);
    data_criterion(i_pair, :) = data_basis(i_snks(i_pair), i_srcs(i_pair), tstart:tstop);
end

%% Format data

% Filter (Iceberg Option)
if(get(GPSP_vars.wave_iceberg, 'Value'))
    data_filter = find(data_gci(:) < data_criterion(:));
    data_gci(data_filter) = data_criterion(data_filter);
end

% Get fill data
fill_data = data_gci;
fill_data(fill_data < data_criterion) = data_criterion(fill_data < data_criterion);

% Report fill area
fill_area = mean(fill_data, 2);
fprintf('GCI Area per second\n');
for i_pair = 1:length(fill_area);
    fprintf('\t%s area = %4.2f\n', wavelabels{i_pair}, fill_area(i_pair) * 1000);
end
fprintf('\n');

% Reflect
if(get(GPSP_vars.wave_iceberg, 'Value') && get(GPSP_vars.wave_reflections, 'Value'))
    if(get(GPSP_vars.cause_signif, 'Value') && ~get(GPSP_vars.cause_threshold_showp, 'Value'))
        data_gci(N_pairs/2 + 1 : end, :) = -data_gci(N_pairs/2 + 1 : end, :);
        data_criterion(N_pairs/2 + 1 : end, :) = -data_criterion(N_pairs/2 + 1 : end, :);
        fill_data(N_pairs/2 + 1 : end, :) = -fill_data(N_pairs/2 + 1 : end, :);
    else
        data_gci(1 : N_pairs/2, :) = data_gci(1 : N_pairs/2, :) - data_criterion(1 : N_pairs/2, :);
        fill_data(1 : N_pairs/2, :) = fill_data(1 : N_pairs/2, :) - data_criterion(1 : N_pairs/2, :);
%         data_criterion(1 : N_pairs/2, :) = data_criterion(1 : N_pairs/2, :) - data_criterion(1 : N_pairs/2, :);
        data_criterion_scalar = data_criterion(1,1);
        data_criterion(1 : N_pairs/2, :) = 0;
        data_gci(N_pairs/2 + 1 : end, :) = data_criterion(N_pairs/2 + 1 : end, :) - data_gci(N_pairs/2 + 1 : end, :);
        fill_data(N_pairs/2 + 1 : end, :) = data_criterion(N_pairs/2 + 1 : end, :) - fill_data(N_pairs/2 + 1 : end, :);
%         data_criterion(N_pairs/2 + 1 : end, :) = data_criterion(N_pairs/2 + 1 : end, :) - data_criterion(N_pairs/2 + 1 : end, :);
        data_criterion(N_pairs/2 + 1 : end, :) = 0;
        
%         fill_data = data_gci;
%         fill_data(fill_data > data_criterion) = data_criterion(fill_data > data_criterion);
%         fill_data(N_pairs/2 + 1 : end, :) = data_gci(N_pairs/2 + 1 : end, :);
%         fill_selection = find(fill_data(N_pairs/2 + 1 : end, :) > data_criterion(N_pairs/2 + 1 : end, :));
%         fill_data(N_pairs/2 +fill_selection) = data_criterion(N_pairs/2 +fill_selection);
    end
end

% Smooth
% smooth = str2double(get(GPSP_vars.wave_smooth, 'String'));
% N_time_smooth = N_time - smooth;
% data_smooth = zeros(N_pairs, N_time_smooth);
% for i_time = 1:N_time_smooth
%     data_smooth(:, i_time) = mean(data(:, i_time + (0:smooth)), 2);
% end

% times_values = repmat(tstart + (0:N_time), N_pairs, 1)';

%% Make the plot

% Configure the figure
if(ishandle(GPSP_vars.display_timecoursefig))
    clf(GPSP_vars.display_timecoursefig);
else
    figure(GPSP_vars.display_timecoursefig);
    set(GPSP_vars.display_timecoursefig, 'Name', 'Timecourses (GPS Plot)');
    set(GPSP_vars.display_timecoursefig, 'Numbertitle', 'off');
    set(GPSP_vars.display_timecoursefig, 'Units', 'Pixels');
end

% Always make background white
set(GPSP_vars.display_timecoursefig, 'Color', [0.702 0.702 0.702]);

% Finish configuring data
% fill_data = [fill_data zeros(size(fill_data, 1), 2) fliplr(data_criterion)]';
% fill_data = [zeros(size(fill_data, 1), 1) fill_data zeros(size(fill_data, 1), 2) data_criterion zeros(size(fill_data, 1), 1)]';
% times_values = [times_values; flipud(times_values)];

% Log align the data?
if(get(GPSP_vars.cause_threshold_showp, 'Value'))
    data_gci = 1 - data_gci;
    data_criterion = 1 - data_criterion;
    fill_data = 1 - fill_data;
end

fill_data = [zeros(size(fill_data, 1), 1) fill_data zeros(size(fill_data, 1), 2) data_criterion zeros(size(fill_data, 1), 1)]';

% Draw Axes
N_axes = str2double(get(GPSP_vars.wave_nplots, 'String'));
for i_axes = 1:N_axes
    
    % Configure the Window
    if(N_axes == 1)
        GPSP_vars.display_timecourseaxes = axes('Parent', GPSP_vars.display_timecoursefig); %#ok<LAXES>
        set(GPSP_vars.display_timecourseaxes, 'Units', 'Normalized');
        set(GPSP_vars.display_timecourseaxes, 'Position', [.1 .1 0.8 0.8]);
        
        pairs = 1:N_pairs;
    else
        figure(GPSP_vars.display_timecoursefig);
%         GPSP_vars.display_timecourseaxes = subplot(N_axes, 1, N_axes - i_axes + 1);
        GPSP_vars.display_timecourseaxes = subplot(N_axes, 1, i_axes);
        
        N_pairs_paxe = ceil(N_pairs/N_axes);
        pairs = (i_axes - 1) * N_pairs_paxe + (1:N_pairs_paxe);
        pairs(pairs > N_pairs) = [];
    end
    
    axis(GPSP_vars.display_timecourseaxes, 'on');
    hold(GPSP_vars.display_timecourseaxes, 'on');
    if(isempty(pairs))
        break;
    end
    
    switch get(GPSP_vars.wave_scale, 'Value')
        case 1 % normal
            set(GPSP_vars.display_timecourseaxes, 'YScale', 'linear')
        case 2 % log
            set(GPSP_vars.display_timecourseaxes, 'YScale', 'log')
    end
    
    if(get(GPSP_vars.cause_threshold_showp, 'Value'))
        set(GPSP_vars.display_timecourseaxes, 'YDir', 'reverse')
    else
        set(GPSP_vars.display_timecourseaxes, 'YDir', 'normal')
    end
    
    % Always make background white
    set(GPSP_vars.display_timecourseaxes, 'Color', [1 1 1]);
    
    % Determine Coloring
%     colormap(GPSP_vars.display_timecourseaxes, repmat([0 .9 0], N_pairs, 1));
cmap = hsv(N_pairs);
% cmap = [0:(1/(N_pairs-1)):1; 1:(-1/(N_pairs-1)):0; zeros(1, N_pairs)]';
if(N_pairs == 1); cmap = [.6 .6 .6]; end
    colormap(GPSP_vars.display_timecourseaxes, cmap);
    colors_fill = colormap(GPSP_vars.display_timecourseaxes); % Doesn't work yet
    colors_line = colormap(GPSP_vars.display_timecourseaxes)*0.8;
    
    % Fill
    if(get(GPSP_vars.rois_aparc_color, 'Value'))
        for i_pair = pairs
            srcroi = rois(i_srcs(i_pair));
            snkroi = rois(i_snks(i_pair));
            roicolor = srcroi.aparcColor + snkroi.aparcColor;
            roicolor = min(mod(roicolor, 1) * 1.25, [1 1 1]);
            
%             size([tstart + (-1:N_time), flipud(tstart + (-1:N_time))]')
%             size(fill_data(:, i_pair))
            fill([tstart + (-1:N_time), flipud(tstart + (-1:N_time))]',...
                fill_data(:, i_pair),...
                roicolor,...
                'LineStyle', 'none',...
                'Parent', GPSP_vars.display_timecourseaxes);
        end
    else
        for i_pair = pairs
            fill([tstart + (-1:N_time), flipud(tstart + (-1:N_time))]',...
                fill_data(:, i_pair)',...
                colors_fill(i_pair, :),...
                'LineStyle', 'none',...
                'Parent', GPSP_vars.display_timecourseaxes);
        end
%         fill(times_values(:, pairs),...
%             fill_data(:, pairs),...
%             pairs,...
%             'LineStyle', 'none',...
%             'Parent', GPSP_vars.display_timecourseaxes);
    end
    
    % Legend
    legend_location = get(GPSP_vars.wave_legend, 'String');
    legend_location = legend_location{get(GPSP_vars.wave_legend, 'Value')};
    if(strcmp(legend_location, 'Off'))
        legend(GPSP_vars.display_timecourseaxes, legend_location);
    else
        switch legend_location
            case 'SEOutside'; legend_location = 'Southeastoutside';
            case 'NEOutside'; legend_location = 'Northeastoutside';
        end
        legend(GPSP_vars.display_timecourseaxes, wavelabels(pairs),...
            'Location', legend_location,...
            'FontSize', 16);
    end
    
    set(GPSP_vars.display_timecourseaxes, 'FontSize', 16);
    
    % Axis limits
    switch get(GPSP_vars.wave_axislim, 'Value')
        case 1 % fixed
            if(get(GPSP_vars.cause_threshold_showp, 'Value')) % P Values
                
                if(get(GPSP_vars.wave_iceberg, 'Value') && ~get(GPSP_vars.wave_reflections, 'Value'))
                    if(get(GPSP_vars.wave_scale, 'Value') == 1)
                        ylim(GPSP_vars.display_timecourseaxes, [0 0.05])
                    else
                        ylim(GPSP_vars.display_timecourseaxes, [0.001 0.1])
                    end
                else
                    ylim(GPSP_vars.display_timecourseaxes, [0 1])
                end
            else
                if(get(GPSP_vars.wave_iceberg, 'Value') && ~get(GPSP_vars.wave_reflections, 'Value'))
                    %             ylim(GPSP_vars.display_timecourseaxes, [min(data_criterion(:)) 1])
                    ylim(GPSP_vars.display_timecourseaxes, [0 1])
                else
                    ylim(GPSP_vars.display_timecourseaxes, [-1 1])
                end
            end
        case 2 % automatic
    end % on the axis fix
    
    xlim(GPSP_vars.display_timecourseaxes, [tstart, tstart + N_time - 1])
    
    % Other labeling
    xlabel(GPSP_vars.display_timecourseaxes, 'Time (ms)')
    if(get(GPSP_vars.cause_threshold_showp, 'Value')) % P Values
        ylabel(GPSP_vars.display_timecourseaxes, 'p-value');
    else
        ylabel(GPSP_vars.display_timecourseaxes, 'Granger Causality Index');
    end
    % title(GPSP_vars.display_timecourseaxes, titlestr);
    
    hold(GPSP_vars.display_timecourseaxes, 'on');
    
    if(get(GPSP_vars.rois_aparc_color, 'Value'))
        for i_pair = pairs
            srcroi = rois(i_srcs(i_pair));
            snkroi = rois(i_snks(i_pair));
            roicolor = srcroi.aparcColor + snkroi.aparcColor;
            roicolor = mod(roicolor, 1)';
            
            line(tstart + (1:N_time) - 1,...
                data_gci(i_pair, :),...
                'Color', roicolor,...
                'LineStyle','-',...
                'LineWidth', 2,...
                'Parent', GPSP_vars.display_timecourseaxes)
            line(tstart + (1:N_time) - 1,...
                data_criterion(i_pair, :),...
                'Color', roicolor,...
                'LineStyle','-.',...
                'LineWidth', 2,...
                'Parent', GPSP_vars.display_timecourseaxes)
        end
    else
        for i_pair = pairs
            line(tstart + (1:N_time) - 1,...
                data_gci(i_pair, :),...
                'Color', colors_line(i_pair, :)',...
                'LineStyle','-',...
                'LineWidth', 2,...
                'Parent', GPSP_vars.display_timecourseaxes)
            line(tstart + (1:N_time) - 1,...
                data_criterion(i_pair, :),...
                'Color', colors_line(i_pair, :)',...
                'LineStyle',':',...
                'LineWidth', 2,...
                'Parent', GPSP_vars.display_timecourseaxes)
        end
    end
    
    % Set Ticks for special graphing
    if(get(GPSP_vars.wave_iceberg, 'Value') && get(GPSP_vars.wave_reflections, 'Value'))
        if(get(GPSP_vars.cause_signif, 'Value'))
            ticks = get(GPSP_vars.display_timecourseaxes, 'YTick');
            ticks = abs(ticks);
        else
            ticks = get(GPSP_vars.display_timecourseaxes, 'YTick');
            ticks = abs(ticks) + data_criterion_scalar;
        end
    else
        ticks = get(GPSP_vars.display_timecourseaxes, 'YTick');
    end
    
    tick_str = cell(length(ticks), 1);
    for i = 1:length(ticks)
        tick_str{i} = sprintf('%1.2f', ticks(i));
    end
    set(GPSP_vars.display_timecourseaxes, 'YTickLabel', tick_str)
    
    if(get(GPSP_vars.cause_threshold_showp, 'Value') && get(GPSP_vars.wave_scale, 'Value') == 2)
        
        ylim(GPSP_vars.display_timecourseaxes, [0.001 0.1])
        set(GPSP_vars.display_timecourseaxes, 'YTick', [0.001 0.005 0.01 0.05 0.1])
        set(GPSP_vars.display_timecourseaxes, 'YTickLabel', {'0.001', '0.005', '0.01', '0.05', '0.1'})
        
    end

end % For each axes

%% Update the GUI
guidata(hObject, GPSP_vars);

end