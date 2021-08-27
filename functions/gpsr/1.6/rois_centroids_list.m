function GPSR_vars = rois_centroids_list(GPSR_vars)
% Lists the centroids in the proper GUI locations
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI
%
% Date Created: 2012.06.25
% Last Modified: 2012.06.29

%% Compose the list

points = getappdata(GPSR_vars.datafig, 'points');
brain = getappdata(GPSR_vars.datafig, 'brain');
if(isappdata(GPSR_vars.datafig, 'rois'))
    roi_settings = getappdata(GPSR_vars.datafig, 'rois');
end

names = cell(length(points), 1);
N_points = length(points);

% For each centroid
for i_point = 1:N_points
    
    % Refresh name
    points(i_point).numInRegion = sum(...
        strcmp({points(1:i_point).aparc}, points(i_point).aparc) &...
        strcmp({points(1:i_point).hemi}, points(i_point).hemi));
    points(i_point).name = sprintf('%s_%s_%d',...
        points(i_point).hemi, points(i_point).aparc, points(i_point).numInRegion);
    points(i_point).number = (points(i_point).hemi == 'R') * 10000 + points(i_point).aparcI * 100 + points(i_point).numInRegion;
    
    % Find prefix based on import status, settings, and roiness
    point = points(i_point);
    if (~point.ROI)
        prefix = '*';
    elseif(point.imported)
        prefix = '+';
    elseif(exist('roi_settings', 'var'))
        if(roi_settings.thresh.sim    == point.thresh.sim   && ...
           roi_settings.thresh.redun  == point.thresh.redun && ...
           roi_settings.thresh.cont   == point.thresh.cont  && ...
           roi_settings.weight.local  == point.weight.local && ...
           roi_settings.weight.act    == point.weight.act   && ...
           roi_settings.weight.actnum == point.weight.actnum)
            prefix = '';
        else
            prefix = '$';
        end % If they have the same settings
    else
        prefix = '';
    end
    
    % Create colored name
    color = floor(brain.aparcCmap(point.aparcI, :) * 255);
    color = sprintf('%02X%02X%02X', color(1), color(2), color(3));
    name = sprintf('<HTML>%s%s <FONT color="#%s">%s</FONT> %1d</HTML>',...
        prefix, point.hemi, color, point.aparc, point.numInRegion);
    names{i_point} = name;
end

setappdata(GPSR_vars.datafig, 'points', points);

%% Set the list when important

set(GPSR_vars.metrics_sim_centroids, 'String', names);
if(max(get(GPSR_vars.metrics_sim_centroids, 'Value')) > N_points)
    set(GPSR_vars.metrics_sim_centroids, 'Value', 1);
end
    
set(GPSR_vars.regions_list, 'String', names);
if(max(get(GPSR_vars.regions_list, 'Value')) > N_points)
    set(GPSR_vars.regions_list, 'Value', 1);
end
set(GPSR_vars.regions_list, 'Max', N_points);
set(GPSR_vars.regions_list, 'ListboxTop', N_points);

%% Display the counts

N_ROIs = sum([points.ROI] & ~[points.imported]);
set(GPSR_vars.regions_rois_n, 'String', num2str(N_ROIs));
set(GPSR_vars.regions_poten_n, 'String', num2str(sum(~[points.ROI])));
set(GPSR_vars.regions_imp_n, 'String', num2str(sum([points.imported])));
% set(GPSR_vars.regions_diff_n, 'String', num2str(sum([points.diff])));

%% Update GUI buttons

if(N_ROIs > 0)
    set(GPSR_vars.regions_show, 'Enable', 'on');
    set(GPSR_vars.quick_regions, 'Enable', 'on');
else
    set(GPSR_vars.regions_show, 'Enable', 'off');
    set(GPSR_vars.quick_regions, 'Enable', 'off');
end

% Update the GUI
guidata(GPSR_vars.centroids_find, GPSR_vars);
% set(GPSR_vars.panels_regions, 'Value', 1);
% rois_panels(GPSR_vars.panels_regions, GPSR_vars);

end % function
