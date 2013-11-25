function plot_data_condition(state)
% Happens after you choose a condition
%
% Author: Conrad Nied
%
% Date Created: 2012.07.05 as separate function from GPS_grangerplot
% Last Modified: 2012.07.05
%
% Input: The GPS Plot variables structure
% Output: None
% 2012.10.11 - Loosely adapted to GPS1.7
% 2013.07.09 - GPS1.8, GPSP_vars->state

%% Get the current condition
i_condition = get(state.data_condition, 'Value');
conditions = get(state.data_condition, 'String');
state.condition = conditions{i_condition};

state.name = 'state';
study = gpsr_parameter(state, state.study);
condition = gpsr_parameter(state, state.condition);

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
state.dir_rois = gps_filename(study, condition, 'granger_rois_set_dir');

% Set the default activation file
if(study.granger.singlesubject)
    subject = gpsr_parameter(state, state.subject);
    
    state.file_activity = gps_filename(study, condition, subject, 'mne_stc_lh');
else % average
    state.file_activity = gps_filename(study, condition, 'mne_stc_avesubj_lh');
end

% Turn on the load button
set(state.data_granger_load, 'Enable', 'on');
set(state.data_granger_load, 'String', 'Load');
set(state.data_act_load, 'Enable', 'on');
set(state.data_act_load, 'String', 'Load');

% Clear out old information
gpsp_set([], 'act');
gpsp_set([], 'granger');
gpsp_set([], 'rois');
gpsp_set([], 'rois_cortical');

%% Load the brain

% Get subject name
state.subject = condition.cortex.brain;

% Load the brain and set it to the structure
subject = gpsa_parameter(state, state.subject);
if(isempty(subject))
    subject.name = state.subject;
    subject.type = 'subject';
    subject.mri.dir = sprintf('%s/%s', study.mri.dir, subject.name);
end
brain = gps_brain_get(subject);
gpsp_set(brain);

%% Set default time values
set(state.frames_windowstart, 'String', num2str(condition.event.focusstart));
set(state.frames_windowstop,  'String', num2str(condition.event.focusstop));
set(state.frames_duration,    'String', num2str(condition.event.focusstop - condition.event.focusstart));
set(state.frames_interval,    'String', num2str(condition.event.focusstop - condition.event.focusstart));

%% Save and draw the brain

% Update handles structure
guidata(state.data_study, state);

% % Draw the brain
plot_draw(state);

end % function