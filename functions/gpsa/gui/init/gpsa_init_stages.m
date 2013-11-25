function gpsa_init_stages
% Initializes stages list for GPS: Analysis
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.09.17 - Created
% 2012.09.21 - Functionality achieved

state = gpsa_get;

%% Get the list of stagse

% Load all functional directories
dirs = dir([state.dir '/functions/gpsa/*']);

% Find the names of the files in the GPSA function folder
stages = {dirs.name};

% Include only stage directories in the list
stages = stages([dirs.isdir]);

% Exclude certain directories
state.stages = setdiff(stages, {'.', '..', 'init', 'load', 'color'});

% Set the stages list to 
set(state.gui.stage_list, 'String', state.stages);

% Save State
gpsa_set(state);

% Load functions for the stages selected
gpsa_load_stage;


end % function