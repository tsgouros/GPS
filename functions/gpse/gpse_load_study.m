function gpse_load_study
% Loads a study to initialize the list of files
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.22 - Created, based on GPS1.7/GPS_edit.m
% 2013.06.18 - Cleanup

state = gpse_get;

%% Get the selected study
i_study = get(state.gui.studies, 'Value');
state.study = state.studies{i_study};

%% Load file list

% Get the list of folders from the parameters folder
files = sprintf('%s/%s/*.mat', gps_presets('studyparameters'), state.study);
files = dir(files);

% Presume each name of a folder is a different study (should be)
filenames = {files.name};

% Remove extensions and check for the file we want to default selection to
i_selected_file = 1;

for i_file = 1:length(filenames)
    filename = filenames{i_file};
    
    % Find and remove the extension
    filename = filename(1:end-4);
    
    % Save on filename list
    filenames{i_file} = filename;
    
    % Check to see if this is the name of the file we want
    if(strcmp(state.selection, filename))
        i_selected_file = i_file;
    elseif(i_selected_file == 1 && i_file == length(filenames))
        i_selected_file = find(strcmp(filenames, state.study));
    end
end

set(state.gui.files, 'Value', i_selected_file);
set(state.gui.files, 'String', filenames);

% Save this set to the GUI state
gpse_set(state);

% Load the file
gpse_load_file;

end % function
