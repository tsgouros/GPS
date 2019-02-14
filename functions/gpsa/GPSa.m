function GPSa(source, event, state)
% Opens a GUI to use GPS analysis functions
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.09.17 - Created
% 2012.10.05 - Removed excess '/' from state.dir
% 2013.04.05 - Works as a subsidary of GPS now, updated for GPS1.8
% 2019.02.14 - CHanged to get state from GPS above.  -ts
  
% Save the state
gpsa_set(state);

% Initialize the GUI figure
gpsa_init_fig;

end % function
