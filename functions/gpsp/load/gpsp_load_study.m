function gpsp_load_study
% Loads a study that has been selected in the GPS: Plotting GUI
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Input: The GPS Plot variables structure
% Output: None
%
% Changelog:
% 2012-07-05 Created in GPS1.6
% 2012-10-11 Loosely adapted to GPS1.7
% 2013-07-14 Make to work in the new GPS1.8 system

state = gpsp_get;

%% Get the current study
i_study = get(state.data_study, 'Value');
studies = get(state.data_study, 'String');
state.study = studies{i_study};

study = gpsp_parameter(state, state.study);

% Set the Freesurfer environmental variable for the subjects MRI directory
setenv('SUBJECTS_DIR', study.mri.dir);

%% Handle conditions list

% Populate List of Conditions
conditions = study.conditions;
set(state.data_condition, 'String', conditions);

% Choose the condition to load
if(isfield(state, 'condition') && sum(strcmp(conditions, state.condition)))
    i_condition = find(strcmp(conditions, state.condition));
else
    i_condition = get(state.data_condition, 'Value');
    if(i_condition > length(conditions)); i_condition = 1; end
end
set(state.data_condition, 'Value', i_condition);

%% Wrap up and set the condition conclusion

% Update handles structure
gpsp_set(state);
guidata(state.data_study, state);

% Send to the condition setter
gpsp_load_condition;

end % function