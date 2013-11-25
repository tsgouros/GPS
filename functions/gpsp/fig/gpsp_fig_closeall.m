function gpsp_fig_closeall
% Confirms the user wants to close the GUI and closes all windows
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012-07-15 Created as GPS1.8/gpsp_fig_closeall

state = gpsp_get;

%% Set up figures

try
    answer = questdlg('Are you sure you want to close GPS: Plotting?');
catch
    answer = 'Yes';
end

if strcmp(answer, 'Yes')
    try handle = state.guifig;
    if(ishghandle(handle)); delete(handle); end; end %#ok<*TRYNC>
    handle = gpsp_fig_data([]);
    try if(ishghandle(handle)); delete(handle); end; end
    handle = gpsp_fig_surf([]);
    try if(ishghandle(handle)); delete(handle); end; end
    handle = gpsp_fig_tc([]);
    try if(ishghandle(handle)); delete(handle); end; end
end

end % function