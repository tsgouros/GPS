function gpsp_draw_timecourse(draw)
% Plots wave data from granger
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Input: The drawing data
% Output: none (makes a graph)
%
% Changelog:
% 2013-01-23 Created as GPS1.7/gpsp function out of plot_wave_draw
% 2013-02-04 Finished the primary implementation of the function
% 2013-08-05 GPS1.8, made to work with GPS: Plotting

%% Fill in unknown data

if(~isfield(draw, 'values')); error('Must provide data values'); end
if(~isfield(draw, 'criteria')); draw.criteria = zeros(size(draw.values)); end
if(sum(size(draw.values) ~= size(draw.criteria)) > 0); error('Values and Criteria matrices have different sizes'); end

% Time
if(~isfield(draw, 'time')); draw.time = 0:(size(draw.values, 2) - 1); end
if(~isfield(draw, 'timedisp')); draw.timedisp = draw.time; end

% Labels
if(~isfield(draw, 'labels'))
    for i = 1:size(draw.values, 1)
        draw.labels{i} = [' ', 'A' + i - 1, ' '];
    end
end

% Figure Properties
if(~isfield(draw, 'fig')); draw.fig = 'd'*26*26*26+'r'*26*26+'a'*26+'w'; end
if(~isfield(draw, 'N_axes')); draw.N_axes = 1; end
if(~isfield(draw, 'bgcolor')); draw.bgcolor = [1 1 1]; end
if(~isfield(draw, 'fgcolor')); draw.fgcolor = ~sum(draw.bgcolor) * [1 1 1]; end
if(~isfield(draw, 'font')); draw.font = 'Helvetica'; end
if(~isfield(draw, 'legend')); draw.legend = 'Off'; end
if(~isfield(draw, 'title')); draw.title = ''; end
if(~isfield(draw, 'xlabel')); draw.xlabel = 'Time (ms)'; end
% if(~isfield(draw, 'ylabel')); draw.ylabel = ''; end
if(~isfield(draw, 'xlim')); draw.xlim = []; end
if(~isfield(draw, 'ylim')); draw.ylim = []; end
if(~isfield(draw, 'colors_fill')); draw.colors_fill = hsv(size(draw.values,1)); end
if(~isfield(draw, 'colors_line')); draw.colors_line = draw.colors_fill * 0.8; end

% Flags
if(~isfield(draw, 'flag_tipsonly')); draw.flag_tipsonly = 0; end
if(~isfield(draw, 'flag_fill')); draw.flag_fill = 1; end
if(~isfield(draw, 'flag_reflect')); draw.flag_reflect = 0; end
if(~isfield(draw, 'flag_sigspikes')); draw.flag_sigspikes = 0; end
if(~isfield(draw, 'flag_pvals')); draw.flag_pvals = 0; end
if(~isfield(draw, 'flag_logscale')); draw.flag_logscale = 0; end
if(~isfield(draw, 'flag_flipydir')); draw.flag_flipydir = 0; end
if(~isfield(draw, 'flag_yaxisright')); draw.flag_yaxisright = 0; end
if(~isfield(draw, 'flag_belowcriteria')); draw.flag_belowcriteria = draw.flag_pvals; end

if(~isfield(draw, 'flag_values')); draw.flag_values = 1; end
if(~isfield(draw, 'flag_criteria')); draw.flag_criteria = 1; end

%% Format the values

% Get general features
[N_waves, N_time] = size(draw.values);

% Erase the lower part of the curve
if(draw.flag_tipsonly)
    if(draw.flag_belowcriteria)
        data_filter = find(draw.values(:) > draw.criteria(:));
    else
        data_filter = find(draw.values(:) < draw.criteria(:));
    end
    draw.values(data_filter) = draw.criteria(data_filter);
end

% Get fill data
draw.fill = draw.values;
if(draw.flag_belowcriteria)
    draw.fill(draw.fill > draw.criteria) = draw.criteria(draw.fill > draw.criteria);
else
    draw.fill(draw.fill < draw.criteria) = draw.criteria(draw.fill < draw.criteria);
end

% % Report fill area
% fill_area = mean(fill_data, 2);
% fprintf('GCI Area per second\n');
% for i_pair = 1:length(fill_area);
%     fprintf('\t%s area = %4.2f\n', wavelabels{i_pair}, fill_area(i_pair) * 1000);
% end
% fprintf('\n');

