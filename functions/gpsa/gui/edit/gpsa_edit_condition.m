function gpsa_edit_condition
% Opens GPSe to edit a condition
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.05 - Created
% 2012.10.08 - Reloads the condition in the GUI
% 2012.10.22 - New edit GUI
% 2013.04.25 - GPS1.8 Changed subset design to condition hierarchy

%% Get input

% State
state = gpsa_get;

% Condition (only get the first name you see)
condition = get(state.gui.condition_list, 'String');
i_condition = get(state.gui.condition_list, 'Value');
i_condition = i_condition(1);
condition = str_unbold(condition{i_condition});

%% Open up GPSe

GPSe(condition, 'wait');

% Reload the condition in the GUI
gpsa_load_condition;

end % function