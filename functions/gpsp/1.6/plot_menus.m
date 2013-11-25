function plot_menus(hObject, handles)
% Arranges option menus for GPSP
%
% Author: Conrad Nied
%
% Input: The current object and the Granger Processing Stream Plotting handle
% Output: none, affects the GUI
%
% Date Created: 2012.08.07 from plot_menus
% Last Modified: 2012.08.07

%% Get Parameters

option_name = get(hObject, 'Tag');
enabling = ~strcmp(option_name, 'guifig') && get(hObject, 'Value');
cause_op = ~isempty(strfind(option_name, 'cause_op_'));

%% Set all menus aside and set all buttons to off

% Set option buttons off
options = {'feat_dataset', 'feat_brain', 'feat_act', 'feat_plv',...
    'feat_rois', 'feat_cause', 'cause_op_general', 'cause_op_node',...
    'cause_op_frames', 'cause_op_focus', 'cause_op_pairings',...
    'feat_circle', 'feat_display', 'cause_op_threshold'};

for i = 1:length(options)
    set(handles.(options{i}), 'Value', 0);
end


% Move away all panels
panels = {'data_panel', 'brain_panel', 'act_panel',...
    'rois_panel', 'node_panel', 'cause_op_panel', 'cause_panel',...
    'frames_panel', 'focus_panel', 'wave_panel', 'display_panel',...
    'threshold_panel'};

for i = 1:length(panels)
    set(handles.(panels{i}), 'Units', 'Pixels');
    pos = get(handles.(panels{i}), 'Position');
    pos(1) = 13;
    pos(2) = 624;
    set(handles.(panels{i}), 'Position', pos);
end

%% Retrieve the ones wanted

if(enabling)
    switch option_name
        case 'feat_dataset'
            panel = 'data_panel';
        case 'feat_brain'
            panel = 'brain_panel';
        case 'feat_act'
            panel = 'act_panel';
        case 'feat_rois'
            panel = 'rois_panel';
        case 'feat_cause'
            panel = 'cause_op_panel';
        case 'cause_op_general'
            panel = 'cause_panel';
        case 'cause_op_frames'
            panel = 'frames_panel';
        case 'cause_op_focus'
            panel = 'focus_panel';
        case 'cause_op_node'
            panel = 'node_panel';
        case 'cause_op_pairings'
            panel = 'wave_panel';
        case 'feat_display'
            panel = 'display_panel';
        case 'cause_op_threshold'
            panel = 'threshold_panel';
        otherwise
            panel = '';
    end
    
    if(~isempty(panel) && ~cause_op)
        set(handles.(option_name), 'Value', 1);
        pos = get(handles.(panel), 'Position');
        pos(2) = 375 - pos(4);
        set(handles.(panel), 'Position', pos);
    elseif(~isempty(panel) && cause_op)
        set(handles.(option_name), 'Value', 1);
        pos = get(handles.(panel), 'Position');
        pos(2) = 300 - pos(4);
        set(handles.(panel), 'Position', pos);
    end
end

if cause_op
    set(handles.feat_cause, 'Value', 1);
    pos = get(handles.cause_op_panel, 'Position');
    pos(2) = 375 - pos(4);
    set(handles.cause_op_panel, 'Position', pos);
end

%% Update the GUI
guidata(hObject, handles);

end