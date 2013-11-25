function gpsp_draw_tc
% Draws timecourse plot
% 
% Author: A. Conrad Nied (conrad.logos@gmail.com)
% 
% Changelog:
% 2013-07-16 Created GPS1.8/gpsp_draw_tc
% 2013-08-05 Filled out functions
% 2013-08-12 Added fonts

% Get the environment
state = gpsp_get;
if(~get(state.tcs_show, 'Value'))
    return
end

% Get the data and the chart
plotdata = gpsp_get('plotdata');
if(isempty(plotdata))
    return
end

%% Extract Data

% Get pairs to plot
pair_names = get(state.regions_pairs, 'String');
available_pairs = state.region_pairs;
selected_pairs = get(state.regions_pairs, 'Value');
N_pairs = length(selected_pairs);

% GCI or p values?
draw.flag_pvals = get(state.tcs_pvals, 'Value');
if(draw.flag_pvals)
    values = plotdata.p_values;
    criteria = plotdata.p_alpha;
else
    values = plotdata.values;
    criteria = plotdata.alpha;
end

% Data
draw.time = plotdata.tstart:plotdata.tstop;
% draw.timedisp
N_time = length(draw.time);
draw.values = zeros(N_pairs, N_time);
draw.criteria = zeros(N_pairs, N_time);
draw.labels = cell(N_pairs, 1);

if(N_pairs == 0)
    return
end

% Get specific data
for i_pair = 1:N_pairs
    j_pair = selected_pairs(i_pair);
    
    draw.values(i_pair, :)   = squeeze(values(  available_pairs(j_pair, 2), available_pairs(j_pair, 1), :));
    draw.criteria(i_pair, :) = squeeze(criteria(available_pairs(j_pair, 2), available_pairs(j_pair, 1), :));
    draw.labels{i_pair}      = pair_names{j_pair};
end

% Get reflected pair data
draw.flag_reflect = get(state.tcs_reflect, 'Value');
if(draw.flag_reflect)
    for i_pair = 1:N_pairs
        j_pair = selected_pairs(i_pair);
        
        pair_name = pair_names{j_pair};
        pair_center = strfind(pair_name, ' -> ');
        pair_name = sprintf('%2$s ->, %1$s', pair_name(1:pair_center - 1), pair_name(pair_center + 4:end));
        
        draw.values(i_pair + N_pairs, :)   = squeeze(values(  available_pairs(j_pair, 1), available_pairs(j_pair, 2), :));
        draw.criteria(i_pair + N_pairs, :) = squeeze(criteria(available_pairs(j_pair, 1), available_pairs(j_pair, 2), :));
        draw.labels{i_pair + N_pairs}      = pair_name;
    end
end

%% Format Figure

% Figure Properties
draw.fig = gpsp_fig_tc;
draw.N_axes = str2double(get(state.tcs_nplots, 'String'));
draw.bgcolor = gpsp_draw_colors(get(state.tcs_bg, 'Value'));
draw.legend = get(state.tcs_legend, 'String');
draw.legend = draw.legend{get(state.tcs_legend, 'Value')};
draw.font = get(state.tcs_font, 'String');
draw.font = draw.font{get(state.tcs_font, 'Value')};
% draw.title
% draw.xlabel
% draw.ylabel % not supported by gpsp_draw_timecourse
% draw.xlim
draw.ylim = [str2double(get(state.tcs_ymin, 'String')), str2double(get(state.tcs_ymax, 'String'))];
% draw.colors_fill
% draw.colors_line

% Flags
draw.flag_tipsonly      = get(state.tcs_tipsonly,      'Value');
draw.flag_fill          = get(state.tcs_fill,          'Value');
draw.flag_sigspikes     = get(state.tcs_sigspikes,     'Value');
draw.flag_logscale      = get(state.tcs_logscale,      'Value');
draw.flag_flipydir      = get(state.tcs_flipydir,      'Value');
draw.flag_yaxisright    = get(state.tcs_yaxisright,    'Value');

%% Draw the formatted figure

gpsp_draw_timecourse(draw);

end % function