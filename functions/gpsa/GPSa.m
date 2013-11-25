function GPSa
% Opens a GUI to use GPS analysis functions
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.09.17 - Created
% 2012.10.05 - Removed excess '/' from state.dir
% 2013.04.05 - Works as a subsidary of GPS now, updated for GPS1.8

%% Setup GUI parameters

% Initialize the state structure
state.name = 'state';

% Initialize the state structure
state.dir = gps_presets('dir');

% Get the position of the monitor
state.gui.position.screen = get(0, 'ScreenSize');

% Start the figure
state.gui.fig = gps_presets('gpsafig');
figure(state.gui.fig)

% Save the state
gpsa_set(state);

% Initialize the GUI figure
gpsa_init_fig;

end % function