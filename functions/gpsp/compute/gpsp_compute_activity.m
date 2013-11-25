function gpsp_compute_activity
% Compose map of brain activation data
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-08-14 Created GPS1.8/gpsp_compute_activity from GPS1.6/plot_act_compose.

%% Acquire Data
state = gpsp_get;
brain = gpsp_get('brain');
act = gpsp_get('act');

if(~isfield(act, 'data_raw'))
    return
end

start = str2double(get(state.act_time_start, 'String'));
stop = str2double(get(state.act_time_stop, 'String'));
if(stop < start); stop = start; end

start = max(1, find(act.sample_times > start/1000, 1, 'first') - 1);
stop = min(size(act.data_raw, 2), find(act.sample_times < stop/1000, 1, 'last') + 1);

%% Baselining (optional, add button for this)
% data = act.data_raw;
% 
% sample_zero = find(act.sample_times > 0.1, 1, 'first') - 1;
% sample_zero = 1;
% base_mean =   mean(data(:, 1:sample_zero),    2);
% base_std  =    std(data(:, 1:sample_zero), 0, 2);
% base_mean = repmat(base_mean, 1, length(act.sample_times));
% base_std  = repmat(base_std , 1, length(act.sample_times));
% data_z = (data - base_mean) ./ base_std;
% data_z = data - base_mean;

%% Map Data onto Brain

act.data = mean(act.data_raw(:, start:stop), 2);

% Contrast
method = get(state.method_condition, 'Value');
% if(method >= 3)
%     act2 = gpsp_get('act2');
%     act.data = act.data - mean(act2.data_raw(:, start:stop), 2);
%     if(method == 4); act.data = -act.data; end
% end

% act.data = mean(data_z(:, start:stop), 2);
data = zeros(brain.N,1);
data(act.decIndices) = act.data;

% Left Side
face = brain.lface;
actcoords = brain.pialcoords(1:brain.N_L,:);
ldata = data(1:brain.N_L);
ldata = rois_metrics_smooth(ldata, face', actcoords');

% Right Side
face = brain.rface;
actcoords = brain.pialcoords((brain.N_L + 1):end,:);
rdata = data((brain.N_L+1):end);
rdata = rois_metrics_smooth(rdata, face', actcoords');

% Synthesize
act.data = [ldata; rdata];

%% Update the GUI

gpsp_set(act);
gpsp_compute_activity_colors;

end % function