% Reflect
if(draw.flag_reflect)
    draw.values(N_waves/2 + 1 : end, :)   = -draw.values(N_waves/2 + 1 : end, :);
    draw.criteria(N_waves/2 + 1 : end, :) = -draw.criteria(N_waves/2 + 1 : end, :);
    if(draw.flag_fill)
        draw.fill(N_waves/2 + 1 : end, :) = -draw.fill(N_waves/2 + 1 : end, :);
    end
    
%     if(get(GPSP_vars.cause_signif, 'Value') && ~get(GPSP_vars.cause_threshold_showp, 'Value'))
%         data_gci(N_pairs/2 + 1 : end, :) = -data_gci(N_pairs/2 + 1 : end, :);
%         data_criterion(N_pairs/2 + 1 : end, :) = -data_criterion(N_pairs/2 + 1 : end, :);
%         fill_data(N_pairs/2 + 1 : end, :) = -fill_data(N_pairs/2 + 1 : end, :);
%     else
%         data_gci(1 : N_pairs/2, :) = data_gci(1 : N_pairs/2, :) - data_criterion(1 : N_pairs/2, :);
%         fill_data(1 : N_pairs/2, :) = fill_data(1 : N_pairs/2, :) - data_criterion(1 : N_pairs/2, :);
%         data_criterion_scalar = data_criterion(1,1);
%         data_criterion(1 : N_pairs/2, :) = 0;
%         data_gci(N_pairs/2 + 1 : end, :) = data_criterion(N_pairs/2 + 1 : end, :) - data_gci(N_pairs/2 + 1 : end, :);
%         fill_data(N_pairs/2 + 1 : end, :) = data_criterion(N_pairs/2 + 1 : end, :) - fill_data(N_pairs/2 + 1 : end, :);
%         data_criterion(N_pairs/2 + 1 : end, :) = 0;
%     end
end
%% Plot the data

% Configure the figure
if(ishandle(draw.fig))
    figure(draw.fig);
    clf(draw.fig);
else
    figure(draw.fig);
    set(draw.fig, 'Name', 'Timecourses');
    set(draw.fig, 'Numbertitle', 'off');
    set(draw.fig, 'Units', 'Pixels');
end

% Always make background white
set(draw.fig, 'Color', draw.bgcolor);

% fill_data = [zeros(size(draw.fill, 1), 1) draw.fill zeros(size(draw.fill, 1), 2) draw.criteria zeros(size(draw.fill, 1), 1)]';

if (min(draw.criteria) >= max(draw.fill))
  fill_data = [flipud(draw.criteria) (draw.fill + 1.0e-6)]';
  circ.time = [fliplr(draw.time(1) + (0:(N_time-1))) (draw.time(1) + (0:(N_time-1)))];
else
  fill_data = [draw.criteria flipud(draw.fill - 1.0e-6)]';
  circ.time = [(draw.time(1) + (0:(N_time-1))) fliplr(draw.time(1) + (0:(N_time-1)))];
end


% Increment the data so nothing is 0, this will help log scale plots
if(isfield(draw, 'ylim'))
    epsilon = max(1e-6, draw.ylim(1));
else
    epsilon = 1e-6;
end

if(draw.flag_logscale)
    fill_data(fill_data <= epsilon) = epsilon;
    draw.values(draw.values <= epsilon) = epsilon;
    draw.criteria(draw.criteria <= epsilon) = epsilon;
else
    fill_data(fill_data <= epsilon & fill_data >= 0) = epsilon;
    draw.values(draw.values <= epsilon & draw.values >= 0) = epsilon;
    draw.criteria(draw.criteria <= epsilon & draw.criteria >= 0) = epsilon;
end

% Draw Axes
for i_axes = 1:draw.N_axes
    
    % Configure the Window
    if(draw.N_axes == 1)
        draw.axes = axes('Parent', draw.fig); %#ok<LAXES>
        set(draw.axes, 'Units', 'Normalized');
        set(draw.axes, 'Position', [.1 .1 0.8 0.8]);
        
        axes_waves = 1:N_waves;
    else
        figure(draw.fig);
        draw.axes = subplot(draw.N_axes, 1, i_axes);
        
        N_pairs_paxe = ceil(N_waves/draw.N_axes);
        axes_waves = (i_axes - 1) * N_pairs_paxe + (1:N_pairs_paxe);
        axes_waves(axes_waves > N_waves) = [];
