function gpsp_set(structure)
% Saves a structure to the GPS: Plotting saving figure
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Input: The structure you want to save and optionally the name of the
% structure you want to save
% Output: None
%
% Changelog:
% 2012-10-11 Created based on GPS 1.7 gpsr_set.m
% 2013-07-14 Updated for GPS1.8 design

if(~isfield(structure, 'name'))
    error('Must name a structure to save it');
end

setappdata(gpsp_fig_data, structure.name, structure);

end % function