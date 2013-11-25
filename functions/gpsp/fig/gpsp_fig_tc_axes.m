function handle = gpsp_fig_tc_axes
% Returns the handle of the timecourse plotting figure axes, if it doesn't exist, makes it
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-07-14 Created as GPS1.8/gpsp_fig_tc_axes

% Search the figure for the child axes
figure_handle = gpsp_fig_tc;
handle = get(figure_handle, 'CurrentAxes');
if(~ishghandle(handle))
    handle = gca(figure_handle);
end
set(handle, 'Units', 'Normalized');
set(handle, 'Position', [.1 .1 0.8 0.8]);

end % function