%         set(draw.axes, 'Units', 'Normalized');
%         set(draw.axes, 'Position', [.15 1-(i_axes*.15) .8 .10])
%         set(draw.axes, 'Position', [.15 1-(i_axes*.11) .8 .07])
%         set(draw.axes, 'Position', [.15 1-(i_axes*.043) .8 .043])
    end
    
    axis(draw.axes, 'on');
    hold(draw.axes, 'on');
    if(isempty(axes_waves))
        break;
    end
    
    if(draw.flag_logscale)
        set(draw.axes, 'YScale', 'log')
    else
        set(draw.axes, 'YScale', 'linear')
    end
    
    if draw.flag_flipydir
        set(draw.axes, 'YDir', 'reverse')
    else
        set(draw.axes, 'YDir', 'normal')
    end
    
    hold(draw.axes, 'on');
    
    % Set the background color
    set(draw.axes, 'Color', draw.bgcolor);
    set(draw.axes, 'XColor', draw.fgcolor);
    set(draw.axes, 'YColor', draw.fgcolor);
    set(draw.axes, 'FontName', draw.font);
    
    % Determine Coloring
%     colormap(GPSP_vars.display_timecourseaxes, repmat([0 .9 0], N_pairs, 1));
% cmap = hsv(N_waves);
% cmap = [0:(1/(N_waves-1)):1; 1:(-1/(N_waves-1)):0; zeros(1, N_waves)]';
% if(N_waves == 1); cmap = [.6 .6 .6]; end
    colormap(draw.axes, draw.colors_fill);
    colors_fill = draw.colors_fill; % Doesn't work yet
    colors_line = draw.colors_line;
%     if(sum(colors_fill(:)) == 0)
%         colors_line = ones(size(colors_fill)) * 0.5;
%     end
    
    % Fill
    if(draw.flag_fill)
        for i_wave = axes_waves
            fill(circ.time,...
                fill_data(:, i_wave)',...
                colors_fill(i_wave, :),...
                'LineStyle', 'none',...
                'Parent', draw.axes);
        end
    end
    
    % Legend
    if(strcmp(draw.legend, 'Off'))
        legend(draw.axes, draw.legend);
    else
        switch draw.legend
            case 'SEOutside'; draw.legend = 'Southeastoutside';
            case 'NEOutside'; draw.legend = 'Northeastoutside';
        end
        legend(draw.axes, draw.labels(axes_waves),...
            'Location', draw.legend,...
            'FontSize', 16,...
            'EdgeColor', draw.fgcolor,...
            'TextColor', draw.fgcolor);
    end
    
    % Draw Significance Spikes
    if(draw.flag_sigspikes)
        for i_wave = axes_waves
            if(draw.flag_belowcriteria)
                sigareas = draw.values(i_wave, :) < draw.criteria(i_wave, :);
            else
                sigareas = draw.values(i_wave, :) > draw.criteria(i_wave, :);
            end
            if(draw.flag_pvals)
                bounds = [epsilon 1];
            else
                minsig = min([draw.values(:); draw.criteria(:)]) + epsilon;
                maxsig = max([draw.values(:); draw.criteria(:)]);
                bounds = [minsig maxsig];
            end
            for i_line = find(sigareas)
                linecolor = [.5 .5 1];
                %                     linecolor = [mod(i_wave,2)==1 0 mod(i_wave,2)==0];
                line([draw.time(i_line) draw.time(i_line)],...
                    bounds,...
                    'Color', linecolor,...
                    'Parent', draw.axes);
            end % for each timepoint with significant areas
        end % for each wave plot
    end % if we are drawing significant area spikes
    
    set(draw.axes, 'FontSize', 16);
    
