function GPSR_vars = rois_metrics_settings_load(GPSR_vars, varargin)
% Change the settings for a given metric (usually called by a button press)
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI datafig
%
% Date Created: 2012.06.21
% Last Modified: 2012.06.21

%% Get settings from GUI

% Metric Identifier
num = get(GPSR_vars.metrics_list, 'Value');
switch num
    case 1; type = 'mne';
    case 2; type = 'plv';
    case 3; type = 'custom';
    case 4; type = 'maxact';
    case 5; type = 'sim';
end

% Load Metric
metric = getappdata(GPSR_vars.datafig, type);

% Get variable arguments in
if(~isempty(varargin))
    repanel = varargin{1};
else
    repanel = 1;
end

%% Get Defaults if they do not exist

% Identifiers
if(~isfield(metric, 'num'))
    metric.num = num; end
if(~isfield(metric, 'type'))
    metric.type = type; end

% Timing
if(~isfield(metric, 'time') || ~isfield(metric.time, 'start_text'))
    metric.time.start_text = '100'; end
if(~isfield(metric, 'time') || ~isfield(metric.time, 'stop_text'))
    metric.time.stop_text = '400'; end
if(~isfield(metric, 'time') || ~isfield(metric.time, 'comp'))
    metric.time.comp = 1; end
if(~isfield(metric, 'time') || ~isfield(metric.time, 'comp2'))
    metric.time.comp2 = 3; end

% Standardizing
if(~isfield(metric, 'stnd') || ~isfield(metric.stnd, 'use'))
    if(strcmp(type, 'sim'))
        metric.stnd.use = 1;
    else
        metric.stnd.use = 0;
    end
end
if(~isfield(metric, 'stnd') || ~isfield(metric.stnd, 'meanonly'))
    metric.stnd.meanonly = 0; end
if(~isfield(metric, 'stnd') || ~isfield(metric.stnd, 'scope'))
    if(strcmp(type, 'sim'))
        metric.stnd.scope = 5;
    else
        metric.stnd.scope = 1;
    end
end

% Regional Option
if(~isfield(metric, 'regional'))
    metric.regional = 0; end

% Visualizing
if(~isfield(metric, 'vis') || ~isfield(metric.vis, 'show'))
    metric.vis.show = 1; end
if(~isfield(metric, 'vis') || ~isfield(metric.vis, 'color'))
    switch type
        case 'mne'; metric.vis.color = 1; % Hot
        case 'plv'; metric.vis.color = 2; % Cool
        case 'custom'; metric.vis.color = 7; % Green
        case 'maxact'; metric.vis.color = 6; % Yellow
        case 'sim'; metric.vis.color = 4; % RBG
    end
end
if(~isfield(metric, 'vis') || ~isfield(metric.vis, 'perc'))
    if(strcmp(type, 'sim'))
        metric.vis.perc = 0;
    else
        metric.vis.perc = 1;
    end
end
if(~isfield(metric, 'vis') || ~isfield(metric.vis, 't1'))
    if(strcmp(type, 'sim'))
        metric.vis.t1 = '-1.2';
    else
        metric.vis.t1 = '80';
    end
end
if(~isfield(metric, 'vis') || ~isfield(metric.vis, 't2'))
    if(strcmp(type, 'sim'))
        metric.vis.t2 = '-0.8';
    else
        metric.vis.t2 = '90';
    end
end
if(~isfield(metric, 'vis') || ~isfield(metric.vis, 't3'))
    if(strcmp(type, 'sim'))
        metric.vis.t3 = '-0.5';
    else
        metric.vis.t3 = '95';
    end
end

% Maximal Activity Specific
if(strcmp(metric.type, 'maxact'))
    if(~isfield(metric, 'basis') || ~isfield(metric.basis, 'one'))
        metric.basis.one     = 2; end
    if(~isfield(metric, 'basis') || ~isfield(metric.basis, 'combine'))
        metric.basis.combine = 0; end
    if(~isfield(metric, 'basis') || ~isfield(metric.basis, 'two'))
        metric.basis.two     = 2; end
