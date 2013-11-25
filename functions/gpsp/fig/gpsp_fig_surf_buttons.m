function gpsp_fig_surf_buttons(hObject)
% Sets buttons as a response to a button press by a surface button
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-08-10 Created

% Get the values 2 == cort on, 1 == circle on, 0 == none
tag = get(hObject, 'Tag');
value = get(hObject, 'Value');

switch tag
    case 'surf_cort'
        value = value * 2;
    case 'surf_circle'
        value = value;
    case 'surf_none';
        value = 1 - value;
    otherwise
        value = 1;
end

% Set the buttons in the GUI
state = gpsp_get;
set(state.surf_cort, 'Value', value == 2)
set(state.surf_circle, 'Value', value == 1)
set(state.surf_none, 'Value', value == 0)

if value == 2
    set(state.screenshot_surf, 'String', 'Cortex');
elseif value == 1
    set(state.screenshot_surf, 'String', 'Circle');
end

end % function