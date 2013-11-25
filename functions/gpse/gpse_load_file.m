function gpse_load_file
% Loads a study to initialize the list of files
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.22 - Created, based on GPS1.7/GPS_edit.m
% 2013.06.18 - GPS1.8 update. Changed subset to condition

state = gpse_get;

% Save the last structure
if(isfield(state, 'struct') && ~isempty(state.struct))
    gpse_parameter(state.struct);
end

% Get the selected file
i_file = get(state.gui.files, 'Value');
files = get(state.gui.files, 'String');
state.file = files{i_file};

% Load
state.struct = gpse_parameter(state.file);

% Update the structure to the latest version
if(isfield(state.struct, 'type'))
    % Screen for format compatibility
    if(strcmp(state.struct.type, 'subject'))
        state.struct = gpse_convert_subject(state.struct);
    elseif(strcmp(state.struct.type, 'study'))
        state.struct = gpse_convert_study(state.struct);
    elseif(strcmp(state.struct.type, 'condition') ||  strcmp(state.struct.type, 'subset'))
        state.struct = gpse_convert_condition(state.struct);
    end
end

% Clear the field names
state.fieldnames = {};

% Save this set to the GUI state
gpse_set(state);

% Load the file
gpse_select_field(0)

end % function