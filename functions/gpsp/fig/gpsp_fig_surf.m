function handle = gpsp_fig_surf(varargin)
% Returns the handle of the surface plotting figure, if it doesn't exist, makes it
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-07-14 Created as separate function from GPS1.8/gpsp_setup.m
% 2013-08-06 Adjustable height and width

handle = 6757200;

if(nargin == 0 && ~ishghandle(handle))
    state = gpsp_get;
    width = str2double(get(state.surf_width, 'String'));
    height = str2double(get(state.surf_height, 'String'));
    
    figure(handle);
    clf(handle);
    set(handle, 'Menubar', 'none');
    set(handle, 'Toolbar', 'none');
    set(handle, 'Name', 'Surface (GPS: Plotting)');
    set(handle, 'Numbertitle', 'off');
    set(handle, 'Units', 'Pixels');
    set(handle, 'Position', [320, 100, width, height]);
    set(handle, 'Renderer', 'OpenGL');
    
    % Initialize it's axes
    gpsp_fig_surf_axes;
end

end % function