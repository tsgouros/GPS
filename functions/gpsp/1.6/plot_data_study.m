function plot_data_study(GPSP_vars)
% Happens after you choose a study
%
% Author: Conrad Nied
%
% Date Created: 2012.07.05 as separate function from GPS_grangerplot
% Last Modified: 2012.07.05
%
% Input: The GPS Plot variables structure
% Output: None
% 2012.10.11 - Loosely adapted to GPS1.7

%% Get the current study
i_study = get(GPSP_vars.data_study, 'Value');
studies = get(GPSP_vars.data_study, 'String');
GPSP_vars.study = studies{i_study};

study = gpsp_parameter(GPSP_vars, GPSP_vars.study);

%% Handle conditions list

% Populate List of Conditions
conditions = study.conditions;
set(GPSP_vars.data_condition, 'String', conditions);

% Choose the condition to load
if(isfield(GPSP_vars, 'condition') && sum(strcmp(conditions, GPSP_vars.condition)))
    i_condition = find(strcmp(conditions, GPSP_vars.condition));
else
    i_condition = get(GPSP_vars.data_condition, 'Value');
    if(i_condition > length(conditions)); i_condition = 1; end
end
set(GPSP_vars.data_condition, 'Value', i_condition);

%% Wrap up and set the condition conclusion

% Update handles structure
guidata(GPSP_vars.data_study, GPSP_vars);

% Send to the condition setter
plot_data_condition(GPSP_vars);

end % function