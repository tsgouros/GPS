function gpsp_load_condition
% Happens after you choose a condition
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012-07-05 Separate function from GPS_grangerplot called
%  GPS1.6/plot_data_condition.m
% 2012-10-11 Loosely adapted to GPS1.7
% 2013-07-09 GPS1.8, GPSP_vars->state
% 2013-06-15 Finished adapting to new standard
% 2013-07-15 Adapted to new GUI
% 2013-08-06 Changes the method conditions

state = gpsp_get;

%% Get the current condition
i_condition = get(state.data_condition, 'Value');
conditions = get(state.data_condition, 'String');
state.condition = conditions{i_condition};

study = gpsp_parameter(state, state.study);
condition = gpsp_parameter(state, state.condition);

%% Load the brain

% Get subject name
state.subject = condition.cortex.brain;

% Load the brain and set it to the structure
subject = gpsp_parameter(state, state.subject);
if(isempty(subject))
    subject.name = state.subject;
    subject.type = 'subject';
    subject.mri.dir = sprintf('%s/%s', study.mri.dir, subject.name);
end
brain = gps_brain_get(subject);
gpsp_set(brain);

% Set parcellations list
parcellations = {'none', 'aparc'};
brain_fields = fields(brain);
for i_field = 1:length(brain_fields)
    field = brain_fields{i_field};
    if(isstruct(brain.(field)))
        parcellations{length(parcellations) + 1} = field;
    end
end
set(state.surf_atlas, 'String', parcellations);

%% Set File Defaults

% Set Default Data file
state.file_granger = gps_filename(study, condition, 'granger_analysis_results');
if(~exist(state.file_granger, 'file'));
    other_file_granger = gps_filename(study, condition, 'granger_analysis_rawoutput');
    if(exist(other_file_granger, 'file'))
        state.file_granger = other_file_granger;
    else
        state.file_granger = study.granger.dir;
    end
end

% Set the default ROI directory
state.file_regions = gps_filename(state, study, condition, 'granger_rois_set_subject_mat');

% Set the default activation file
state.file_activity = gps_filename(study, condition, 'mne_stc_avesubj_lh');
if(~exist(state.file_activity, 'file'))
    subject = gpsp_parameter(state, state.subject);
    if(~isempty(subject))
        filename = gps_filename(study, condition, subject, 'mne_stc_lh');
        if(exist(filename, 'file'))
            state.file_activity = filename;
        end
    end
end

% Turn on the load button
set(state.data_granger_load, 'String', 'Load');
set(state.data_granger_load, 'FontWeight', 'Bold');
set(state.data_granger_load, 'FontAngle', 'Normal');
set(state.data_act_load, 'String', 'Load');
set(state.data_act_load, 'FontWeight', 'Bold');
set(state.data_act_load, 'FontAngle', 'Normal');
set(state.data_granger2_load, 'String', 'Load');
set(state.data_granger2_load, 'FontWeight', 'Bold');
set(state.data_granger2_load, 'FontAngle', 'Normal');
set(state.data_act2_load, 'String', 'Load');
set(state.data_act2_load, 'FontWeight', 'Bold');
set(state.data_act2_load, 'FontAngle', 'Normal')

% Clear out old information
act.name = 'act';
act2.name = 'act2';
granger.name = 'granger';
granger2.name = 'granger2';
rois.name = 'rois';
gpsp_set(act);
gpsp_set(act2);
gpsp_set(granger);
gpsp_set(granger2);
gpsp_set(rois);
set(state.method_condition, 'String', ' ');
set(state.method_condition, 'Value', 1);

%% Set default time values
set(state.time_windowstart, 'String', num2str(condition.event.focusstart));
set(state.time_windowstop,  'String', num2str(condition.event.focusstop));
set(state.time_duration,    'String', num2str(condition.event.focusstop - condition.event.focusstart));
set(state.time_interval,    'String', num2str(condition.event.focusstop - condition.event.focusstart));

%% Set comparable conditions

comparisons = study.conditions;
i_comparisons = zeros(length(comparisons), 1);
for i_comparison = 1:length(comparisons);
    comparison = gpsp_parameter(state, comparisons{i_comparison});
    if(~strcmp(condition.name, comparison.name) && ...
            strcmp(comparison.cortex.roiset, condition.cortex.roiset))
        i_comparisons(i_comparison) = 1;
    end
end
if(sum(i_comparisons) > 0)
    comparisons = comparisons(find(i_comparisons)); %#ok<FNDSB>
    comparisons = [{''}; comparisons];
else
    comparisons = {''};
end
set(state.data_condition2, 'String', comparisons);
set(state.data_condition2, 'Value', 1);

% Disable comparison list if there aren't any
if(length(comparisons) == 1)
    set(state.data_condition2_text,'Enable', 'off');
%     set(state.data_act2_text,      'Enable', 'off');
    set(state.data_granger2_text,  'Enable', 'off');
    set(state.data_condition2,     'Enable', 'off');
%     set(state.data_act2_load,      'Enable', 'off');
    set(state.data_granger2_load,  'Enable', 'off');
else
    set(state.data_condition2_text,'Enable', 'on');
%     set(state.data_act2_text,      'Enable', 'on');
    set(state.data_granger2_text,  'Enable', 'on');
    set(state.data_condition2,     'Enable', 'on');
%     set(state.data_act2_load,      'Enable', 'on');
    set(state.data_granger2_load,  'Enable', 'on');
end
    

%% Save and draw the brain

% Update structures
gpsp_set(state);
guidata(state.data_study, state);

% Compute the time window
gpsp_compute_timing;

% Draw the brain
gpsp_draw_surf;

end % function