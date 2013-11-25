function gpse_select_field(depth)
% Calls up the value and editing options for a field for GPSe
%
% Author: Conrad Nied
%
% Changelog:
% 2012.10.22 - Created, based on GPS1.7/GPS_edit.m

state = gpse_get;
depth_max = 3;

% Set the field name
if(depth > 0)
    list = sprintf('field%d', depth);
    set(state.gui.(list), 'Enable', 'on');
    
    string = get(state.gui.(list), 'String');
    value = get(state.gui.(list), 'Value');
    fieldname = string{value};
    state.fieldnames{depth} = fieldname;
    
    gpse_set(state);
else
%     list = 'files';
end

if(isfield(state.struct, 'type'))
    type = state.struct.type;
else
    type = 'unknown';
end
for i = 1:depth
    type = sprintf('%s.%s', type, state.fieldnames{i});
end
type = gpse_datatype(type);

% Get the field
switch depth
    case 0
        field = state.struct;
    case 1
        field = state.struct.(state.fieldnames{1});
    case 2
        field = state.struct.(state.fieldnames{1}).(state.fieldnames{2});
    case 3
        field = state.struct.(state.fieldnames{1}).(state.fieldnames{2}).(state.fieldnames{3});
end % switch on the depth of the field

% Set the field qualities

if(strcmp(type, 'struct'))
    nextfield = sprintf('field%d', depth + 1);
    newfields = fields(field);
    
    set(state.gui.editbox, 'Enable', 'off');
    set(state.gui.default, 'Enable', 'off');
    
    % Check to make sure the index won't exceed
    if(max(get(state.gui.(nextfield), 'Value')) > length(newfields))
        set(state.gui.(nextfield), 'Value', 1);
    end
    
    % Set the next fields
    set(state.gui.(nextfield), 'String', newfields);
    
    % Set the type in case it cannot progress further
    set(state.gui.type, 'String', type);
    
    % Load the next field
    gpse_select_field(depth + 1);
else
    set(state.gui.editbox, 'Enable', 'on');
    set(state.gui.default, 'Enable', 'on');
    
    % Switch on the type of the data
    switch type
        case {'string', 'date', 'filename'}
            display = field;
            option = 'off';
            
        case {'number', 'boolean'}
            display = num2str(field);
            option = 'off';
            
        case 'textbox'
            if(~iscell(field))
                display = '';
            else
                display = field{1};
            end
            
            option = 'View';
            
        case {'directory', 'filepath'}
            display = field;
            option = 'Browse';
            
        case {'array', 'matrix', 'cellstr'}
            display = gpse_convert_string(field);
            option = 'View';
            
        otherwise
            display = '';
            option = 'off';
            
            set(state.gui.default, 'Enable', 'off');
    end % switch type
    
    % Set the editbox display
    set(state.gui.editbox, 'String', display);
    
    % Handle the option
    if(strcmp(option, 'off'));
        set(state.gui.option, 'String', '');
        set(state.gui.option, 'Enable', 'off');
    else
        set(state.gui.option, 'String', option);
        set(state.gui.option, 'Enable', 'on');
    end
    
    % Turn off the following fields
    for i = (depth + 1) : depth_max
        nextlist = state.gui.(sprintf('field%d', i));
        set(nextlist, 'String', {''});
        set(nextlist, 'Enable', 'off');
        set(nextlist, 'Value', 1);
    end

    % Set the type string
    set(state.gui.type, 'String', type);
    
end % % structure or regular data?

end % function