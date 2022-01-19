function GPSR_vars = rois_data_condition_load(GPSR_vars)
% Loads the selected condition on the study list
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI
%
% Date Created: 2012.06.14
% Last Modified: 2012.07.03
% 2012.10.09 - Superficially adapted to GPS1.7

conditions = get(GPSR_vars.data_condition_list, 'String');
i_condition = get(GPSR_vars.data_condition_list, 'Value');
GPSR_vars.condition = conditions{i_condition};

condition = gpsr_parameter(GPSR_vars, GPSR_vars.condition);

%% Load the set
if(isfield(condition, 'sets'))
    sets = condition.sets;
    if(~isempty(sets{1}))
        sets = [{''}; sets];
    end
else
    sets = {''};
end

set(GPSR_vars.data_set_list, 'String', sets);

% Pick the study
if(find(strcmp(sets, GPSR_vars.set)))
    i_set = find(strcmp(sets, GPSR_vars.set));
else
    i_set = 1;
end
set(GPSR_vars.data_set_list, 'Value', i_set);

GPSR_vars.set = sets{i_set};

GPSR_vars = rois_data_set_load(GPSR_vars);
tmp = guidata(GPSR_vars.data_set_list);
GPSR_vars.data_set_list = tmp.data_set_list;

%% Update the GUI
guidata(GPSR_vars.data_condition_list, GPSR_vars);

end % function
