function GPSP_vars = plot_act_compose(GPSP_vars)
% Compose map of brain activation data
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream Plotting variables/handle
% Output: none, refreshes the GPSP_vars figure
%
% Date Created: 2012.07.05 from granger_plot_act_compose
% Last Modified: 2012.07.10
% 2012.10.11 - Loosely adapted to GPS1.7

hObject = GPSP_vars.act_compose;

%% Acquire Data
brain = gpsp_get('brain');
act = gpsp_get('act');

start = str2double(get(GPSP_vars.act_time_start, 'String'));
stop = str2double(get(GPSP_vars.act_time_stop, 'String'));
if(stop < start); stop = start; end

start = max(1, find(act.sample_times > start/1000, 1, 'first') - 1);
stop = min(size(act.data_raw, 2), find(act.sample_times < stop/1000, 1, 'last') + 1);

%% Baselining (optional, add button for this)
data = act.data_raw;

sample_zero = find(act.sample_times > 0.1, 1, 'first') - 1;
sample_zero = 1;
base_mean =   mean(data(:, 1:sample_zero),    2);
base_std  =    std(data(:, 1:sample_zero), 0, 2);
base_mean = repmat(base_mean, 1, length(act.sample_times));
base_std  = repmat(base_std , 1, length(act.sample_times));
data_z = (data - base_mean) ./ base_std;
data_z = data - base_mean;

%% Map Data onto Brain

% act.data = mean(act.data_raw(:, start:stop), 2);
act.data = mean(data_z(:, start:stop), 2);
data = zeros(brain.N,1);
data(act.decIndices) = act.data;

% Left Side
face = brain.lface;
actcoords = brain.pialcoords(1:brain.N_L,:);
ldata = data(1:brain.N_L);
% ldata = inverse_smooth('', 'value', ldata,...
%     'step', 5,...
%     'face', double(face' - 1),...
%     'vertex', actcoords');
ldata = rois_metrics_smooth(ldata, face', actcoords');

% Right Side
face = brain.rface;
actcoords = brain.pialcoords((brain.N_L + 1):end,:);
rdata = data((brain.N_L+1):end);
% rdata = inverse_smooth('', 'value', rdata,...
%     'step', 5,...
%     'face', double(face' - 1),...
%     'vertex', actcoords');
rdata = rois_metrics_smooth(rdata, face', actcoords');

% Synthesize
act.data = [ldata; rdata];

%% Update the GUI

gpsp_set(act);
plot_act_threshold(GPSP_vars);

GPSP_vars = guidata(hObject);
plot_rois_compose(GPSP_vars);

end % function