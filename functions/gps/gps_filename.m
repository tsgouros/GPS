function filename = gps_filename(varargin)
% Finds filenames given particular structures
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013.04.12 - Created for GPS1.8
% 2013.04.16 - Added STC files
% 2013.04.17 - Corrected average filename
% 2013.04.25 - Changed subset design to condition design
% 2013.04.30 - Generalized 
% 2013.05.22 - Added mne_inv and mne_inv_meg
% 2013.06.11 - Corrected meg_eog_proj from .mat to .fif file
% 2013.06.18 - Updated parameters it accepts and cleaned
% 2013.07.02 - Added default subject values and MRI filenames
% 2013.07.10 - Uses condition brain instead of study.average_brain

%% Process input

% Process input arguments
for i_argin = 1:nargin
    parameter = varargin{i_argin};
    if(isstruct(parameter))
        if(strcmp(parameter.name, 'state'))
            state = parameter;
        else
            switch parameter.type
                case 'state'
                    state = parameter;
                case 'study'
                    study = parameter;
                case 'subject'
                    subject = parameter;
                case 'condition'
                    condition = parameter;
            end
        end
    elseif(ischar(parameter))
        if(length(parameter) > 5 && strcmp(parameter(1:5), 'hemi='))
            hemi = parameter(6:end);
        elseif(length(parameter) > 6 && strcmp(parameter(1:6), 'block='))
            block = parameter(7:end);
        elseif(length(parameter) > 6 && strcmp(parameter(1:6), 'event='))
            event = str2double(parameter(7:end));
        elseif(length(parameter) > 8 && strcmp(parameter(1:8), 'version='))
            version = parameter(9:end);
        else
            filetarget = parameter;
        end
    else
        error('Unknown parameter for gps_filename:%s\n', parameter);
    end
end % for all input arguments

% Verify input arguments
% if(~exist('state', 'var'))
%     state = gpsa_get;
% end
if(~exist('filetarget', 'var'))
    error('Not given a file target')
end

% Check which version the study is in
if(~exist('version', 'var'))
    if(exist('state', 'var') && ~isempty(state))
        studyname = state.study;
    elseif(exist('study', 'var') && ~isempty(study))
        studyname = study.name;
    elseif(exist('subject', 'var') && ~isempty(subject))
        studyname = subject.study;
    elseif(exist('condition', 'var') && ~isempty(condition))
        studyname = condition.study;
    end
    if(sum(strcmp(studyname, {'PTC2', 'MPS1', 'MVS1', 'MVS2'})))
        version = 'GPS1.7';
    else
        version = 'GPS1.8';
    end
end

% Fill in the default subject values if one isn't provided
if(~exist('subject', 'var') && exist('study', 'var'))
    if(exist('state', 'var'))
        subject.name = state.subject;
    else
        subject.name = condition.cortex.brain;
    end
    subject.mri.dir = sprintf('%s/%s', study.mri.dir, subject.name);
end

%% Retrieve filenames

