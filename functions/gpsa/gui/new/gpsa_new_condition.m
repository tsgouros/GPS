function gpsa_new_condition
% Makes a new condition and opens GPSe to edit it
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.05 - Created
% 2013.04.24 - GPS1.8 Changed subset/subsubset to condition hierarchy
% 2013.06.11 - Adds condition to state now

% Get state
state = gpsa_get;

% Get input for the name of this condition
name = inputdlg({'Name'}, 'New Condition', 1, {''});
name = name{1};

% Create the condition using default parameters
condition = gpse_convert_condition(name);
gpsa_parameter(condition);

% Save to the study
study = gpsa_parameter(state.study);
study.conditions = unique([study.conditions; name]);
gpsa_parameter(study);

% Add to the GUI
state.conditions = study.conditions;
set(state.gui.condition_list, 'String', state.conditions);

% Set the GUI to index to this condition now
i_condition = find(strcmp(study.conditions, name));
set(state.gui.condition_list, 'Value', i_condition);

% Save to the GUI state
gpsa_set(state);

% % Edit the condition
% gpsa_edit_condition;

end % function