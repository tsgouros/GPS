function gpsa_edit_subject
% Opens GPSe to edit a subject
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.07 - Created based on GPS1.7/gpsa_edit_subset.m
% 2012.10.08 - Reloads the subject back into the GUI
% 2012.10.22 - New edit GUI
% 2013.04.25 - GPS1.8 fixed naming error on line 17

%% Get input

% State
state = gpsa_get;

% Subject (only get the first name you see)
subjects = get(state.gui.subject_list, 'String');
i_subject = get(state.gui.subject_list, 'Value');
i_subject = i_subject(1);
subject = subjects{i_subject};

%% Open up GPSe

GPSe(subject, 'wait');

% Reload the subject in the GUI
gpsa_load_subject;

end % function