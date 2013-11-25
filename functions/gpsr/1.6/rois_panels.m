function rois_panels(hObject, handles)
% Arranges panels for GPSR
%
% Author: Conrad Nied
%
% Input: The current object and the Granger Processing Stream ROIs handle
% Output: none, affects the GUI
%
% Based on granger_plot_options of 2012.05.17
% Date Created: 2012.06.14
% Last Modified: 2012.06.21

%% Get Parameters

option_name = get(hObject, 'Tag');
enabling = ~strcmp(option_name, 'figure1') && get(hObject, 'Value');
metrics_list = ~isempty(strfind(option_name, 'metrics'));

%% Set all menus aside and set all buttons to off

% Set option buttons off
options = {'panels_data', 'panels_brain', 'panels_metrics',...
    'panels_centroids', 'panels_regions', 'panels_save'};

for i = 1:length(options)
    set(handles.(options{i}), 'Value', 0);
end


% Move away all panels
panels = {'data_panel', 'brain_panel', 'metrics_panel',...
    'centroids_panel', 'regions_panel', 'save_panel',...
    'metrics_maxact_panel', 'metrics_sim_panel'};

for i = 1:length(panels)
    pos = get(handles.(panels{i}), 'Position');
    pos(1) = 25;
    pos(2) = 1000;
    set(handles.(panels{i}), 'Position', pos);
end

%% Retrieve the ones wanted

if(enabling)
    panel = '';
    switch option_name
        case 'panels_data'; panel = 'data_panel';
        case 'panels_brain'; panel = 'brain_panel';
        case {'panels_metrics', 'metrics_list'};
            switch get(handles.metrics_list, 'Value')
                case 4; panel = 'metrics_maxact_panel';
                case 5; panel = 'metrics_sim_panel';
            end % Switch on the sublist of the metric
        case 'panels_centroids'; panel = 'centroids_panel';
        case 'panels_regions'; panel = 'regions_panel';
        case 'panels_save'; panel = 'save_panel';
    end % Switch on the option name
    
    if(~isempty(panel) && ~metrics_list)
        set(handles.(option_name), 'Value', 1)
        pos = get(handles.(panel), 'Position');
        pos(2) = 490 - pos(4);
        set(handles.(panel), 'Position', pos);
    elseif(~isempty(panel) && metrics_list)
        pos = get(handles.(panel), 'Position');
        pos(2) = 100 - pos(4);
        set(handles.(panel), 'Position', pos);
    end
end

if metrics_list
    set(handles.panels_metrics, 'Value', 1);
    pos = get(handles.metrics_panel, 'Position');
    pos(2) = 490 - pos(4);
    set(handles.metrics_panel, 'Position', pos);
end

%% Update the GUI
guidata(hObject, handles);

end % function