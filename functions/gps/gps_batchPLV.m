function gps_batchPLV
% Performs a batch PLV function on the launchpad server
%
% Author: Conrad Nied
%
% Changelog:
% 2012.10.31 - Created to run PLV for PTC3

% to run do
% ssh launchpad
%  type your password
% cd /cluster/dgow/GPS1.7/functions/gps
% pbsumit -q matlab -n 4 -c "matlab.new -nodisplay -nodesktop -nojvm -r gps_batchPLV"

%% Initialize

% Initialize the state structure
state.name = 'state';
state.dir = gps_presets('dir');

% Load function directory
addpath(genpath(gps_presets('fdir')));

% Load the study, subjects, and subsets
state.study = 'PTC3';
study = gpsa_parameter(state, state.study);

state.subject = study.subjects{11}; % specifying subjects for now
state.subset = study.subsets(6:end);

%% Perform

gpsa_do(state, 'gpsa_plv_compute');

exit % stop matlab

end % function