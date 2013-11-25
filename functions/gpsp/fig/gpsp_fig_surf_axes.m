function handle = gpsp_fig_surf_axes
% Returns the handle of the surface plotting figure axes, if it doesn't exist, makes it
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-07-14 Created as GPS1.8/gpsp_fig_surf_axes

% Search the figure for the child axes
figure_handle = gpsp_fig_surf;
handle = gca(figure_handle);%get(figure_handle, 'CurrentAxes');
if(~ishghandle(handle))
    handle = gca(figure_handle);
end
set(handle, 'Units', 'Normalized');
set(handle, 'Position', [0.05 0.05 0.9 0.9]);

end % function