%     % Axis limits
%     switch get(GPSP_vars.wave_axislim, 'Value')
%         case 1 % fixed
%             if(get(GPSP_vars.cause_threshold_showp, 'Value')) % P Values
%                 
%                 if(get(GPSP_vars.wave_iceberg, 'Value') && ~get(GPSP_vars.wave_reflections, 'Value'))
%                     if(get(GPSP_vars.wave_scale, 'Value') == 1)
%                         ylim(draw.axes, [0 0.05])
%                     else
%                         ylim(draw.axes, [0.001 0.1])
%                     end
%                 else
%                     ylim(draw.axes, [0 1])
%                 end
%             else
%                 if(get(GPSP_vars.wave_iceberg, 'Value') && ~get(GPSP_vars.wave_reflections, 'Value'))
%                     %             ylim(GPSP_vars.display_timecourseaxes, [min(data_criterion(:)) 1])
%                     ylim(draw.axes, [0 1])
%                 else
%                     ylim(draw.axes, [-1 1])
%                 end
%             end
%         case 2 % automatic
%     end % on the axis fix
    
    if(~isempty(draw.xlim))
        xlim(draw.axes, draw.xlim)
    else
        xlim(draw.axes, [draw.time(1), draw.time(end)])
    end
    if(~isempty(draw.ylim))
        if(~draw.flag_reflect)
            ylim(draw.axes, draw.ylim)
        else
            ylim(draw.axes, [-draw.ylim(2) draw.ylim(2)])
        end
    end
    if(draw.flag_yaxisright)
        set(draw.axes, 'YAxisLocation', 'right');
    end
    
    % Chart Labels
    if(i_axes == 1)
        title(draw.axes, draw.title)
    end
    
    if(i_axes == draw.N_axes)
        xlabel(draw.axes, draw.xlabel)
    else
        set(draw.axes, 'xcolor',[1 1 1], 'xtick',[])
    end
    
    if(~isfield(draw, 'ylabel'))
        if(draw.flag_pvals) % P Values
            ylabel(draw.axes, 'p-value');
        else
            ylabel(draw.axes, 'Granger Causality Index');
        end
    else
        ylabel(draw.axes, draw.ylabel);
    end
        
    
%     if(get(GPSP_vars.rois_aparc_color, 'Value'))
%         for i_pair = axes_waves
%             srcroi = rois(i_srcs(i_pair));
%             snkroi = rois(i_snks(i_pair));
%             roicolor = srcroi.aparcColor + snkroi.aparcColor;
%             roicolor = mod(roicolor, 1)';
%             
%             line(tstart + (1:N_time) - 1,...
%                 draw.values(i_pair, :),...
%                 'Color', roicolor,...
%                 'LineStyle','-',...
%                 'LineWidth', 2,...
%                 'Parent', draw.axes)
%             line(tstart + (1:N_time) - 1,...
%                 data_criterion(i_pair, :),...
%                 'Color', roicolor,...
%                 'LineStyle','-.',...
%                 'LineWidth', 2,...
%                 'Parent', draw.axes)
%         end
%     else
        for i_pair = axes_waves
            if(draw.flag_values)
                line(draw.time,...
                    draw.values(i_pair, :),...
                    'Color', colors_line(i_pair, :)',...
                    'LineStyle','-',...
                    'LineWidth', 2,...
                    'Parent', draw.axes)
            end
            if(draw.flag_criteria)
                line(draw.time,...
                    draw.criteria(i_pair, :),...
                    'Color', colors_line(i_pair, :)',...
                    'LineStyle',':',...
                    'LineWidth', 2,...
                    'Parent', draw.axes)
            end
        end
