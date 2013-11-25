function gpse_init_studies
% Initializes the study list in the GPS: Edit environment
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.22 - Created, based on GPS1.7/gpsa_init_studies.m
% 2013.04.25 - GPS1.8 Revised note before gpse_load_study
% 2013.06.18 - Moved state.study assignment to gpse_load_study

state = gpse_get;

%% Load study list

% Get the list of folders from the parameters folder
files = dir(gps_presets('parameters'));

% Presume each name of a folder is a different study (should be)
state.studies = {files.name};

% Remove non-study entries
state.studies = setdiff(state.studies, {'.', '..', 'GPS'});

% Set the list of studies to this list
set(state.gui.studies, 'String', state.studies);

% Default to study in the state
i_study = find(strcmp(state.studies, state.study));
if(length(i_study) ~= 1); i_study = 1; end
set(state.gui.studies, 'Value', i_study);

% Save this set to the GUI state
gpse_set(state);

% Load the study (and subjects, conditions, and stages)
gpse_load_study;

end % function