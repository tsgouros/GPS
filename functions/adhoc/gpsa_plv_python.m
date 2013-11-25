function gpsa_plv_python(varargin)
% This function writes routines for the python processing of PLV
%
% Author: A. Conrad Nied
% 
% Changelog:
% 2013.05    - Created
% 2013.05.20 - Gamma band now, takes varargin, saves folder changed, saves matrix

% Get variables
[state, ~] = gpsa_inputs(varargin);

study = gpsa_parameter(state, state.study);
subject = gpsa_parameter(state, state.subject);
condition = gpsa_parameter(state, state.condition);
folder = sprintf('%s/Python/%s/%s', study.plv.dir, condition.name, subject.name);
if(~exist(folder, 'dir')); mkdir(folder); end
filename = sprintf('%s/%s_%s_commands.py', folder, subject.name, condition.name);
fid = fopen(filename, 'w');

% Setup the environment
fprintf(fid, '# Setup the environment\n');
fprintf(fid, 'import mne\n');
fprintf(fid, 'from mne.minimum_norm import apply_inverse_epochs, make_inverse_operator\n');
fprintf(fid, 'from mne.connectivity import spectral_connectivity\n');
fprintf(fid, 'from mne.viz import circular_layout, plot_connectivity_circle\n');
fprintf(fid, 'import pylab as pl\n');
fprintf(fid, 'import numpy as np\n');
fprintf(fid, '\n');

% Load the necessary files from the subject's data
fprintf(fid, '# Load the necessary files from the subject''s data\n');
% fprintf(fid, 'data_path = ''%s''\n', study.basedir);
% fprintf(fid, 'subjects_dir = ''%s''\n', study.mri.dir);
fprintf(fid, 'mne.set_log_level(''WARNING'')\n');
fprintf(fid, 'fwd = mne.read_forward_solution(''%s'', surf_ori=True)\n',...
    gps_filename(subject, 'mne_fwd_meg'));
fprintf(fid, '\n');

% Get the raw information
fprintf(fid, '# Get the raw information\n');
fprintf(fid, 'raw = mne.fiff.Raw([');
for i_block = 1:length(subject.blocks)
    if(i_block > 1); fprintf(fid, ', '); end
    fprintf(fid, '''%s''', gps_filename(subject, 'meg_scan_block', ['block=' subject.blocks{i_block}]));
end
fprintf(fid, '])\n');
fprintf(fid, 'picks = mne.fiff.pick_types(raw.info, meg=True, eeg=False, stim=False, eog=True, exclude=raw.info[''bads''])\n');
fprintf(fid, 'tmin, tmax = -0.3, 0.8\n');

% Get events
fprintf(fid, '# Get events and concatenate them\n');
fprintf(fid, 'events_txt = np.loadtxt(''%s'', dtype=np.float)\n',...
    gps_filename(subject, 'meg_events_grouped_block', ['block=' subject.blocks{1}]));
fprintf(fid, 'events_proc = np.delete(events_txt, 1, 1)\n');
fprintf(fid, 'events_1 = events_proc.astype(int)\n');
% fprintf(fid, 'epochs = mne.Epochs(raw, events, event_id, tmin, tmax, picks=picks, baseline=(None, 0), reject=dict(mag=4e-12, grad=4000e-13, eog=150e-6))\n');
fprintf(fid, '\n');
events_list = 'events_1';

for i_block = 2:length(subject.blocks)
    fprintf(fid, 'events_txt = np.loadtxt(''%s'', dtype=np.float)\n',...
        gps_filename(subject, 'meg_events_grouped_block', ['block=' subject.blocks{i_block}]));
    fprintf(fid, 'events_proc = np.delete(events_txt, 1, 1)\n');
    fprintf(fid, 'events_%d = events_proc.astype(int)\n', i_block);
    fprintf(fid, '\n');
    events_list = sprintf('%s, events_%d', events_list, i_block);
end

fprintf(fid, 'events_list = [%s]\n', events_list);
fprintf(fid, 'events = mne.concatenate_events(events_list, raw._first_samps, raw._last_samps)\n');
fprintf(fid, '\n');

