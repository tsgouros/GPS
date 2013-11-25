function debug
% Gets some data for Conrad to help to debug an error
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-08-01 Created

state = gpsa_get;
study = gpsa_parameter(state, state.study);
isubj = get(state.gui.subject_list, 'Value');
icond = get(state.gui.condition_list, 'Value');
filename = sprintf('%s/debug_%s.mat', state.dir, study.name);
save(filename);

end