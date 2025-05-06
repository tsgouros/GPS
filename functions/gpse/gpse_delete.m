function gpse_delete
% Delets a parameter file from the study directory
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.06.18 - Created

% Get the state
state = gpse_get;

% Produce the filename for the selected file
i_file = get(state.gui.files, 'Value');
files = get(state.gui.files, 'String');
filename = sprintf('%s/%s/%s.mat', gps_presets('studyparameters'), state.study, files{i_file});

% Check the user that he wants to delete the file
answer = questdlg({'Are you sure you want to delete the file?', filename});

if(strcmp(answer, 'Yes'))
    
    % Clear it from the state
    state.struct = [];
    gpse_set(state);
    
    % Remove the file
    delete(filename);
    
    % Load the study fresh
    gpse_load_study;
else
    fprintf('No file deleted\n');
end

end % function
