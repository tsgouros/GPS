function GPSr
% Opens a GUI to use GPS regioning functions
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.05.31 - Made based on GPS1.8/GPSa.m

%% Setup GUI parameters

% Initialize the state structure
state.name = 'state';

% Initialize the state structure
state.dir = gps_presets('dir');

% Get the position of the monitor
state.position.screen = get(0, 'ScreenSize');

%% Start the Menu Figure
state.menu.fig = 6752000;
figure(state.menu.fig)

% Save the state
gpsr_set(state);

% Initialize the menu figure
gpsr_menu_init;

%% Start the Data Figure
state.data.fig = 6752100;
figure(state.data.fig)

% Save the state
gpsr_set(state);

% Initialize the data figure


end % function