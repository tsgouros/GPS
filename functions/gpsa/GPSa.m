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

  %% For some reason, we re-create the state variable here.  I guess
  %% this means that it is not passed down from GPS.m.   -ts

% Initialize the state structure
state.name = 'state';

% We are going to cheat here by adding explicit paths to the MNE and
% freesurfer software
  state.fshome = getenv('FREESURFER_HOME');
  if (state.fshome == "")
    state.fshome = '/Applications/freesurfer';
  end
  state.fsfasthome = getenv('FSFAST_HOME');
  if (state.fsfasthome == "")
    state.fsfasthome = '/Applications/freesurfer/fsfast';
  end
  state.mnehome = getenv('MNE_ROOT');
  if (state.mnehome == "")
    state.mnehome = '/Applications/MNE-2.7.0-3106-MacOSX-i386';
  end


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
