function GPSe(varargin)
% Opens a GUI to use GPS edit functions
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.07 - Created, based on GPS1.7/GPSa.m
% 2012.10.22 - Added inputs
% 2013.04.05 - Cut out the function tree loading (GPS now responsible), 1.8

%% Setup GUI parameters

% Initialize the state structure
state.name = 'state';

% Initialize the state structure
state.dir = gps_presets('dir');

% Get the position of the monitor
state.gui.position.screen = get(0, 'ScreenSize');

% Start the figure
state.gui.fig = 6753000;
figure(state.gui.fig)

% Load GPSa state (or default state)
gpsa_state = gpsa_get;
if(~isempty(gpsa_state))
    state.study = gpsa_state.study;
else
    state.study = 'WPM';
end

% Handle inputs
if(nargin >= 1);
    state.selection = varargin{1};
else
    state.selection = state.study;
end

% Save the state
gpse_set(state);

% Initialize the GUI figure
gpse_init_fig;

% Waiting? Doesn't work right now
if(nargin >= 2);
    uiwait(state.gui.fig);
end

end % function