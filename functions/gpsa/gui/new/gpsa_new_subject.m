function gpsa_new_subject
% Makes a new subject and opens GPSe to edit it
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.07 - Created, based on GPS1.7/gpsa_new_subset.m
% 2013.06.11 - Adds subject to state now

% Get state
state = gpsa_get;

% Get input for the name of this subject
name = inputdlg({'Name'}, 'New Subject', 1, {''});
name = name{1};

% Create the subject using default parameters
subject = gpse_convert_subject(name);
gpsa_parameter(subject);

% Save to the study
study = gpsa_parameter(state.study);
study.subjects = unique([study.subjects; name]);
gpsa_parameter(study);

% Add to the GUI
state.subjects = study.subjects;
set(state.gui.subject_list, 'String', state.subjects);

% Set the GUI to index to this subject now
i_subject = find(strcmp(study.subjects, name));
set(state.gui.subject_list, 'Value', i_subject);

% Save the subject to the state's list
gpsa_set(state)

% % Edit the subject
% gpsa_edit_subject;

end % function