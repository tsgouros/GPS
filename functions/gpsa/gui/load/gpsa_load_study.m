function gpsa_load_study
% Loads a study's information for GPS: Analysis
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.09.19 - created, branched from gpsa_init_studies
% 2012.09.27 - removed stage initialization and average subject
% 2013.04.05 - Updated to GPS 1.8
% 2013.04.25 - Changed subset design to condition hierarchy

% Load the state of the GUI
state = gpsa_get('state');

%% Get the study

% Make sure the index of the selected study is within acceptable bounds
i_study = get(state.gui.study_list, 'Value');
if(i_study > length(state.studies) || i_study < 1)
    i_study = 1;
    set(state.gui.study_list, 'Value', i_study);
end % If index of the study is invalid

% Set the study in the GPS state
state.study = state.studies{i_study};

% Save the GUI state
gpsa_set(state);

% Update the study for version
study = gpsa_parameter(state.study);

if(~isfield(study, 'version') || ~strcmp(study.version, 'GPS1.8') || 1)
    study = gpse_convert_study(study);
    gpsa_parameter(study);
end

% Set the Freesurfer environmental variable for the subjects MRI directory
setenv('SUBJECTS_DIR', study.mri.dir);

%% Initialize Subjects

% Get the subjects list from the study structure? or should we just get it
% from files in the study directory with type subject?
state.subjects = study.subjects;

% Get the list of subjects from the study, adding in the average one
% GPSa_state.subjects = union(study.average_name, study.subjects);

% Set the list of studies to this list
set(state.gui.subject_list, 'String', state.subjects);

% Save the GUI state
gpsa_set(state);

% Load the subject data into the GUI
gpsa_load_subject;

%% Initialize Conditions

% Load the state again in case it has changed
state = gpsa_get('state');

% Get the conditions list from the study structure? or should we just get it
% from files in the study directory with type subject?
state.conditions = study.conditions;
guiconditions = study.conditions;

% Bold the conditions that are primary
for i_condition = 1:length(guiconditions)
    condition = gpsa_parameter(state, guiconditions{i_condition});
    if(~isempty(condition) && isfield(condition, 'level') && condition.level == 1)
        guiconditions{i_condition} = str_bold(condition.name);
    end
end

% Set the list of studies to this list
set(state.gui.condition_list, 'String', guiconditions);

% Save the GUI state
gpsa_set(state);

% Load the condition data into the GUI
gpsa_load_condition;

end % function