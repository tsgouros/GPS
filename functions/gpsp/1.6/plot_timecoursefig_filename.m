function filename = plot_timecoursefig_filename(GPSP_vars, varargin)
% Determines the filename for an image given the current state of the
% system, for the timecourse plot
%
% Author: Conrad Nied
%
% Input: GPSP variables structure
% Output: String with filename
%
% Date Created: 2012.09.09 from plot_image_filename
% Last Modified: 2012.09.10

filename = sprintf('%s_%s%s',...
    GPSP_vars.study, GPSP_vars.condition, GPSP_vars.set);

if(nargin == 2)
    movie = varargin{1};
else
    movie = '';
end

filename = sprintf('%s_timecourse', filename);

%% Add the settings

% Significance/Threshold
if(get(GPSP_vars.cause_signif, 'Value'))
    threshold = get(GPSP_vars.cause_quantile, 'String');
    threshold(threshold == '.') = 'p';
    filename = sprintf('%s_q%s', filename, threshold);
else
    threshold = get(GPSP_vars.cause_threshold, 'String');
    threshold(threshold == '.') = 'p';
    filename = sprintf('%s_t%s', filename, threshold);
end % If significance

% Options
add = '';
if(get(GPSP_vars.cause_signif, 'Value'))
    add = [add 'S'];
end
if(get(GPSP_vars.cause_threshold_showp, 'Value'))
    add = [add 'P'];
end
if(get(GPSP_vars.wave_iceberg, 'Value'))
    add = [add 'I'];
end
if(get(GPSP_vars.wave_reflections, 'Value'))
    add = [add 'R'];
end
if(get(GPSP_vars.wave_scale, 'Value') == 2)
    add = [add 'L'];
end
if(get(GPSP_vars.wave_axislim, 'Value') == 1)
    add = [add 'X'];
end

if(~isempty(add))
    filename = sprintf('%s_%s', filename, add);
end % If we are adding something

%% Add the interactions

labels = get(GPSP_vars.wave_list, 'String');
i_labels = get(GPSP_vars.wave_list, 'Value');

% Add each interaction (After formatting)
for i_label = i_labels
    label = labels{i_label};
    label(label == ' ') = [];
    label(label == '-') = [];
    label(label == '>') = '-';
    filename = sprintf('%s_%s', filename, label);
end

%% Display

switch get(GPSP_vars.display_bg, 'Value')
    case 1
        filename = sprintf('%s_bgW', filename);
    case 3
        filename = sprintf('%s_bgQ', filename);
    case 4
        filename = sprintf('%s_bgK', filename);
end % which background?

end % function