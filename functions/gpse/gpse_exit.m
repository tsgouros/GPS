function gpse_exit
% Saves the open file and closes the editing GUI
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.22 - Created based on GPS1.7/GPS_edit.m/exit_Callback

state = gpse_get('state');

% Save parameter
if(isfield(state, 'struct') && ~isempty(state.struct))
    gpse_parameter(state.struct);
end

% Close Window
delete(state.gui.fig);
uiresume(); % If we were waiting before


end % function