function gpsr_cluster
% Analyze clusters based on cortical activity
%
% Author: A. Conrad Nied (conrad@martinos.org)
%
% Changelog:
% 2013.05.22 - Created

%% Load data

% Basic Parameters
state = gpsa_get;

state.subject = 'average';
study = gpsr_parameter(state, state.study);
% subject = gpsr_parameter(state, state.subject);
condition = gpsr_parameter(state, state.condition);
brain = gps_brain_get(state);

% STC files
activity_lh = mne_read_stc_file1(gps_filename(study, condition, 'mne_stc_avesubj_lh'));
activity_rh = mne_read_stc_file1(gps_filename(study, condition, 'mne_stc_avesubj_rh'));

% Isolate activity
activity = [activity_lh.data; activity_rh.data];
sample_times = (0:size(activity, 2) - 1) * activity_lh.tstep + activity_lh.tmin;
activity = activity(:, sample_times >= 0.1 & sample_times <= 0.4);
clear activity_lh activity_rh

%% Process

activity_norm = activity - repmat(mean(activity, 2), 1, size(activity, 2));
activity_norm = activity / repmat(std(activity_norm, 0, 2), 1, size(activity_norm, 2));

dists = pdist(activity_norm, 'Euclidean');
Z = linkage(dists);
max(Z(:, 3))
c = cluster(Z, 'maxclus', [2 3 5 8 13 21 34 55]);

%% Display

brain.regions = c(:, 5);
brain.act.data = mean(activity, 2);
brain.act.p = [80 90 95 100];

figure(31521)
clf
set(gcf, 'Units', 'Pixels');
set(gcf, 'Position', [10, 10, 800, 600]);
set(gca, 'Units', 'Normalized');
set(gca, 'Position', [0, 0, 1, 1]);

options.overlays(1).name = 'act';
options.overlays(1).percentiled = 'p';
options.overlays(1).decimated = 1;
options.overlays(1).coloring = 'hot';
options.shading = 1;
options.curvature = 'bin';
options.sides = {'ll', 'rl', 'lm', 'rm'};
options.fig = gcf;
options.axes = gca;
options.regions = 1;
options.regions_color = gps_colorhash((1:max(brain.regions))');
options.parcellation = 'speech lab';
% options.parcellation = 'Endpoint';
options.parcellation_text = 1;

gps_brain_draw(brain, options);
set(options.fig, 'Name', 'Activity');
set(options.fig, 'NumberTitle', 'off');

% Save
% frame = getframe(gcf);
% filename = sprintf('%s/Python/%s/%s_%s_plv_cortex.png', study.plv.dir, condition.name, study.name, condition.name);
% imwrite(frame.cdata, filename);


end % function