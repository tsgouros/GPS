function GPSR_vars = rois_metrics_settings_change(hObject, GPSR_vars)
% Change the settings for a given metric (usually called by a button press)
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI datafig
%
% Date Created: 2012.06.21
% Last Modified: 2012.06.29

%% Get settings from GUI

% Metric Identifier
switch get(GPSR_vars.metrics_list, 'Value')
    case 1; type = 'mne';
    case 2; type = 'plv';
    case 3; type = 'custom';
    case 4; type = 'maxact';
    case 5; type = 'sim';
end

% Load Metric
oldmetric = getappdata(GPSR_vars.datafig, type);
metric    = oldmetric;
metric.type = type;
metric.num = get(GPSR_vars.metrics_list, 'Value');

% Timing
metric.time.start_text = get(GPSR_vars.metrics_time_start, 'String');
metric.time.stop_text  = get(GPSR_vars.metrics_time_stop , 'String');
metric.time.comp       = get(GPSR_vars.metrics_time_comp , 'Value' );
metric.time.comp2      = get(GPSR_vars.metrics_time_comp2, 'Value' );

% Standardizing
metric.stnd.use      = get(GPSR_vars.metrics_standard      , 'Value');
metric.stnd.meanonly = get(GPSR_vars.metrics_standard_mean , 'Value');
metric.stnd.scope    = get(GPSR_vars.metrics_standard_scope, 'Value');

% Regional Option
metric.regional = get(GPSR_vars.metrics_regional, 'Value');

% Visualizing
metric.vis.show  = get(GPSR_vars.metrics_vis_show , 'Value' );
metric.vis.color = get(GPSR_vars.metrics_vis_color, 'Value' );
metric.vis.perc  = get(GPSR_vars.metrics_vis_perc , 'Value' );
metric.vis.t1    = get(GPSR_vars.metrics_vis_t1   , 'String');
metric.vis.t2    = get(GPSR_vars.metrics_vis_t2   , 'String');
metric.vis.t3    = get(GPSR_vars.metrics_vis_t3   , 'String');

% Maximal Activity Specific
if(strcmp(metric.type, 'maxact'))
    metric.basis.one     = get(GPSR_vars.metrics_maxact_basis    , 'Value');
    metric.basis.combine = get(GPSR_vars.metrics_maxact_basis2_on, 'Value');
    metric.basis.two     = get(GPSR_vars.metrics_maxact_basis2   , 'Value');
end

% Similarity Specific
if(strcmp(metric.type, 'sim'))
    metric.sim.point        =            get(GPSR_vars.metrics_sim_centroids , 'Value' ) ;
    metric.sim.norm         =            get(GPSR_vars.metrics_sim_norm      , 'Value' ) ;
    metric.sim.local_weight = str2double(get(GPSR_vars.metrics_sim_locality  , 'String'));
    metric.sim.act          =            get(GPSR_vars.metrics_sim_act       , 'Value' ) ;
    metric.sim.act_weight   = str2double(get(GPSR_vars.metrics_sim_act_weight, 'String'));
end

%% Compute the metric data if the settings have been changed.

% Check if they are different
[isSame, diff] = structcmp(metric, oldmetric);

if((strcmp(type, 'maxact') || strcmp(type, 'sim')) && ~isfield(metric, 'data'))
    setappdata(GPSR_vars.datafig, type, metric);
    rois_metrics_compute(hObject, GPSR_vars);
elseif(~isSame && ~isempty(strfind(diff, 'vis')))
    setappdata(GPSR_vars.datafig, type, metric);
    rois_metrics_thresh(hObject, GPSR_vars);
elseif(~isSame)
    setappdata(GPSR_vars.datafig, type, metric);
    rois_metrics_compute(hObject, GPSR_vars);
else
    rois_metrics_thresh(hObject, GPSR_vars);
end
            
end % function rois_metrics_settings_change

function [isSame, diff] = structcmp(A, B)
% Checks two structures to see if they are the same or no
%
% Author: Conrad Nied
%
% Date Created: 2012.06.21

fs = fields(A);
isSame = 1;
diff = '';

for i_f = 1:length(fs);
    f = fs{i_f};
    if(~strcmp(f, 'data'));
        if(~isfield(B, f))
            isSame = 0;
        elseif(isnumeric(A.(f)))
            if(A.(f) ~= B.(f)); isSame = 0; diff = f; end
        elseif(isstruct(A.(f)))
            [lisSame, ldiff] = structcmp(A.(f), B.(f));
%             if(~lisSame); isSame = 0; diff = [ldiff '.' f]; end
            if(~lisSame); isSame = 0; diff = f; end
        else % String
            if(~strcmp(A.(f), B.(f))); isSame = 0; diff = f; end
        end
    end
end

end % function structcmp