% Get the epochs
fprintf(fid, '# Get the epochs\n');
fprintf(fid, 'epochs = mne.Epochs(raw, events, {');
for i_event = 1:length(condition.event.code)
    if(i_event > 1); fprintf(fid, ', '); end
    fprintf(fid, '''%d'': %d', condition.event.code(i_event), condition.event.code(i_event));
end
fprintf(fid, '}, tmin, tmax, picks=picks, baseline=(None, 0), reject=dict(mag=4e-12, grad=4000e-13, eog=150e-6))\n');

fprintf(fid, 'mne.epochs.combine_event_ids(epochs, [');
for i_event = 1:length(condition.event.code)
    if(i_event > 1); fprintf(fid, ', '); end
    fprintf(fid, '''%d''', condition.event.code(i_event));
end
fprintf(fid, '], 500, False)\n');
fprintf(fid, '\n');

% Compute the inverse operator and get the source timecourses
fprintf(fid, '# Compute the inverse operator and get the source timecourses\n');
fprintf(fid, 'cov = mne.compute_covariance(epochs)\n');
fprintf(fid, 'inverse_op = make_inverse_operator(epochs.info, fwd, cov, loose=0.2, depth=0.8)\n');
% fprintf(fid, 'inverse_op = mne.minimum_norm.read_inverse_operator(''%s'')\n', gps_filename(subject, 'mne_inv_meg'));
fprintf(fid, 'snr = 1.0\n');
fprintf(fid, 'lambda2 = 1.0 / snr ** 2\n');
fprintf(fid, 'stcs = apply_inverse_epochs(epochs, inverse_op, lambda2, method=''dSPM'', pick_normal=True, return_generator=True)\n');
fprintf(fid, '\n');

% Get labels and label time courses
fprintf(fid, '# Get labels and label time courses\n');
fprintf(fid, 'labels, label_colors = mne.labels_from_parc(''%s'', parc=''aparc'', subjects_dir=''%s'')\n', subject.name, study.mri.dir);
% fprintf(fid, 'labels, label_colors = mne.labels_from_parc(''%s'', parc=''SLaparc17'', subjects_dir=''%s'')\n', subject.name, study.mri.dir);
fprintf(fid, 'label_ts = mne.extract_label_time_course(stcs, labels, inverse_op[''src''], mode=''mean_flip'', return_generator=True)\n');
fprintf(fid, '\n');

% Compute the connectivity in the alpha band
fprintf(fid, '# Compute the connectivity in the alpha band\n');
fprintf(fid, 'fmin, fmax, sfreq = 35., 50., raw.info[''sfreq'']\n');
fprintf(fid, 'methods = [''coh'', ''plv'', ''wpli'']\n');
fprintf(fid, 'con, freqs, times, n_epochs, n_tapers = spectral_connectivity(label_ts, method=methods, mode=''multitaper'', sfreq=sfreq, fmin=fmin, fmax=fmax, tmin=0.1, tmax=0.4, faverage=True, mt_adaptive=True)\n');
fprintf(fid, '\n');

% Visualize the connectivity estimates obtained for each method using a circular graph:
fprintf(fid, '# Visualize\n');
fprintf(fid, 'node_names = [label.name for label in labels]\n');
fprintf(fid, 'np.savetxt(''node_names2.txt'', node_names, ''%%s'')\n');
% fprintf(fid, 'node_order = [line.strip() for line in open(''/autofs/cluster/dgow/GPS1.8/functions/gpsa/plv/node_order.txt'', ''r'').readlines()]\n');
% fprintf(fid, 'node_angles = circular_layout(node_names, node_order, start_pos=90)\n');
fprintf(fid, '\n');
fprintf(fid, 'for method, this_con in zip(methods, con):\n');
% fprintf(fid, '    plot_connectivity_circle(this_con[:, :, 0], node_names, n_lines=1000, node_angles=node_angles, node_colors=label_colors, title=''%s %s Gamma %%s'' %% method.upper())\n',...
fprintf(fid, '    plot_connectivity_circle(this_con[:, :, 0], node_names, n_lines=1000, node_colors=label_colors, title=''%s %s Gamma %%s'' %% method.upper())\n',...
    subject.name, condition.name);
fprintf(fid, '    pl.savefig(''%s/%s_%s_gamma_%%s.png'' %% method, facecolor=''black'')\n', folder, subject.name, condition.name);
fprintf(fid, '    np.savetxt(''%s/%s_%s_gamma_%%s.txt'' %% method, np.array(this_con)[:, :, 0], ''%%f'')\n', folder, subject.name, condition.name);
fprintf(fid, '\n');

fclose(fid);

end % function