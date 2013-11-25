function handle = gpsp_fig_tc(varargin)
% Returns the handle of the timecourse plotting figure, if it doesn't exist, makes it
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-07-14 Created as separate function from GPS1.8/gpsp_setup.m
% 2013-08-06 Adjustable height and width

handle = 6757300;

if(nargin == 0 && ~ishghandle(handle))
    state = gpsp_get;
    width = str2double(get(state.tcs_width, 'String'));
    height = str2double(get(state.tcs_height, 'String'));
    
    figure(handle);
    clf(handle);
    set(handle, 'Menubar', 'none');
    set(handle, 'Toolbar', 'none');
    set(handle, 'Name', 'Timecourses (GPS: Plotting)');
    set(handle, 'Numbertitle', 'off');
    set(handle, 'Units', 'Pixels');
    set(handle, 'Position', [320, 100, width, height]);
    
    gpsp_fig_tc_axes;
end

end % function