%     end
    
    % Set Ticks for special graphing
    if(draw.flag_tipsonly && draw.flag_reflect)
        ticks = get(draw.axes, 'YTick');
        ticks = abs(ticks);
    else
        ticks = get(draw.axes, 'YTick');
    end
    
    % Format Ticks
    if(sum(mod(ticks*10, 0)))
        tick_fmt = '%1.2f';
    else
        tick_fmt = '%1.1f';
    end
    tick_str = cell(length(ticks), 1);
    for i = 1:length(ticks)
        tick_str{i} = sprintf(tick_fmt', ticks(i));
    end
    set(draw.axes, 'YTickLabel', tick_str)
    
    if(draw.flag_pvals && draw.flag_logscale)
        set(draw.axes, 'YTick', [0.001 0.005 0.01 0.05 0.1 0.5])
        set(draw.axes, 'YTickLabel', {'0.001', '0.005', '0.01', '0.05', '0.1', '0.5'})
    end
    
    if(isfield(draw, 'xlim') && ~isempty(draw.xlim))
        xlim(draw.axes, draw.xlim)
    end
    if(isfield(draw, 'ylim') && ~isempty(draw.ylim))
        if(~draw.flag_reflect)
            ylim(draw.axes, draw.ylim)
        else
            ylim(draw.axes, [-draw.ylim(2) draw.ylim(2)])
        end
    end

end % For each axes

end % function



% OLD FUNCTION 1/29/2021 ON



% function gpsp_draw_timecourse(draw)
% % Plots wave data from granger
% %
% % Author: A. Conrad Nied (conrad.logos@gmail.com)
% %
% % Input: The drawing data
% % Output: none (makes a graph)
% %
% % Changelog:
% % 2013-01-23 Created as GPS1.7/gpsp function out of plot_wave_draw
% % 2013-02-04 Finished the primary implementation of the function
% % 2013-08-05 GPS1.8, made to work with GPS: Plotting
% 
% %% Fill in unknown data
% 
% if(~isfield(draw, 'values')); error('Must provide data values'); end
% if(~isfield(draw, 'criteria')); draw.criteria = zeros(size(draw.values)); end
% if(sum(size(draw.values) ~= size(draw.criteria)) > 0); error('Values and Criteria matrices have different sizes'); end
% 
% % Time
% if(~isfield(draw, 'time')); draw.time = 0:(size(draw.values, 2) - 1); end
% if(~isfield(draw, 'timedisp')); draw.timedisp = draw.time; end
% 
% % Labels
% if(~isfield(draw, 'labels'))
%     for i = 1:size(draw.values, 1)
%         draw.labels{i} = [' ', 'A' + i - 1, ' '];
%     end
% end
% 
% % Figure Properties
% if(~isfield(draw, 'fig')); draw.fig = 'd'*26*26*26+'r'*26*26+'a'*26+'w'; end
% if(~isfield(draw, 'N_axes')); draw.N_axes = 1; end
% if(~isfield(draw, 'bgcolor')); draw.bgcolor = [1 1 1]; end
% if(~isfield(draw, 'fgcolor')); draw.fgcolor = ~sum(draw.bgcolor) * [1 1 1]; end
% if(~isfield(draw, 'font')); draw.font = 'Helvetica'; end
% if(~isfield(draw, 'legend')); draw.legend = 'Off'; end
% if(~isfield(draw, 'title')); draw.title = ''; end
% if(~isfield(draw, 'xlabel')); draw.xlabel = 'Time (ms)'; end
% % if(~isfield(draw, 'ylabel')); draw.ylabel = ''; end
% if(~isfield(draw, 'xlim')); draw.xlim = []; end
% if(~isfield(draw, 'ylim')); draw.ylim = []; end
% if(~isfield(draw, 'colors_fill')); draw.colors_fill = hsv(size(draw.values,1)); end
% if(~isfield(draw, 'colors_line')); draw.colors_line = draw.colors_fill * 0.8; end
% 
% % Flags
% if(~isfield(draw, 'flag_tipsonly')); draw.flag_tipsonly = 0; end
% if(~isfield(draw, 'flag_fill')); draw.flag_fill = 1; end
% if(~isfield(draw, 'flag_reflect')); draw.flag_reflect = 0; end
% if(~isfield(draw, 'flag_sigspikes')); draw.flag_sigspikes = 0; end
% if(~isfield(draw, 'flag_pvals')); draw.flag_pvals = 0; end
% if(~isfield(draw, 'flag_logscale')); draw.flag_logscale = 0; end
% if(~isfield(draw, 'flag_flipydir')); draw.flag_flipydir = 0; end
% if(~isfield(draw, 'flag_yaxisright')); draw.flag_yaxisright = 0; end
% if(~isfield(draw, 'flag_belowcriteria')); draw.flag_belowcriteria = draw.flag_pvals; end
% 
% if(~isfield(draw, 'flag_values')); draw.flag_values = 1; end
% if(~isfield(draw, 'flag_criteria')); draw.flag_criteria = 1; end
% 
% %% Format the values
% 
% % Get general features
% [N_waves, N_time] = size(draw.values);
% 
% % Erase the lower part of the curve
% if(draw.flag_tipsonly)
%     if(draw.flag_belowcriteria)
%         data_filter = find(draw.values(:) > draw.criteria(:));
%     else
%         data_filter = find(draw.values(:) < draw.criteria(:));
%     end
%     draw.values(data_filter) = draw.criteria(data_filter);
% end
% 
% % Get fill data
% draw.fill = draw.values;
% if(draw.flag_belowcriteria)
%     draw.fill(draw.fill > draw.criteria) = draw.criteria(draw.fill > draw.criteria);
% else
%     draw.fill(draw.fill < draw.criteria) = draw.criteria(draw.fill < draw.criteria);
% end
% 
% % % Report fill area
% % fill_area = mean(fill_data, 2);
% % fprintf('GCI Area per second\n');
% % for i_pair = 1:length(fill_area);
% %     fprintf('\t%s area = %4.2f\n', wavelabels{i_pair}, fill_area(i_pair) * 1000);
% % end
% % fprintf('\n');
% 
% % Reflect
% if(draw.flag_reflect)
%     draw.values(N_waves/2 + 1 : end, :)   = -draw.values(N_waves/2 + 1 : end, :);
%     draw.criteria(N_waves/2 + 1 : end, :) = -draw.criteria(N_waves/2 + 1 : end, :);
%     if(draw.flag_fill)
%         draw.fill(N_waves/2 + 1 : end, :) = -draw.fill(N_waves/2 + 1 : end, :);
%     end
%     
% %     if(get(GPSP_vars.cause_signif, 'Value') && ~get(GPSP_vars.cause_threshold_showp, 'Value'))
% %         data_gci(N_pairs/2 + 1 : end, :) = -data_gci(N_pairs/2 + 1 : end, :);
% %         data_criterion(N_pairs/2 + 1 : end, :) = -data_criterion(N_pairs/2 + 1 : end, :);
% %         fill_data(N_pairs/2 + 1 : end, :) = -fill_data(N_pairs/2 + 1 : end, :);
% %     else
% %         data_gci(1 : N_pairs/2, :) = data_gci(1 : N_pairs/2, :) - data_criterion(1 : N_pairs/2, :);
% %         fill_data(1 : N_pairs/2, :) = fill_data(1 : N_pairs/2, :) - data_criterion(1 : N_pairs/2, :);
% %         data_criterion_scalar = data_criterion(1,1);
% %         data_criterion(1 : N_pairs/2, :) = 0;
% %         data_gci(N_pairs/2 + 1 : end, :) = data_criterion(N_pairs/2 + 1 : end, :) - data_gci(N_pairs/2 + 1 : end, :);
% %         fill_data(N_pairs/2 + 1 : end, :) = data_criterion(N_pairs/2 + 1 : end, :) - fill_data(N_pairs/2 + 1 : end, :);
% %         data_criterion(N_pairs/2 + 1 : end, :) = 0;
% %     end
% end
% %% Plot the data
% 
% % Configure the figure
% if(ishandle(draw.fig))
%     figure(draw.fig);
%     clf(draw.fig);
% else
%     figure(draw.fig);
%     set(draw.fig, 'Name', 'Timecourses');
%     set(draw.fig, 'Numbertitle', 'off');
%     set(draw.fig, 'Units', 'Pixels');
% end
% 
% % Always make background white
% set(draw.fig, 'Color', draw.bgcolor);
% 
% fill_data = [zeros(size(draw.fill, 1), 1) draw.fill zeros(size(draw.fill, 1), 2) draw.criteria zeros(size(draw.fill, 1), 1)]';
% 
% % Increment the data so nothing is 0, this will help log scale plots
% if(isfield(draw, 'ylim'))
%     epsilon = max(1e-6, draw.ylim(1));
% else
%     epsilon = 1e-6;
% end
% 
% if(draw.flag_logscale)
%     fill_data(fill_data <= epsilon) = epsilon;
%     draw.values(draw.values <= epsilon) = epsilon;
%     draw.criteria(draw.criteria <= epsilon) = epsilon;
% else
%     fill_data(fill_data <= epsilon & fill_data >= 0) = epsilon;
%     draw.values(draw.values <= epsilon & draw.values >= 0) = epsilon;
%     draw.criteria(draw.criteria <= epsilon & draw.criteria >= 0) = epsilon;
% end
% 
% % Draw Axes
% for i_axes = 1:draw.N_axes
%     
%     % Configure the Window
%     if(draw.N_axes == 1)
%         draw.axes = axes('Parent', draw.fig); %#ok<LAXES>
%         set(draw.axes, 'Units', 'Normalized');
%         set(draw.axes, 'Position', [.1 .1 0.8 0.8]);
%         
%         axes_waves = 1:N_waves;
%     else
%         figure(draw.fig);
%         draw.axes = subplot(draw.N_axes, 1, i_axes);
%         
%         N_pairs_paxe = ceil(N_waves/draw.N_axes);
%         axes_waves = (i_axes - 1) * N_pairs_paxe + (1:N_pairs_paxe);
%         axes_waves(axes_waves > N_waves) = [];
% %         set(draw.axes, 'Units', 'Normalized');
% %         set(draw.axes, 'Position', [.15 1-(i_axes*.15) .8 .10])
% %         set(draw.axes, 'Position', [.15 1-(i_axes*.11) .8 .07])
% %         set(draw.axes, 'Position', [.15 1-(i_axes*.043) .8 .043])
%     end
%     
%     axis(draw.axes, 'on');
%     hold(draw.axes, 'on');
%     if(isempty(axes_waves))
%         break;
%     end
%     
%     if(draw.flag_logscale)
%         set(draw.axes, 'YScale', 'log')
%     else
%         set(draw.axes, 'YScale', 'linear')
%     end
%     
%     if draw.flag_flipydir
%         set(draw.axes, 'YDir', 'reverse')
%     else
%         set(draw.axes, 'YDir', 'normal')
%     end
%     
%     hold(draw.axes, 'on');
%     
%     % Set the background color
%     set(draw.axes, 'Color', draw.bgcolor);
%     set(draw.axes, 'XColor', draw.fgcolor);
%     set(draw.axes, 'YColor', draw.fgcolor);
%     set(draw.axes, 'FontName', draw.font);
%     
%     % Determine Coloring
% %     colormap(GPSP_vars.display_timecourseaxes, repmat([0 .9 0], N_pairs, 1));
% % cmap = hsv(N_waves);
% % cmap = [0:(1/(N_waves-1)):1; 1:(-1/(N_waves-1)):0; zeros(1, N_waves)]';
% % if(N_waves == 1); cmap = [.6 .6 .6]; end
%     colormap(draw.axes, draw.colors_fill);
%     colors_fill = draw.colors_fill; % Doesn't work yet
%     colors_line = draw.colors_line;
% %     if(sum(colors_fill(:)) == 0)
% %         colors_line = ones(size(colors_fill)) * 0.5;
% %     end
%     
%     % Fill
%     if(draw.flag_fill)
%         for i_wave = axes_waves
%             fill([draw.time(1) + (-1:N_time), flipud(draw.time(1) + (-1:N_time))]',...
%                 fill_data(:, i_wave)',...
%                 colors_fill(i_wave, :),...
%                 'LineStyle', 'none',...
%                 'Parent', draw.axes);
%                 disp('i_wave');
%                 disp(i_wave);
%                 disp('X');
%                 disp([draw.time(1) + (-1:N_time), flipud(draw.time(1) + (-1:N_time))]);
%                 disp('Y');
%                 disp(fill_data(:,i_wave));
%         end
%     end
%     
%     % Legend
%     if(strcmp(draw.legend, 'Off'))
%         legend(draw.axes, draw.legend);
%     else
%         switch draw.legend
%             case 'SEOutside'; draw.legend = 'Southeastoutside';
%             case 'NEOutside'; draw.legend = 'Northeastoutside';
%         end
%         legend(draw.axes, draw.labels(axes_waves),...
%             'Location', draw.legend,...
%             'FontSize', 16,...
%             'EdgeColor', draw.fgcolor,...
%             'TextColor', draw.fgcolor);
%     end
%     
%     % Draw Significance Spikes
%     if(draw.flag_sigspikes)
%         for i_wave = axes_waves
%             if(draw.flag_belowcriteria)
%                 sigareas = draw.values(i_wave, :) < draw.criteria(i_wave, :);
%             else
%                 sigareas = draw.values(i_wave, :) > draw.criteria(i_wave, :);
%             end
%             if(draw.flag_pvals)
%                 bounds = [epsilon 1];
%             else
%                 minsig = min([draw.values(:); draw.criteria(:)]) + epsilon;
%                 maxsig = max([draw.values(:); draw.criteria(:)]);
%                 bounds = [minsig maxsig];
%             end
%             for i_line = find(sigareas)
%                 linecolor = [.5 .5 1];
%                 %                     linecolor = [mod(i_wave,2)==1 0 mod(i_wave,2)==0];
%                 line([draw.time(i_line) draw.time(i_line)],...
%                     bounds,...
%                     'Color', linecolor,...
%                     'Parent', draw.axes);
%             end % for each timepoint with significant areas
%         end % for each wave plot
%     end % if we are drawing significant area spikes
%     
%     set(draw.axes, 'FontSize', 16);
%     
% %     % Axis limits
% %     switch get(GPSP_vars.wave_axislim, 'Value')
% %         case 1 % fixed
% %             if(get(GPSP_vars.cause_threshold_showp, 'Value')) % P Values
% %                 
% %                 if(get(GPSP_vars.wave_iceberg, 'Value') && ~get(GPSP_vars.wave_reflections, 'Value'))
% %                     if(get(GPSP_vars.wave_scale, 'Value') == 1)
% %                         ylim(draw.axes, [0 0.05])
% %                     else
% %                         ylim(draw.axes, [0.001 0.1])
% %                     end
% %                 else
% %                     ylim(draw.axes, [0 1])
% %                 end
% %             else
% %                 if(get(GPSP_vars.wave_iceberg, 'Value') && ~get(GPSP_vars.wave_reflections, 'Value'))
% %                     %             ylim(GPSP_vars.display_timecourseaxes, [min(data_criterion(:)) 1])
% %                     ylim(draw.axes, [0 1])
% %                 else
% %                     ylim(draw.axes, [-1 1])
% %                 end
% %             end
% %         case 2 % automatic
% %     end % on the axis fix
%     
%     if(~isempty(draw.xlim))
%         xlim(draw.axes, draw.xlim)
%     else
%         xlim(draw.axes, [draw.time(1), draw.time(end)])
%     end
%     if(~isempty(draw.ylim))
%         if(~draw.flag_reflect)
%             ylim(draw.axes, draw.ylim)
%         else
%             ylim(draw.axes, [-draw.ylim(2) draw.ylim(2)])
%         end
%     end
%     if(draw.flag_yaxisright)
%         set(draw.axes, 'YAxisLocation', 'right');
%     end
%     
%     % Chart Labels
%     if(i_axes == 1)
%         title(draw.axes, draw.title)
%     end
%     
%     if(i_axes == draw.N_axes)
%         xlabel(draw.axes, draw.xlabel)
%     else
%         set(draw.axes, 'xcolor',[1 1 1], 'xtick',[])
%     end
%     
%     if(~isfield(draw, 'ylabel'))
%         if(draw.flag_pvals) % P Values
%             ylabel(draw.axes, 'p-value');
%         else
%             ylabel(draw.axes, 'Granger Causality Index');
%         end
%     else
%         ylabel(draw.axes, draw.ylabel);
%     end
%         
%     
% %     if(get(GPSP_vars.rois_aparc_color, 'Value'))
% %         for i_pair = axes_waves
% %             srcroi = rois(i_srcs(i_pair));
% %             snkroi = rois(i_snks(i_pair));
% %             roicolor = srcroi.aparcColor + snkroi.aparcColor;
% %             roicolor = mod(roicolor, 1)';
% %             
% %             line(tstart + (1:N_time) - 1,...
% %                 draw.values(i_pair, :),...
% %                 'Color', roicolor,...
% %                 'LineStyle','-',...
% %                 'LineWidth', 2,...
% %                 'Parent', draw.axes)
% %             line(tstart + (1:N_time) - 1,...
% %                 data_criterion(i_pair, :),...
% %                 'Color', roicolor,...
% %                 'LineStyle','-.',...
% %                 'LineWidth', 2,...
% %                 'Parent', draw.axes)
% %         end
% %     else
%         for i_pair = axes_waves
%             if(draw.flag_values)
%                 line(draw.time,...
%                     draw.values(i_pair, :),...
%                     'Color', colors_line(i_pair, :)',...
%                     'LineStyle','-',...
%                     'LineWidth', 2,...
%                     'Parent', draw.axes)
%             end
%             if(draw.flag_criteria)
%                 line(draw.time,...
%                     draw.criteria(i_pair, :),...
%                     'Color', colors_line(i_pair, :)',...
%                     'LineStyle',':',...
%                     'LineWidth', 2,...
%                     'Parent', draw.axes)
%             end
%         end
% %     end
%     
%     % Set Ticks for special graphing
%     if(draw.flag_tipsonly && draw.flag_reflect)
%         ticks = get(draw.axes, 'YTick');
%         ticks = abs(ticks);
%     else
%         ticks = get(draw.axes, 'YTick');
%     end
%     
%     % Format Ticks
%     if(sum(mod(ticks*10, 0)))
%         tick_fmt = '%1.2f';
%     else
%         tick_fmt = '%1.1f';
%     end
%     tick_str = cell(length(ticks), 1);
%     for i = 1:length(ticks)
%         tick_str{i} = sprintf(tick_fmt', ticks(i));
%     end
%     set(draw.axes, 'YTickLabel', tick_str)
%     
%     if(draw.flag_pvals && draw.flag_logscale)
%         set(draw.axes, 'YTick', [0.001 0.005 0.01 0.05 0.1 0.5])
%         set(draw.axes, 'YTickLabel', {'0.001', '0.005', '0.01', '0.05', '0.1', '0.5'})
%     end
%     
%     if(isfield(draw, 'xlim') && ~isempty(draw.xlim))
%         xlim(draw.axes, draw.xlim)
%     end
%     if(isfield(draw, 'ylim') && ~isempty(draw.ylim))
%         if(~draw.flag_reflect)
%             ylim(draw.axes, draw.ylim)
%         else
%             ylim(draw.axes, [-draw.ylim(2) draw.ylim(2)])
%         end
%     end
% 
% end % For each axes
% 
% end % function