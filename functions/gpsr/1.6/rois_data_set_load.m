function rois_data_set_load(GPSR_vars)
% Loads the selected condition set on the study list
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI
%
% Date Created: 2012.06.14
% Last Modified: 2012.06.14
% 2012.10.09 - Superficially adapted to GPS1.7
% 2013.07.10 - Cleared a bit

sets = get(GPSR_vars.data_set_list, 'String');
i_set = get(GPSR_vars.data_set_list, 'Value');
GPSR_vars.set = sets{i_set};
GPSR_vars.uset = sets{i_set};
if(~isempty(GPSR_vars.uset))
    GPSR_vars.uset = sprintf('_%s', GPSR_vars.uset);
end

study = gpsr_parameter(GPSR_vars, GPSR_vars.study);
condition = gpsr_parameter(GPSR_vars, GPSR_vars.condition);

%% Whatever needs to be done

% Set browsing defaults
rois_data_measure_defaults(GPSR_vars);
GPSR_vars = guidata(GPSR_vars.data_subject_list);

%% Update the GUI
guidata(GPSR_vars.data_set_list, GPSR_vars);

end % function