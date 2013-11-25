function gpsr_menu_panel(varargin)
% Arranges panels for GPSr
%
% Author: Conrad Nied
%
% Input: The panel to affect
% Output: none, affects the GUI
%
% Changelog:
% Based on granger_plot_options of 2012.05.17 then
% Based on GPS1.6/rois_panel.m of 2012.06.21

%% Get parameters

state = gpsr_get;
if(nargin == 1)
    feature = varargin{1};
else
    feature = '';
end

%% Set all menus aside and set all buttons to off

features = {'cortex', 'timecourses', 'overlays', 'centroids', 'regions'};

for i = 1:length(features)
    if(strcmp(feature, features{i})); selected = 1; else selected = 0; end
    
    % Turn the button off
    set(state.menu.features.(features{i}), 'Value', selected);
    
    % Change the position
    pos = get(state.menu.(features{i}).panel, 'Position');
    if(selected); pos(2) = 20; else pos(2) = 600; end
    set(state.menu.(features{i}).panel, 'Position', pos);
end % for all features

end % function