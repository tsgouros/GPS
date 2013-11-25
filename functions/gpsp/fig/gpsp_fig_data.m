function handle = gpsp_fig_data(varargin)
% Returns the handle of the data figure, if it doesn't exist, makes it
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-07-14 Created as separate function from GPS1.8/gpsp_setup.m

handle = 6757100;

if(nargin == 0 && ~ishghandle(handle))
    figure(handle);
    clf(handle);
    set(handle, 'Menubar', 'none');
    set(handle, 'Toolbar', 'none');
    set(handle, 'Name', 'Data (GPS: Plotting)');
    set(handle, 'Numbertitle', 'off');
    set(handle, 'Units', 'Pixels');
    set(handle, 'Position', [1, 1, 300, 10]);
    set(handle, 'CloseRequestFcn', 'gpsp_fig_closeall;');
end

end % function