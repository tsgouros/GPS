function gpsa_load_condition
% Loads condition information for GPS: Analysis
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.09.19 - created, branched from gpsa_init_studies
% 2012.10.05 - Fixed inconsistency with state and structure subsets
% 2013.04.25 - GPS1.8 Changed subset design to condition hierarchy
% 2013.06.11 - Just a convention change

state = gpsa_get;

% Set the index of the list if it exceeds the bounds
i_condition = get(state.gui.condition_list, 'Value');
conditions = get(state.gui.condition_list, 'String');
if(max(i_condition) > length(conditions) || min(i_condition) < 1)
    i_condition = 1;
    set(state.gui.condition_list, 'Value', i_condition);
end % If i_subject is invalid
    
% Get the condition parameter
for j_condition = i_condition
    state.condition = str_unbold(conditions{j_condition});
    condition = gpsa_parameter(state.condition);

    % Initialize a condition if the structure didn't exist
    if(isempty(condition))
        condition.name = state.condition;
    end
    
    % Update the condition for version
    if(~isfield(condition, 'version') || strcmp(condition.version, 'GPS1.7') || 1)
        condition = gpse_convert_condition(condition);
        gpsa_parameter(condition);
    end
end

% Save State
gpsa_set(state);

end % function