switch filetarget
    case 'mri_dir'
        filename = sprintf('%s/%s', study.mri.dir, subject.name);
    case 'mri_ave_dir'
        filename = sprintf('%s/%s', study.mri.dir, condition.cortex.brain);
    case 'mri_fsave_dir'
        filename = sprintf('%s/fsaverage', study.mri.dir);
    case 'mri_mgz'
        filename = sprintf('%s/mri/T1.mgz', subject.mri.dir);
    case 'mri_surf_dir'
        filename = sprintf('%s/surf', subject.mri.dir);
    case 'mri_surf_inflated_gen'
        filename = sprintf('%s/surf/*.inflated', subject.mri.dir);
    case 'mri_label_dir'
        filename = sprintf('%s/label', subject.mri.dir);
    case 'mri_label_aparc_gen'
        filename = sprintf('%s/label/*.aparc.annot', subject.mri.dir);
    case 'mri_srcspace_gen'
        filename = sprintf('%s/bem/%s*-src.fif', subject.mri.dir, subject.name);
    case 'mri_coreg_dir'
        filename = sprintf('%s/mri/T1-neuromag/sets', subject.mri.dir);
    case 'mri_coreg_default'
        filename = sprintf('%s/mri/T1-neuromag/sets/COR.fif', subject.mri.dir);
    case 'mri_bem_surf_gen'
        filename = sprintf('%s/bem/*.surf', subject.mri.dir);
    case 'mri_bem_fif_gen'
        filename = sprintf('%s/bem/%s*-bem.fif', subject.mri.dir, subject.name);
    case 'mri_cortex_mat'
        filename = sprintf('%s/brain.mat', subject.mri.dir);
    case 'meg_scan_dir'
        filename = sprintf('%s/scans',...
            subject.meg.dir);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/raw_data',...
                subject.meg.dir);
        end
    case 'meg_dir'
        filename = sprintf('%s/%s', study.meg.dir, subject.name);
    case 'meg_fif_gen'
        filename = sprintf('%s/scans/*.fif',...
            subject.meg.dir);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/raw_data/%*.fif',...
                subject.meg.dir);
        end
    case 'meg_scan_gen'
        filename = sprintf('%s/scans/%s_*_raw.fif',...
            subject.meg.dir, subject.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/raw_data/%s_*_raw.fif',...
                subject.meg.dir, subject.name);
        end
    case 'meg_scan_block'
        filename = sprintf('%s/scans/%s_%s_raw.fif',...
            subject.meg.dir, subject.name, block);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/raw_data/%s_%s_raw.fif',...
                subject.meg.dir, subject.name, block);
        end
    case 'meg_scan_emptyroom'
        filename = sprintf('%s/scans/%s_emptyroom_raw.fif',...
            subject.meg.dir, subject.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/raw_data/%s_emptyroom_raw.fif',...
                subject.meg.dir, subject.name);
        end
    case 'meg_scan_filtered_dir'
        filename = sprintf('%s/scans_filtered',...
            subject.meg.dir);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/processed_data',...
                subject.meg.dir);
        end
    case 'meg_scan_filtered_gen'
        filename = sprintf('%s/scans_filtered/%s_*_filtered_raw.fif',...
            subject.meg.dir, subject.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/processed_data/%s_*_filtered_raw.fif',...
                subject.meg.dir, subject.name);
        end
    case 'meg_scan_filtered_block'
        filename = sprintf('%s/scans_filtered/%s_%s_filtered_raw.fif',...
            subject.meg.dir, subject.name, block);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/processed_data/%s_%s_filtered_raw.fif',...
                subject.meg.dir, subject.name, block);
        end
    case 'meg_events_dir'
        filename = sprintf('%s/events',...
            subject.meg.dir);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/triggers',...
                subject.meg.dir);
        end
    case 'meg_events_gen'
        filename = sprintf('%s/events/%s_*.eve',...
            subject.meg.dir, subject.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/triggers/%s_*.eve',...
                subject.meg.dir, subject.name);
        end
    case 'meg_events_block'
        filename = sprintf('%s/events/%s_%s.eve',...
            subject.meg.dir, subject.name, block);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/triggers/%s_%s.eve',...
                subject.meg.dir, subject.name, block);
        end
    case 'meg_events_grouped_gen'
        filename = sprintf('%s/events/%s_*_grouped.eve',...
            subject.meg.dir, subject.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/triggers/%s_*_grouped.eve',...
                subject.meg.dir, subject.name);
        end
    case 'meg_events_grouped_block'
        filename = sprintf('%s/events/%s_%s_grouped.eve',...
            subject.meg.dir, subject.name, block);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/triggers/%s_%s_grouped.eve',...
                subject.meg.dir, subject.name, block);
        end
    case 'meg_evoked_dir'
        filename = sprintf('%s/evoked',...
            subject.meg.dir);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/trials/%s',...
                study.granger.dir, subject.name);
        end
    case 'meg_evoked_gen'
        filename = sprintf('%s/evoked/%s_eve*_evoked_filtered.mat',...
            subject.meg.dir, subject.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/trials/%s/%s_eve*_evoked_filtered.mat',...
                study.granger.dir, subject.name, subject.name);
        end
    case 'meg_evoked_event'
        filename = sprintf('%s/evoked/%s_eve%04d_evoked_filtered.mat',...
            subject.meg.dir, subject.name, event);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/trials/%s/%s_eve%04d_evoked_filtered.mat',...
                study.granger.dir, subject.name, subject.name, event);
        end
    case 'meg_channels_bad'
        filename = sprintf('%s/%s_bad_channels.txt',...
            subject.meg.dir, subject.name);
    case 'meg_eog_proj'
        filename = sprintf('%s/scans/%s_eog_proj.fif',...
            subject.meg.dir, subject.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/raw_data/%s_eog_proj.fif',...
                subject.meg.dir, subject.name);
        end
    case 'meg_images_dir'
        filename = sprintf('%s/images',...
            subject.meg.dir);
        if(strcmp(version, 'GPS1.7'))
            sprintf('%s/trials/%s/images',...
                study.granger.dir, subject.name);
        end
    case 'mne_dir'
        filename = sprintf('%s/%s', study.mne.dir, subject.name);
    case 'mne_logs_dir'
        filename = sprintf('%s/logs',...
            subject.mne.dir);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/logs',...
                subject.meg.dir);
        end
    case 'mne_commands_dir'
        filename = sprintf('%s/commands',...
            subject.mne.dir);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/analysis_commands',...
                subject.meg.dir);
        end
    case 'mne_block_dir'
        filename = sprintf('%s/blocks',...
            subject.mne.dir);
    case 'mne_ave_block'
        filename = sprintf('%s/blocks/%s_%s_ave.fif',...
            subject.mne.dir, subject.name, block);
    case 'mne_ave_log_block'
        filename = sprintf('%s/logs/%s_%s_ave.log',...
            subject.mne.dir, subject.name, block);
    case 'mne_ave_fif'
        filename = sprintf('%s/%s_ave.fif',...
            subject.mne.dir, subject.name);
    case 'mne_cov_block'
        filename = sprintf('%s/blocks/%s_%s_cov.fif',...
            subject.mne.dir, subject.name, block);
    case 'mne_cov_log_block'
        filename = sprintf('%s/logs/%s_%s_cov.log',...
            subject.mne.dir, subject.name, block);
    case 'mne_cov_fif'
        filename = sprintf('%s/%s_cov.fif',...
            subject.mne.dir, subject.name);
    case 'mne_cov_emptyroom_fif'
        filename = sprintf('%s/%s_emptyroom_cov.fif',...
            subject.mne.dir, subject.name);
    case 'mne_fwd'
        filename = sprintf('%s/%s-fwd.fif',...
            subject.mne.dir, subject.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/averages/%s-fwd.fif',...
                subject.meg.dir, subject.name);
        end
    case 'mne_fwd_meg'
        filename = sprintf('%s/%s_meg-fwd.fif',...
            subject.mne.dir, subject.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/averages/%s_meg-fwd.fif',...
                subject.meg.dir, subject.name);
        end
    case 'mne_inv'
        filename = sprintf('%s/%s_meg_eeg-inv.fif',...
            subject.mne.dir, subject.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/averages/%s_meg_eeg-inv.fif',...
                subject.meg.dir, subject.name);
        end
    case 'mne_inv_meg'
        filename = sprintf('%s/%s_meg-inv.fif',...
            subject.mne.dir, subject.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/averages/%s_meg-inv.fif',...
                subject.meg.dir, subject.name);
        end
    case 'mne_stc_dir'
        filename = sprintf('%s/stcs',...
            subject.mne.dir);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/stcs',...
                subject.meg.dir);
        end
    case 'mne_stc'
        filename = sprintf('%s/stcs/%s_%s_act',...
            subject.mne.dir, subject.name, condition.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/stcs/%s_%s_act',...
                subject.meg.dir, subject.name, condition.name);
        end
    case 'mne_stc_lh'
        filename = sprintf('%s/stcs/%s_%s_act-lh.stc',...
            subject.mne.dir, subject.name, condition.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/stcs/%s_%s_act-lh.stc',...
                subject.meg.dir, subject.name, condition.name);
        end
    case 'mne_stc_rh'
        filename = sprintf('%s/stcs/%s_%s_act-rh.stc',...
            subject.mne.dir, subject.name, condition.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/stcs/%s_%s_act-rh.stc',...
                subject.meg.dir, subject.name, condition.name);
        end
    case 'mne_stc_avebrain'
        filename = sprintf('%s/stcs/%s_%s_act_%sbrain',...
            subject.mne.dir, subject.name, condition.name, condition.cortex.brain);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/stcs/%s_%s_act_avebrain',...
                subject.meg.dir, subject.name, condition.name);
        end
    case 'mne_stc_avebrain_lh'
        filename = sprintf('%s/stcs/%s_%s_act_%sbrain-lh.stc',...
            subject.mne.dir, subject.name, condition.name, condition.cortex.brain);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/stcs/%s_%s_act_avebrain-lh.stc',...
                subject.meg.dir, subject.name, condition.name);
        end
    case 'mne_stc_avesubj_dir'
        filename = sprintf('%s/%s/stcs',...
            study.mne.dir, condition.cortex.brain);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/%s/stcs',...
                study.meg.dir, condition.cortex.brain);
        end
    case 'mne_stc_avesubj'
        filename = sprintf('%s/%s/stcs/%s_%s_act',...
            study.mne.dir, condition.cortex.brain, condition.cortex.brain, condition.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/%s/stcs/%s_%s_act',...
                study.meg.dir, condition.cortex.brain, condition.cortex.brain, condition.name);
        end
    case 'mne_stc_avesubj_lh'
        filename = sprintf('%s/%s/stcs/%s_%s_act-lh.stc',...
            study.mne.dir, condition.cortex.brain, condition.cortex.brain, condition.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/%s/stcs/%s_%s_act-lh.stc',...
                study.meg.dir, condition.cortex.brain, condition.cortex.brain, condition.name);
        end
    case 'mne_stc_avesubj_rh'
        filename = sprintf('%s/%s/stcs/%s_%s_act-rh.stc',...
            study.mne.dir, condition.cortex.brain, condition.cortex.brain, condition.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/%s/stcs/%s_%s_act-rh.stc',...
                study.meg.dir, condition.cortex.brain, condition.cortex.brain, condition.name);
        end
    case 'mne_stc_avesubj_command'
        filename = sprintf('%s/%s/commands/%s_ave_desc',...
            study.mne.dir, condition.cortex.brain, condition.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/%s/stcs/commands/%s_ave_desc',...
                study.meg.dir, condition.cortex.brain, condition.name);
        end
    case 'mne_images_dir'
        filename = sprintf('%s/images',...
            subject.mne.dir);
        if(strcmp(version, 'GPS1.7'))
            sprintf('%s/trials/%s/images',...
                study.granger.dir, subject.name);
        end
    case 'granger_rois_set_dir'
        filename = sprintf('%s/rois/%s',...
            study.granger.dir, condition.cortex.roiset);
    case 'granger_rois_set_subject_dir'
        filename = sprintf('%s/rois/%s/%s',...
            study.granger.dir, condition.cortex.roiset, state.subject);
    case 'granger_rois_set_labels_gen'
        filename = sprintf('%s/rois/%s/*.label',...
            study.granger.dir, condition.cortex.roiset);
    case 'granger_rois_set_subject_labels_gen'
        filename = sprintf('%s/rois/%s/%s/*.label',...
            study.granger.dir, condition.cortex.roiset, state.subject);
    case 'granger_rois_set_subject_labels_gen_hemi'
        filename = sprintf('%s/rois/%s/%s/*-%s.label',...
            study.granger.dir, condition.cortex.roiset, state.subject, hemi);
    case 'granger_rois_set_subject_mat'
        filename = sprintf('%s/rois/%s/%s/%s_rois.mat',...
            study.granger.dir, condition.cortex.roiset, state.subject, state.subject);
    case 'granger_waves_rois_dir'
        filename = sprintf('%s/roiwaves/%s', study.granger.dir, condition.name);
        if(~strcmp(condition.name, condition.cortex.roiset))
            filename = sprintf('%s_%s', filename, condition.cortex.roiset); end
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/roiwaves/%s', study.granger.dir, condition.name);
            if(~strcmp(condition.name, condition.cortex.roiset))
                filename = sprintf('%s/%s', filename, condition.cortex.roiset); end
        end
    case 'granger_waves_rois_subject_mat'
        filename = sprintf('%s/roiwaves/%s', study.granger.dir, condition.name);
        if(~strcmp(condition.name, condition.cortex.roiset))
            filename = sprintf('%s_%s', filename, condition.cortex.roiset); end
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/roiwaves/%s', study.granger.dir, condition.name);
            if(~strcmp(condition.name, condition.cortex.roiset))
                filename = sprintf('%s/%s', filename, condition.cortex.roiset); end
        end
        filename = sprintf('%s/%s_%s_roiwaves.mat',...
            filename, subject.name, condition.name);
    case 'granger_mni_coordinates'
        filename = sprintf('%s/rois/%s/%s/mni_coordinates.txt',...
            study.granger.dir, condition.cortex.roiset, condition.cortex.brain);
    case 'granger_analysis_input'
        filename = sprintf('%s/input/%s_%s.mat',...
            study.granger.dir, study.name, condition.name);
    case 'granger_analysis_input_dir'
        filename = sprintf('%s/input',...
            study.granger.dir);
    case 'granger_analysis_rawoutput'
        filename = gps_filename(study, condition, 'granger_analysis_rawoutput_gen');
        folder = filename(1:find(filename == '/', 1, 'last'));
        filename = dir(filename);
        if(~isempty(filename))
            filename = [folder filename(end).name];
        else filename = [];
        end
    case 'granger_analysis_rawoutput_now'
        filename = gps_filename(study, condition, 'granger_analysis_rawoutput_gen');
        date_string = datestr(now, 'yyyymmdd_hhMMss');
        asterisk = find(filename == '*');
        filename = sprintf('%s%s.mat', filename(1:asterisk - 1), date_string);
    case 'granger_analysis_rawoutput_gen'
        filename = gps_filename(study, condition, 'granger_analysis_rawoutput_dir');
        filename = sprintf('%s/%s_%s_*.mat',...
            filename, study.name, condition.name);
    case 'granger_analysis_rawoutput_dir'
        filename = sprintf('%s/results/raw',...
            study.granger.dir);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/results',...
                study.granger.dir);
        end
    case 'granger_analysis_nullhypo'
        filename = gps_filename(study, condition, 'granger_analysis_nullhypo_gen');
        folder = filename(1:find(filename == '/', 1, 'last'));
        filename = dir(filename);
        if(~isempty(filename))
            filename = [folder filename(end).name];
        else filename = [];
        end
    case 'granger_analysis_nullhypo_now'
        filename = gps_filename(study, condition, 'granger_analysis_nullhypo_gen');
        date_string = datestr(now, 'yyyymmdd_hhMMss');
        asterisk = find(filename == '*');
        filename = sprintf('%s%s.mat', filename(1:asterisk - 1), date_string);
    case 'granger_analysis_nullhypo_gen'
        filename = gps_filename(study, condition, 'granger_analysis_nullhypo_dir');
        filename = sprintf('%s/%s_%s_*.mat',...
            filename, study.name, condition.name);
    case 'granger_analysis_nullhypo_dir'
        filename = sprintf('%s/results/nullhypothesis',...
            study.granger.dir);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/results',...
                study.granger.dir);
        end
    case 'granger_analysis_results'
        filename = gps_filename(study, condition, 'granger_analysis_results_gen');
        folder = filename(1:find(filename == '/', 1, 'last'));
        filename = dir(filename);
        if(~isempty(filename))
            filename = [folder filename(end).name];
        else filename = [];
        end
    case 'granger_analysis_results_now'
        filename = gps_filename(study, condition, 'granger_analysis_results_gen');
        date_string = datestr(now, 'yyyymmdd_hhMMss');
        asterisk = find(filename == '*');
        filename = sprintf('%s%s.mat', filename(1:asterisk - 1), date_string);
    case 'granger_analysis_results_gen'
        filename = sprintf('%s/results/%s_%s_*.mat',...
            study.granger.dir, study.name, condition.name);
        if(strcmp(version, 'GPS1.7'))
            filename = sprintf('%s/results/%s_%s_tests_*.mat',...
                study.granger.dir, study.name, condition.name);
        end
    otherwise
        error('Filetarget %s does not exist\n', filetarget)
end

end % function