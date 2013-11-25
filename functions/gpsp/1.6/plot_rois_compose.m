function GPSP_vars = plot_rois_compose(GPSP_vars)
% Compose ROI maps
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream Plotting variables/handle
% Output: none, refreshes the GPSP_vars figure
%
% Date Created: 2012.07.09 from granger_plot_rois_compose
% Last Modified: 2012.07.10
% 2012.10.11 - Loosely adapted to GPS1.7

hObject = GPSP_vars.rois_compose;

%% Acquire Data
brain = gpsp_get('brain');
act = gpsp_get('act');
rois = gpsp_get('rois');
N_ROIs = length(rois);

data = zeros(brain.N, 1);
if(get(GPSP_vars.rois_aparc_color, 'Value'))
    data(act.decIndices) = 1;
else
    data(act.decIndices) = .05;
end
ROIfocus = get(GPSP_vars.focus_list, 'Value');

% Find ROI coordinates
for i_ROI = 1:N_ROIs
    
    if(~get(GPSP_vars.node_focusspec, 'Value') || sum(ROIfocus == i_ROI))
    
        roi_verts = rois(i_ROI).vertices;
        
        % Map onto brain
        if(get(GPSP_vars.rois_aparc_color, 'Value'))
            data(roi_verts) = rois(i_ROI).aparcI;
        else
            data(roi_verts) = 1;
        end
    end % if we are mapping this ROI
end % for each ROI

if(get(GPSP_vars.rois_aparc_color, 'Value'))
    data(data~=0, 1:3) = brain.aparcCmap(data(data~=0), :);
end
    
% Smooth
if(get(GPSP_vars.rois_smooth, 'Value'))

    % Smooth Foreground
%     data(1:brain.N_L, :) = inverse_smooth('',...
%         'value', data(1:brain.N_L, :),...
%         'step', 5,...
%         'face', brain.lface' - 1,...
%         'vertex', brain.pialcoords(1:brain.N_L, :)');
% 
%     % Right Side
%     data(brain.N_L + 1:end, :) = inverse_smooth('',...
%         'value', data(brain.N_L + 1:end, :),...
%         'step', 5,...
%         'face', brain.rface' - 1,...
%         'vertex', brain.pialcoords(brain.N_L + 1:end, :)');
    % Left Side
    data(1:brain.N_L) = rois_metrics_smooth(...
        data(1:brain.N_L),...
        brain.lface',...
        brain.pialcoords(1:brain.N_L, :)');

    % Right Side
    data(brain.N_L + 1:end) = rois_metrics_smooth(...
        data(brain.N_L + 1:end),...
        brain.rface',...
        brain.pialcoords(brain.N_L + 1:end, :)');

end % if smoothing

%% Get ROI activity for other plots (not integrated yet into GUI)

% data_raw = act.data_raw;
% for i_ROI = 1:length(ROIverts)
%     roi_verts = ROIverts{i_ROI}+1;
%     if(GPSP_vars.ROIhemi(i_ROI) == 0) % Align right hemisphere ROI
%         roi_verts = roi_verts + brain.N_L;
%     end
% 
%     % Map onto brain
%     data(roi_verts) = 1;
% end % for each ROI


%% Update the GUI

gpsp_set(data, 'rois_cortical');

% Draw the brain
plot_draw(GPSP_vars);

end % function