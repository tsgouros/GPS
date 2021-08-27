function rois_metrics_thresh(hObject, GPSR_vars)
% Manages thresholds for the GUI
%
% Author: Conrad Nied
%
% Input: The calling object and the Granger Processing Stream ROIs handle
% Output: none, affects the GUI
%
% Date Created: 2012.06.18
% Last Modified: 2012.06.22
% 2013.06.28 - GPS1.8, doesn't draw the figures if autoredraw is off

flag_figures = ~get(GPSR_vars.quick_pauseautoredraw, 'Value');

%% Which button?/type?

% From Button
button = get(hObject, 'tag');
underscores = strfind(button, '_');
if(length(underscores) == 1)
    % 1 underscore
    type = button(underscores(1) + 1 : end);
    op = 'quickon';
else % 2 underscores
    type = button(underscores(1) + 1 : underscores(2) - 1);
    op = button(underscores(2) + 1 : end);
end

% From Metric Panel
num = get(GPSR_vars.metrics_list, 'Value');
switch num
    case 1; active_type = 'mne';
    case 2; active_type = 'plv';
    case 3; active_type = 'custom';
    case 4; active_type = 'maxact';
    case 5; active_type = 'sim';
end

% If the type differs, don't change the gui
guiBased = 0; % as opposed to data based

if(strcmp(type, active_type) || strcmp(type, 'vis'))
    guiBased = 1;
end

% If the type isn't specified, do the current one
if(~sum(strcmp({'mne', 'plv', 'custom', 'maxact', 'sim'}, type)))
    type = active_type;
end

%% Load background dat
metric = getappdata(GPSR_vars.datafig, type);

% Percentage or Value based?
guiPerc = metric.vis.perc;
dispPerc = metric.vis.perc;

if(guiBased)
    if(strcmp(button, 'metrics_vis_perc'))
        guiPerc = 0;
        dispPerc = 1;
    elseif(strcmp(button, 'metrics_vis_abs'))
%     elseif(metric.vis.perc ~= newPerc && newPerc == 0)
        guiPerc = 1;
        dispPerc = 0;
    end
end


% if(strcmp(op, 'perc'))
%     if(get(hObject, 'Value')) % Was 1 so now values
%         set(hObject, 'String', 'Val');
%         isPerc = 1;
%         dispPerc = 0; 
%     else % Was 0 so now percentages
%         set(hObject, 'String', 'Perc');
%         isPerc = 0;
%         dispPerc = 1;
%     end
% else
%     button = sprintf('brain_%s_pv', type);
%     isPerc = ~get(GPSR_vars.(button), 'Value');
%     dispPerc = isPerc;
% end

% Load Measures

%% Find the values/percentages

data = metric.data.cort;

if(guiBased)
    if(guiPerc) % Thresholds are in percentages
        p(1) = str2double(get(GPSR_vars.metrics_vis_t1, 'String'));
        p(2) = str2double(get(GPSR_vars.metrics_vis_t2, 'String'));
        p(3) = str2double(get(GPSR_vars.metrics_vis_t3, 'String'));
        p(4) = 100;

        % Compute the values at these percentiles
        v = prctile(data, p);
    else % Thresholds are in values
        v(1) = str2double(get(GPSR_vars.metrics_vis_t1, 'String'));
        v(2) = str2double(get(GPSR_vars.metrics_vis_t2, 'String'));
        v(3) = str2double(get(GPSR_vars.metrics_vis_t3, 'String'));

        p(1) = sum(data < v(1)) * 100 / length(data);
        p(2) = sum(data < v(2)) * 100 / length(data);
        p(3) = sum(data < v(3)) * 100 / length(data);
        p(4) = 100;
        v(4) = max(data);
    end
else % From the metric data only
    if(guiPerc) % Thresholds are in percentages
        p(1) = str2double(metric.vis.t1);
        p(2) = str2double(metric.vis.t2);
        p(3) = str2double(metric.vis.t3);
        p(4) = 100;

        % Compute the values at these percentiles
        v = prctile(data, p);
    else % Thresholds are in values
        v(1) = str2double(metric.vis.t1);
        v(2) = str2double(metric.vis.t2);
        v(3) = str2double(metric.vis.t3);

        p(1) = sum(data < v(1)) * 100 / length(data);
        p(2) = sum(data < v(2)) * 100 / length(data);
        p(3) = sum(data < v(3)) * 100 / length(data);
        p(4) = 100;
        v(4) = max(data);
    end
end

%% Set the display