end

% Similarity Specific
if(strcmp(metric.type, 'sim'))
    if(~isfield(metric, 'sim') || ~isfield(metric.sim, 'point'))
        metric.sim.point = 1; end
    if(~isfield(metric, 'sim') || ~isfield(metric.sim, 'norm'))
        metric.sim.norm = 2; end
    if(~isfield(metric, 'sim') || ~isfield(metric.sim, 'local_weight'))
        metric.sim.local_weight = 0.1; end
    if(~isfield(metric, 'sim') || ~isfield(metric.sim, 'act'))
        metric.sim.act = 1; end % MNE
    if(~isfield(metric, 'sim') || ~isfield(metric.sim, 'act_weight'))
        metric.sim.act_weight = 0.0; end
end

%% Set GUI
% Timing
set(GPSR_vars.metrics_time_start, 'String', metric.time.start_text);
set(GPSR_vars.metrics_time_stop , 'String', metric.time.stop_text);
set(GPSR_vars.metrics_time_comp , 'Value' , metric.time.comp);
set(GPSR_vars.metrics_time_comp2, 'Value' , metric.time.comp2);

% Standardizing
set(GPSR_vars.metrics_standard      , 'Value', metric.stnd.use);
set(GPSR_vars.metrics_standard_mean , 'Value', metric.stnd.meanonly);
set(GPSR_vars.metrics_standard_scope, 'Value', metric.stnd.scope);

% Regional Option
set(GPSR_vars.metrics_regional, 'Value', metric.regional);

% Visualizing
set(GPSR_vars.metrics_vis_show , 'Value' ,  metric.vis.show);
set(GPSR_vars.(['quick_' type]), 'Value' ,  metric.vis.show);
set(GPSR_vars.metrics_vis_color, 'Value' ,  metric.vis.color);
set(GPSR_vars.metrics_vis_perc , 'Value' ,  metric.vis.perc);
set(GPSR_vars.metrics_vis_abs  , 'Value' , ~metric.vis.perc);
set(GPSR_vars.metrics_vis_t1   , 'String',  metric.vis.t1);
set(GPSR_vars.metrics_vis_t2   , 'String',  metric.vis.t2);
set(GPSR_vars.metrics_vis_t3   , 'String',  metric.vis.t3);

% Maximal Activity Specific
if(strcmp(metric.type, 'maxact'))
	set(GPSR_vars.metrics_maxact_basis    , 'Value', metric.basis.one);
    set(GPSR_vars.metrics_maxact_basis2_on, 'Value', metric.basis.combine);
    set(GPSR_vars.metrics_maxact_basis2   , 'Value', metric.basis.two);
end

% Similarity Specific
if(strcmp(metric.type, 'sim'))
    if(max(metric.sim.point) > length(get(GPSR_vars.metrics_sim_centroids, 'String')))
        metric.sim.point = 1;
    end
	set(GPSR_vars.metrics_sim_centroids , 'Value' , metric.sim.point);
	set(GPSR_vars.regions_list          , 'Value' , metric.sim.point);
    set(GPSR_vars.metrics_sim_norm      , 'Value' , metric.sim.norm);
    set(GPSR_vars.metrics_sim_locality  , 'String', num2str(metric.sim.local_weight));
    set(GPSR_vars.regions_spatial       , 'String', num2str(metric.sim.local_weight));
    set(GPSR_vars.metrics_sim_act       , 'Value' , metric.sim.act);
    set(GPSR_vars.regions_act           , 'Value' , metric.sim.act);
    set(GPSR_vars.metrics_sim_act_weight, 'String', num2str(metric.sim.act_weight));
    set(GPSR_vars.regions_act_weight    , 'String', num2str(metric.sim.act_weight));
end

%% Save metric for gaps corrected
setappdata(GPSR_vars.datafig, metric.type, metric);

if(repanel)
    set(GPSR_vars.panels_metrics, 'Value', 1);
    GPSR_vars = rois_panels(GPSR_vars.metrics_list, GPSR_vars);
end

end % function
