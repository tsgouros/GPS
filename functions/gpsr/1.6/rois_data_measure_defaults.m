function rois_data_measure_defaults(state)
% Sets default values for filenames
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI
%
% Date Created: 2012.06.16
% Last Modified: 2012.06.16
% 2012.10.09 - Superficially adapted to GPS1.7
% 2013.06.27 - GPS1.8 gps_filename adaptation

% Get parameters
study = gpsr_parameter(state, state.study);
subject = gpsr_parameter(state, state.subject);
condition = gpsr_parameter(state, state.condition);

if(~isempty(subject) && ~isempty(condition))

    % Set filenames
    if(strcmp(subject.name, condition.cortex.brain)) % Average subject
        files.mne = gps_filename(study, condition, 'mne_stc_avesubj_lh');
        files.plv = sprintf('%s/stc/%s/%s_%s_LSTG1_freq%2dp00hz_plv_ave-lh.stc',...
            study.plv.dir, condition.name, study.name, condition.name, study.granger.plv_freq);
        files.custom = sprintf('%s/%s/stcs/%s_%s_%s_mne-lh.stc',...
            study.meg.dir, condition.cortex.brain, study.name, condition.cortex.brain, condition.name);
        files.oldroidir = gps_filename(study, condition, 'granger_rois_set_dir');
    else % Regular subject
        files.mne = gps_filename(study, condition, subject, 'mne_stc_lh');
        files.plv = sprintf('%s/stc/%s/%s_LSTG1_freq%2dp00hz_plv-lh.stc',...
            study.plv.dir, condition.name, subject.name, study.granger.plv_freq);
        files.custom = sprintf('%s/stcs/%s_%s_mne-lh.stc',...
            subject.meg.dir, subject.name, condition.name);
        files.oldroidir = gps_filename(study, condition, 'granger_rois_set_dir');
%         files.oldroidir = gps_filename(state, study, condition, 'granger_rois_set_subject_dir');
    end
    files.roidir = files.oldroidir;
    files.imdir = sprintf('%s/images/%s',...
        study.granger.dir, condition.name);

    [~, ~, ~] = mkdir(files.roidir);
    
    % Save to data fig
    setappdata(state.datafig, 'files', files);
    
elseif(strcmp(state.subject, condition.cortex.brain))
    files.mne = gps_filename(study, condition, 'mne_stc_avesubj_lh');
    files.plv = sprintf('%s/stc/%s/%s_%s_LSTG1_freq%2dp00hz_plv_ave-lh.stc',...
        study.plv.dir, condition.name, study.name, condition.name, study.granger.plv_freq);
    files.custom = sprintf('%s/%s/stcs/%s_%s_%s_mne-lh.stc',...
        study.meg.dir, condition.cortex.brain, study.name, condition.cortex.brain, condition.name);
    files.oldroidir = gps_filename(study, condition, 'granger_rois_set_dir');
    files.roidir = files.oldroidir;
    files.imdir = sprintf('%s/images/%s',...
        study.granger.dir, condition.name);
    [~, ~, ~] = mkdir(files.roidir);
    
    % Save to data fig
    setappdata(state.datafig, 'files', files);
else
    return
end

%% Remove Metrics Data and Reset Buttons
if(isappdata(state.datafig, 'metrics'))
    metrics = getappdata(state.datafig, 'metrics');
    for typec = {'mne', 'plv', 'custom', 'maxact', 'sim'}
        if(isfield(metrics, typec))
            metrics.(typec) = rmfield(metrics.(typec), 'data');
        end
    end
    setappdata(state.datafig, 'metrics', metrics);
end

for typec = {'mne', 'plv', 'custom', 'maxact', 'sim'}
    type = typec{1};
    % Turn on the load button
    if(~strcmp(type, 'maxact') && ~strcmp(type, 'sim'))
        button = sprintf('data_%s_load', type);
        set(state.(button), 'Enable', 'on');
        set(state.(button), 'String', 'Load');
    end

    % Disable this measure in other parts of the GUI
    button = sprintf('quick_%s', type);
    set(state.(button), 'Enable', 'off');
    set(state.(button), 'Value', 0);

    % Clear Data (but not settings)
    if(isappdata(state.datafig, type))
        metric = getappdata(state.datafig, type);
        if(isfield(metric, 'data')); metric = rmfield(metric, 'data'); end
        setappdata(state.datafig, type, metric);
    end % If there is app data
end

if(isappdata(state.datafig, 'points'))
    rmappdata(state.datafig, 'points');
end
set(state.quick_centroids, 'Value', 0);
set(state.quick_centroids, 'Enable', 'off');
set(state.centroids_show, 'Value', 0);
set(state.centroids_show, 'Enable', 'off');
set(state.quick_regions, 'Value', 0);
set(state.quick_regions, 'Enable', 'off');
set(state.regions_show, 'Value', 0);
set(state.regions_show, 'Enable', 'off');

% set(state.metrics_vis_show, 'Value', 0);


%% Update the GUI
guidata(state.data_subject_list, state);

% Draw
rois_draw(state);

end % function