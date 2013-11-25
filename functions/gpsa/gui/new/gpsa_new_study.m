function gpsa_new_study
% Makes a new study and opens GPSe to edit it
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.08 - Created based on GPS1.7/gpsa_new_subset.m
% 2013.04.05 - Fixed a bug in the modification of the study list
% 2013.04.24 - GPS1.8 fixed spelling error
% 2013.06.11 - Properly adds a new study now
% 2013.06.18 - Changed environmental variable USERNAME to USER

% Get state
state = gpsa_get;

% Get input for the name of this study
inputs = inputdlg({'Name', 'Base Directory', 'Block Names'}, 'New Study', 1, {'', '', ''});

if(isempty(inputs))
    fprintf('You closed the new study prompt')
else
    study.name = inputs{1};
    study.basedir = inputs{2};
    study.blocks = gpse_convert_string(inputs{3}, 'cellstr');
end

% Make the study folder in the parameters directory
folder = sprintf('%s/parameters/%s', state.dir, study.name);
if(~exist(folder, 'dir')); mkdir(folder); end

% Set the study in the GUI
state.study = study.name;

% Create the study using default parameters
study = gpse_convert_study(study);
gpsa_parameter(study);

% Modify the study list in the GUI and add this study
studies = get(state.gui.study_list, 'String');
studies = unique([studies; study.name]);
set(state.gui.study_list, 'String', studies);

% Update the GUI studies list and the user's list
state.studies = studies;
gpsa_set(state);

user = getenv('USER');
userstudies_filename = sprintf('%s/GPS/userstudies.mat', gps_presets('parameters'));
if(exist(userstudies_filename, 'file'))
    userstudies = load(userstudies_filename);
end % If the preset file exists
userstudies.(user) = state.studies;
save(userstudies_filename, '-struct', 'userstudies');

% Set the GUI to index to this study now
i_study = find(strcmp(studies, study.name));
set(state.gui.study_list, 'Value', i_study);

end % function