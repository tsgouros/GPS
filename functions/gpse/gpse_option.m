function gpse_option
% Does an conditional edit for particular field types
%
% Author: Conrad Nied
%
% Changelog:
% 2012.10.22 - Created, based on GPS1.7/GPS_edit.m/examine_Callback

state = gpse_get;

% Find the depth of the current editing field
if(strcmp(get(state.gui.field3, 'Enable'), 'on')) % Field 3
    depth = 3;
elseif(strcmp(get(state.gui.field2, 'Enable'), 'on')) % Field 2
    depth = 2;
elseif(strcmp(get(state.gui.field1, 'Enable'), 'on')) % Field 1
    depth = 1;
else % Field 0 (the superstructure itself), should not ever actually happen
    depth = 0;
end % which level are you in the structure?

% Get the field and fieldname
switch depth
    case 0
        fieldname = state.struct.name;
        field = state.struct;
    case 1
        fieldname = state.fieldnames{1};
        field = state.struct.(state.fieldnames{1});
    case 2
        fieldname = state.fieldnames{2};
        field = state.struct.(state.fieldnames{1}).(state.fieldnames{2});
    case 3
        fieldname = state.fieldnames{3};
        field = state.struct.(state.fieldnames{1}).(state.fieldnames{2}).(state.fieldnames{3});
end % switch on the depth of the field

% Different function for different type of variables
switch get(state.gui.type, 'String')
    case 'date'
        % will make sometime...
        
    case 'textbox'
        options.Resize = 'on';
        field = inputdlg({fieldname} , 'Edit Textbox Value(only supports one line :/', 10, field, options);
        
        % Save the edit
        set(state.gui.editbox, 'String', field);
        gpse_editbox
        
    case 'directory'
        direc = uigetdir(field, 'Select the directory');
        
        if(direc ~= 0)
            set(state.gui.editbox, 'String', direc);
            gpse_editbox
        end
        
    case 'filepath'
        [file direc] = uigetfile(field, 'Select the file');
        
        if(direc ~= 0)
            set(state.gui.editbox, 'String', [direc file]);
            gpse_editbox
        end
        
    case 'array'
        t = uitable('Parent', figure(1), 'Data', field, 'ColumnWidth', 'auto');
        
    case 'matrix'
        t = uitable('Parent', figure(1), 'Data', field, 'ColumnWidth', 'auto');
        
end % Switch

end % function