if(guiBased && dispPerc) % Show Percentages
    metric.vis.t1 = num2str(p(1));
    metric.vis.t2 = num2str(p(2));
    metric.vis.t3 = num2str(p(3));
    
    set(GPSR_vars.metrics_vis_t1, 'String', metric.vis.t1);
    set(GPSR_vars.metrics_vis_t2, 'String', metric.vis.t2);
    set(GPSR_vars.metrics_vis_t3, 'String', metric.vis.t3);
elseif(guiBased && ~dispPerc) % Show Values
    metric.vis.t1 = num2str(v(1));
    metric.vis.t2 = num2str(v(2));
    metric.vis.t3 = num2str(v(3));
    
    set(GPSR_vars.metrics_vis_t1, 'String', metric.vis.t1);
    set(GPSR_vars.metrics_vis_t2, 'String', metric.vis.t2);
    set(GPSR_vars.metrics_vis_t3, 'String', metric.vis.t3);
end

% Color boxes!
cdata = rois_draw_coloring([1 2 3]', [1 2 3 4], metric.vis.color);
if(guiBased)
    
    set(GPSR_vars.metrics_vis_t1, 'BackgroundColor', cdata(1, :));
    if(sum(cdata(1, :) .^ 2) < 0.5)
        set(GPSR_vars.metrics_vis_t1, 'ForegroundColor', [1 1 1]);
    else
        set(GPSR_vars.metrics_vis_t1, 'ForegroundColor', [0 0 0]);
    end
    
    set(GPSR_vars.metrics_vis_t2, 'BackgroundColor', cdata(2, :));
    if(sum(cdata(2, :) .^ 2) < 0.5)
        set(GPSR_vars.metrics_vis_t2, 'ForegroundColor', [1 1 1]);
    else
        set(GPSR_vars.metrics_vis_t2, 'ForegroundColor', [0 0 0]);
    end
    
    set(GPSR_vars.metrics_vis_t3, 'BackgroundColor', cdata(3, :));
    if(sum(cdata(3, :) .^ 2) < 0.5)
        set(GPSR_vars.metrics_vis_t3, 'ForegroundColor', [1 1 1]);
    else
        set(GPSR_vars.metrics_vis_t3, 'ForegroundColor', [0 0 0]);
    end
end

%% Draw a histogram of this recent plot

if(flag_figures)
    figure(metric.num + 6752)
    GPSR_vars.axes_histogram = subplot(2, 1, 2);
    cla(GPSR_vars.axes_histogram);
    hold(GPSR_vars.axes_histogram, 'on');
    title(GPSR_vars.axes_histogram, [type ' histogram']);
    
    % Get containers
    N_buckets = 400;
    N_samples = length(data);
    data_min = min(data);
    data_max = max(data);
    data_step = (data_max - data_min) / N_buckets;
    data_buckets = data_min:data_step:data_max;
    
    % Get histogram values
    data_histogram = hist(data, data_buckets);
    hist_min = min(data_histogram);
    hist_max = max(data_histogram);
    
    % Plot Histogram
    % cla(GPSR_vars.axes_histogram);
    bargraph = bar(data_buckets, data_histogram,...
        'Parent', GPSR_vars.axes_histogram,...
        'HitTest', 'off',...
        'FaceColor', [0.5 0.5 0.5]);
    hold(GPSR_vars.axes_histogram,'on');
    
    % Plot histogram margins
    line([v(1) v(1)],...
        [hist_min hist_max],...
        'Color', cdata(1, :),...
        'Parent', GPSR_vars.axes_histogram,...
        'HitTest', 'off');
    
    line([v(2) v(2)],...
        [hist_min hist_max],...
        'Color', cdata(2, :),...
        'Parent', GPSR_vars.axes_histogram,...
        'HitTest', 'off');
    
    line([v(3) v(3)],...
        [hist_min hist_max],...
        'Color', cdata(3, :),...
        'Parent', GPSR_vars.axes_histogram,...
        'HitTest', 'off');
    
    xlim(GPSR_vars.axes_histogram, [data_min data_max]);
    ylim(GPSR_vars.axes_histogram, [hist_min hist_max]);
    guidata(GPSR_vars.data_subject_list, GPSR_vars);
    axis(GPSR_vars.axes_histogram, 'on');
end

%% Save to datafig and GUI; and draw

metric.data.p = p;
metric.data.v = v;

setappdata(GPSR_vars.datafig, type, metric);

guidata(hObject, GPSR_vars);
GPSR_vars = rois_draw(GPSR_vars);

end % function
