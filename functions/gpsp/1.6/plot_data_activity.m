function plot_data_activity(state)
% Load in brain cortical activity estimates
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream Plotting variables/handle
% Output: none
%
% Changelog:
% 2012-07-05 Created from granger_plot_act_load
% 2012-10-11 Loosely adapted to GPS1.7
% 2013-07-09 GPS1.8 updated conventions and verifies file now

%% Ask for the file to load (double check the default is right)

[filename, path] = uigetfile(state.file_activity);
state.file_activity = [path filename];

%% Acquire Data
brain = gpsp_get('brain');

% Left
filename = state.file_activity;
lMNE = mne_read_stc_file(filename);

% Right
filename = [filename(1:(end-7)) '-rh.stc'];
rMNE = mne_read_stc_file(filename);

%% Fill act structure

act.name = 'act';
act.data_raw = [lMNE.data; rMNE.data];
act.decIndices = [lMNE.vertices + 1; rMNE.vertices + brain.N_L + 1];
act.decN_L = length(lMNE.data);
act.decN_R = length(rMNE.data);
act.decN = act.decN_L + act.decN_R;
act.sample_times = rMNE.tmin + (0:size(act.data_raw, 2) - 1) * rMNE.tstep;

% Turn on the load button
set(state.data_act_load, 'Enable', 'off');
set(state.data_act_load, 'String', 'Loaded');

%% Update the GUI

gpsp_set(act);
plot_act_compose(state);

end % function