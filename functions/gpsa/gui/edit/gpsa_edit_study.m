function gpsa_edit_study
% Opens GPSe to edit a study
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.08 - Created based on GPS1.7/gpsa_edit_subset.m
% 2012.10.22 - New edit GUI

%% Get input

% State
state = gpsa_get;

% Study (only get the first name you see)
study = get(state.gui.study_list, 'String');
i_study = get(state.gui.study_list, 'Value');
i_study = i_study(1);
study = study{i_study};

%% Open up GPSe

GPSe(study, 'wait');

% Reload the study in the GUI
gpsa_load_study;

end % function