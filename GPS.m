function GPS
% Opens a GUI to direct the user on which GUI they would like to start up
%
% Author: Alexander Conrad Nied (anied@cs.washington.edu)
%
% Changelog:
% 2013.04.03 - Created for GPS1.8
% 2013.07.02 - Gets figure number from preset now
%
% GPS is a GUI-based program composed by David Gow and members of his lab
% at the Massachusetts General Hospital to automate MNE and FSL analyses
% of MR-constrained MEG/EEG data and to perform Kalman filter based Granger
% analyses of those data.
%
% Copyright (C) 2014  Alexander Conrad Nied and David Gow
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% Setup GUI parameters

% Initialize the state structure
state.name = 'state';

% Initialize the state structure
state.dir = gps_presets('dir');


% We are going to cheat here by loading the necessary environment
% variables for Freesurfer and MNE each time those programs are 
% invoked, instead of relying on the inherited environment.
state.setenv = sprintf("source %s/gps_init.bash; ", state.dir);

% Get the position of the monitor
state.gui.position.screen = get(0, 'ScreenSize');

% Load function directory
addpath(genpath(gps_presets('functions')));
addpath(pwd);

% Start the figure
state.gui.fig = gps_presets('gpsafig');
figure(state.gui.fig)

% Initialize the GUI figure
w = 160; % Width of the GUI
h = 170; % Height of the GUI
clf(state.gui.fig)
set(state.gui.fig, 'Visible', 'on');
set(state.gui.fig, 'Units', 'pixels');
set(state.gui.fig, 'MenuBar', 'none');
set(state.gui.fig, 'ToolBar', 'none');
set(state.gui.fig, 'NumberTitle', 'off');
set(state.gui.fig, 'Name', 'GPS');
set(state.gui.fig, 'Color', [0.8 0.8 0.8]);
state.gui.position.fig = [state.gui.position.screen(3)/2 - w/2, state.gui.position.screen(4)/2 - h/2, w, h];
set(state.gui.fig, 'Position', state.gui.position.fig);

% % Draw the title
% state.gui.title = uicontrol(state.gui.fig);
% set(state.gui.title, 'Style', 'Text');
% set(state.gui.title, 'Units', 'pixels');
% set(state.gui.title, 'Position', [20, 140, 120, 25]);
% set(state.gui.title, 'BackgroundColor', [0.8 0.8 0.8]);
% set(state.gui.title, 'String', 'GPS');
% set(state.gui.title, 'FontSize', 14);

% Draw the Analysis button
state.gui.analysis = uicontrol(state.gui.fig);
set(state.gui.analysis, 'Style', 'PushButton');
set(state.gui.analysis, 'Units', 'pixels');
set(state.gui.analysis, 'Position', [20, 125, 120, 25]);
set(state.gui.analysis, 'BackgroundColor', [0.8 0.8 0.8]);
set(state.gui.analysis, 'String', 'Analysis');
set(state.gui.analysis, 'FontSize', 14);
set(state.gui.analysis, 'Callback', {@GPSa, state});
% delete(' num2str(state.gui.fig) ');

% Draw the Editor button
state.gui.editor = uicontrol(state.gui.fig);
set(state.gui.editor, 'Style', 'PushButton');
set(state.gui.editor, 'Units', 'pixels');
set(state.gui.editor, 'Position', [20, 90, 120, 25]);
set(state.gui.editor, 'BackgroundColor', [0.8 0.8 0.8]);
set(state.gui.editor, 'String', 'Editor');
set(state.gui.editor, 'FontSize', 14);
set(state.gui.editor, 'Callback', 'GPSe;');

% Draw the Regionator button
state.gui.regionator = uicontrol(state.gui.fig);
set(state.gui.regionator, 'Style', 'PushButton');
set(state.gui.regionator, 'Units', 'pixels');
set(state.gui.regionator, 'Position', [20, 55, 120, 25]);
set(state.gui.regionator, 'BackgroundColor', [0.8 0.8 0.8]);
set(state.gui.regionator, 'String', 'Regionator');
set(state.gui.regionator, 'FontSize', 14);
set(state.gui.regionator, 'Callback', 'GPS_rois;');

% Draw the Plot Drawer button
state.gui.plot = uicontrol(state.gui.fig);
set(state.gui.plot, 'Style', 'PushButton');
set(state.gui.plot, 'Units', 'pixels');
set(state.gui.plot, 'Position', [20, 20, 120, 25]);
set(state.gui.plot, 'BackgroundColor', [0.8 0.8 0.8]);
set(state.gui.plot, 'String', 'Plot Drawer');
set(state.gui.plot, 'FontSize', 14);
set(state.gui.plot, 'Callback', 'GPSp;');

%% Save the state to the figure's application data
gps_set(state);

end % function
