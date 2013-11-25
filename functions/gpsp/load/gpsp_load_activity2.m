function gpsp_load_activity2
% Load in brain cortical activity estimates
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-08-14 Created GPS1.8/gpsp_load_activity from GPS1.7/plot_data_act

state = gpsp_get;
set(state.data_act2_load, 'String', 'Loading');
set(state.data_act2_load, 'FontWeight', 'Normal');
set(state.data_act2_load, 'FontAngle', 'Italic');
guidata(state.data_act2_load, state);
refresh(state.guifig);
pause(0.1);

%% Ask for the file to load (double check the default is right)

[filename, path] = uigetfile(state.file_activity2);
state.file_activity2 = [path filename];
gpsp_set(state);

%% Acquire Data
brain = gpsp_get('brain');

% Left
filename = state.file_activity2;
lMNE = mne_read_stc_file(filename);

% Right
filename = [filename(1:(end-7)) '-rh.stc'];
rMNE = mne_read_stc_file(filename);

%% Fill act structure

act.name = 'act2';
act.data_raw = [lMNE.data; rMNE.data];
act.decIndices = [lMNE.vertices + 1; rMNE.vertices + brain.N_L + 1];
act.decN_L = length(lMNE.data);
act.decN_R = length(rMNE.data);
act.decN = act.decN_L + act.decN_R;
act.sample_times = rMNE.tmin + (0:size(act.data_raw, 2) - 1) * rMNE.tstep;

% Turn on the load button
set(state.data_act2_load, 'String', 'Loaded');
set(state.data_act2_load, 'FontWeight', 'Normal');
set(state.data_act2_load, 'FontAngle', 'Normal');
guidata(state.data_act2_load, state);
refresh(state.guifig);

%% Update the GUI

gpsp_set(act);
gpsp_compute_activity;

end % function