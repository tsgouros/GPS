function gpse_editbox
% Save the new value entered in the editbox to the structure
%
% Author: Conrad Nied
%
% Changelog:
% 2012.10.22 - Created, based on GPS1.7/GPS_edit.m

state = gpse_get;

new_value = get(state.gui.editbox, 'String');

% Change how you have to save the data
switch get(state.gui.type, 'String')
    case {'string', 'date', 'textbox', 'directory', 'filename', 'filepath'}
%         new_value = new_value;
    case {'number', 'boolean'}
        new_value = str2double(new_value);
    case 'array'
        new_value = gpse_convert_string(new_value, 'array');
    case 'matrix'
        new_value = gpse_convert_string(new_value, 'matrix');
    case 'cellstr'
        new_value = gpse_convert_string(new_value, 'cellstr');
end % Switch

% Change the value in the original structure


if    (strcmp(get(state.gui.field3, 'Enable'), 'on')) % Field 3
    state.struct.(state.fieldnames{1}).(state.fieldnames{2}).(state.fieldnames{3}) = new_value;
    
elseif(strcmp(get(state.gui.field2, 'Enable'), 'on')) % Field 2
    state.struct.(state.fieldnames{1}).(state.fieldnames{2}) = new_value;
    
elseif(strcmp(get(state.gui.field1, 'Enable'), 'on')) % Field 1
    state.struct.(state.fieldnames{1}) = new_value;
end % which level are you in the structure?

% Save the state
gpse_set(state);

end % function