function rois_regions_remove(GPSR_vars, varargin)
% Makes ROIs based on similarity and other metrics
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI datafig
%
% Date Created: 2012.06.27
% Last Modified: 2012.06.27

%% Get settings from GUI

points = getappdata(GPSR_vars.datafig, 'points');
all_points = 1:length(points);

if(~isempty(varargin))
    if(strcmp(varargin{1}, 'all'))
        selection = all_points;
    else
        selection = get(GPSR_vars.regions_list, 'Value');
    end
else
    selection = get(GPSR_vars.regions_list, 'Value');
end

%% Update points
points(selection) = [];

setappdata(GPSR_vars.datafig, 'points', points);
rois_centroids_list(GPSR_vars)
GPSR_vars = guidata(GPSR_vars.regions_list);
rois_draw(GPSR_vars);

end % function
