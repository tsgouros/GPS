function GPSR_vars = rois_draw(GPSR_vars)
% Draws the brain for the GPS ROI program
%
% Author: Conrad Nied
%
% Date Created: 2012.06.14
% Last Modified: 2012.08.09
% 2013.07.02 - Checks that processes are selected and enabled

if(get(GPSR_vars.quick_pauseautoredraw, 'Value'))
    % Don't draw brain
    return
end

cla(GPSR_vars.axes_brain);
set(GPSR_vars.guifig, 'Renderer', 'OpenGL');
rotate3d(GPSR_vars.axes_brain, 'off');

brain = getappdata(GPSR_vars.datafig, 'brain');
    
% Which Brain Surface
switch get(GPSR_vars.brain_surface, 'Value')
    case 1 % Inflated
        coords = brain.infcoords;
    case 2 % Pial
        coords = brain.pialcoords;
    case 3 % White Matter
        coords = brain.origcoords;
end

%% Background
N_bg = 1;
CData_BG = ones(brain.N, 3); % White

% Sulci/Gyri
if(get(GPSR_vars.brain_gyrisulci, 'Value'))
    curv = brain.curv;
    CData_curv = zeros(brain.N,1);
    CData_curv(curv>0) = 0; % Gyri
    CData_curv(curv<=0) = 1; % Sulci

    CData_BG = CData_BG + [CData_curv CData_curv CData_curv]; % 3 grey color values

    N_bg = N_bg + 1;
else
    CData_BG = CData_BG * 1.8;

    N_bg = N_bg + 1;
end

% Freesurfer Automatically Parcellated Regions
if(get(GPSR_vars.brain_fsregions, 'Value'))
    aparcI = brain.aparcI;
    CData_aparc = brain.aparcCmap(aparcI,:);
    CData_BG = CData_BG + CData_aparc;
    N_bg = N_bg + 1;
end

CData_BG = CData_BG / N_bg;

%% Foreground
CData_FG = zeros(brain.N, 3); % black
N_FG = 0;

% Activation Maps
for types = {'mne', 'plv', 'custom', 'maxact', 'sim'};
    type = types{1};
    button = sprintf('quick_%s', type);
    selected = get(GPSR_vars.(button), 'Value');
    enabled = strcmp(get(GPSR_vars.(button), 'Enable'), 'on');
    if(selected && enabled)
        metric = getappdata(GPSR_vars.datafig, type);
        data = rois_draw_coloring(metric.data.cort, metric.data.v, metric.vis.color);
        CData_FG = CData_FG + data;
        N_FG = N_FG + 1;
    end % If we are drawing this metric
end % For all metrics

% % Similarity (and ROI display)
% type = 'sim';
% button = sprintf('quick_%s', type);
% if(get(GPSR_vars.(button), 'Value'))
%     metric = getappdata(GPSR_vars.datafig, type);
%     points = getappdata(GPSR_vars.datafig, 'points');
%     if(metric.sim.point <= length(points))
%         point = points(metric.sim.point);
%         if(point.ROI)
%             values = metric.data.v;
%             values(2) = point.thresh.redun;
%             values(3) = point.thresh.sim;
%             metric.data.cort(point.vertices) = values(4);
%         else
%             values = metric.data.v;
%         end
%         data = rois_draw_coloring(metric.data.cort, values, metric.vis.color);
%         CData_FG = CData_FG + data;
%         N_FG = N_FG + 1;
%     end % if we have points
% end % If we are drawing this metric

if(N_FG > 0)
%     CData_FG = CData_FG / N_FG;
    CData_FG = min(CData_FG,1);
    CData_FG = max(CData_FG,0);
end

% Synthesize
CData = (CData_FG + CData_BG) / 2;

% ROIs
if(get(GPSR_vars.regions_show, 'Value'));
    points = getappdata(GPSR_vars.datafig, 'points');
    highlights = get(GPSR_vars.regions_list, 'Value');
    
    for i_point = 1:length(points)
        point = points(i_point);
        if(point.ROI && isfield(point, 'vertices'))
            if(sum(highlights == i_point))
                CData(point.vertices, :) = repmat([0 1 .75], length(point.vertices), 1);
            else
                CData(point.vertices, :) = repmat([0 1 .5], length(point.vertices), 1);
            end % If the point is highlit
        end % If the point is an ROI
    end % For all points
end % if showing ROIs

CData = min(CData,1);
CData = max(CData,0);

%% Draw Brains

% Find out which brains are showing
showside(1) = get(GPSR_vars.brain_left, 'Value');
showside(2) = get(GPSR_vars.brain_right, 'Value');
if(get(GPSR_vars.brain_perspective, 'Value') == 7)
    showside(3) = get(GPSR_vars.brain_left, 'Value');
    showside(4) = get(GPSR_vars.brain_right, 'Value');
else
    showside(3) = 0;
    showside(4) = 0;
end

% Draw the brains (up to 4)
if(showside(1))
    ll_coords = coords(1:brain.N_L, :);
    
    switch get(GPSR_vars.brain_perspective, 'Value')
        case {1, 7} % Lateral || Lat & Med
            ll_coords(:, 1) = -ll_coords(:, 1);
            ll_coords(:, 2) = -ll_coords(:, 2) + min(ll_coords(:, 2)) - 5;
            ll_coords(:, 3) = ll_coords(:, 3) - min(ll_coords(:, 3)) + 5;
        case 2 % Medial
%             ll_coords(:, 1) = ll_coords(:, 1);
            ll_coords(:, 2) = -ll_coords(:, 2) + min(ll_coords(:, 2)) - 5;
            ll_coords(:, 3) = ll_coords(:, 3) - min(ll_coords(:, 3)) + 5;
        case {3, 4, 5, 6, 8} % Frontal, Occipital, Dorsal, Ventral, Free Rotate
            if(get(GPSR_vars.brain_surface, 'Value') == 1) % Inflated
                ll_coords(:, 1) = ll_coords(:, 1) - max(ll_coords(:, 1)) - 5;
%             ll_coords(:, 2) = -ll_coords(:, 2) + min(ll_coords(:, 2)) - 5;
%             ll_coords(:, 3) = ll_coords(:, 3) - min(ll_coords(:, 3)) + 5;
            end
    end
    ll_CData = CData(1:brain.N_L, :);

    patch('Parent', GPSR_vars.axes_brain,...
        'Faces', brain.lface,...
        'Vertices', ll_coords,...
        'FaceVertexCData', ll_CData,...
        'MarkerEdgeColor', 'none',...
        'EdgeColor', 'none',...
        'FaceColor', 'interp',...
        'FaceLighting', 'flat',...
        'SpecularStrength', 0.0, 'AmbientStrength', 0.4,...
        'DiffuseStrength', 0.8, 'SpecularExponent', 10.0);
else
    ll_coords = zeros(brain.N_R, 3);
end
if(showside(2))
    rl_coords = coords(brain.N_L + 1:end, :);
    switch get(GPSR_vars.brain_perspective, 'Value')
        case {1, 7} % Lateral || Lat & Med
%             rl_coords(:, 1) = rl_coords(:, 1);
            rl_coords(:, 2) = rl_coords(:, 2) - min(rl_coords(:, 2)) + 5;
            rl_coords(:, 3) = rl_coords(:, 3) - min(rl_coords(:, 3)) + 5;
        case 2 % Medial
            rl_coords(:, 1) = -rl_coords(:, 1);
            rl_coords(:, 2) = rl_coords(:, 2) - min(rl_coords(:, 2)) + 5;
            rl_coords(:, 3) = rl_coords(:, 3) - min(rl_coords(:, 3)) + 5;
        case {3, 4, 5, 6, 8} % Frontal, Occipital, Dorsal, Ventral, Free Rotate
            if(get(GPSR_vars.brain_surface, 'Value') == 1) % Inflated
                rl_coords(:, 1) = rl_coords(:, 1) - min(rl_coords(:, 1)) + 5;
            end
%             rl_coords(:, 2) = rl_coords(:, 2) - min(rl_coords(:, 2)) + 5;
%             rl_coords(:, 3) = rl_coords(:, 3) - min(rl_coords(:, 3)) + 5;
    end
    rl_CData = CData(brain.N_L + 1:end, :);

    patch('Parent', GPSR_vars.axes_brain,...
        'Faces', brain.rface,...
        'Vertices', rl_coords,...
        'FaceVertexCData', rl_CData,...
        'MarkerEdgeColor', 'none',...
        'EdgeColor', 'none',...
        'FaceColor', 'interp',...
        'FaceLighting', 'flat',...
        'SpecularStrength', 0.0, 'AmbientStrength', 0.4,...
        'DiffuseStrength', 0.8, 'SpecularExponent', 10.0);
else
    rl_coords = zeros(brain.N_R, 3);
end
if(showside(3))
    lm_coords = coords(1:brain.N_L, :);
    lm_coords(:, 2) = lm_coords(:, 2) - max(lm_coords(:, 2)) - 5;
    lm_coords(:, 3) = lm_coords(:, 3) - max(lm_coords(:, 3)) - 5;
    lm_CData = CData(1:brain.N_L, :);

    patch('Parent', GPSR_vars.axes_brain,...
        'Faces', brain.lface,...
        'Vertices', lm_coords,...
        'FaceVertexCData', lm_CData,...
        'MarkerEdgeColor', 'none',...
        'EdgeColor', 'none',...
        'FaceColor', 'interp',...
        'FaceLighting', 'flat',...
        'SpecularStrength', 0.0, 'AmbientStrength', 0.4,...
        'DiffuseStrength', 0.8, 'SpecularExponent', 10.0);
else
    lm_coords = zeros(brain.N_L, 3);
end
if(showside(4))
    rm_coords = coords(brain.N_L + 1:end, :);
    rm_coords(:, 1) = -rm_coords(:, 1);
    rm_coords(:, 2) = -rm_coords(:, 2) + max(rm_coords(:, 2)) + 5;
    rm_coords(:, 3) = rm_coords(:, 3) - max(rm_coords(:, 3)) - 5;
    rm_CData = CData(brain.N_L + 1:end, :);

    patch('Parent', GPSR_vars.axes_brain,...
        'Faces', brain.rface,...
        'Vertices', rm_coords,...
        'FaceVertexCData', rm_CData,...
        'MarkerEdgeColor', 'none',...
        'EdgeColor', 'none',...
        'FaceColor', 'interp',...
        'FaceLighting', 'flat',...
        'SpecularStrength', 0.0, 'AmbientStrength', 0.4,...
        'DiffuseStrength', 0.8, 'SpecularExponent', 10.0);
else
    rm_coords = zeros(brain.N_R, 3);
end

%% Set some more parameters

% Centroids
if(get(GPSR_vars.quick_centroids, 'Value'))
    points = getappdata(GPSR_vars.datafig, 'points');
    highlights = get(GPSR_vars.regions_list, 'Value');
    N_points = length(points);

    for i_point = 1:N_points
        point = points(i_point);
        
        % Is it being highlighted?
        if(sum(i_point == highlights))
            color = 'g';
            psize = 20;
        else
            color = 'c';
            psize = 10;
        end
        
        % Which surface is it being drawn on?
        if(strcmp(point.side, 'L')) % Lateral point
            if(strcmp(point.hemi, 'L')) % Left Hemisphere
                coord = ll_coords(point.index, :);
            else % Right Hemisphere
                coord = rl_coords(point.index - brain.N_L, :);
            end
        else % Medial point
            if(get(GPSR_vars.brain_perspective, 'Value') == 7) % If 4 brains
                if(strcmp(point.hemi, 'L')) % Left Hemisphere
                    coord = lm_coords(point.index, :);
                else % Right Hemisphere
                    coord = rm_coords(point.index - brain.N_L, :);
                end
            else
                if(strcmp(point.hemi, 'L')) % Left Hemisphere
                    coord = ll_coords(point.index, :);
                else % Right Hemisphere
                    coord = rl_coords(point.index - brain.N_L, :);
                end
            end
        end
        
        % Draw the points
        hold(GPSR_vars.axes_brain, 'on');
        plot3(GPSR_vars.axes_brain,...
            coord(1), coord(2), coord(3),...
            [color '+'],...
            'MarkerSize', psize)
        plot3(GPSR_vars.axes_brain,...
            coord(1), coord(2), coord(3),...
            [color 'o'],...
            'MarkerSize', psize)
        
        if(get(GPSR_vars.centroids_show_text, 'Value'))
            if(sum(highlights == i_point))
                text(coord(1)*1.2, coord(2), coord(3),...
                    sprintf('%s_{%d}', point.aparc, point.numInRegion),...
                    'Parent', GPSR_vars.axes_brain,...
                    'HorizontalAlignment', 'center',...
                    'VerticalAlignment', 'middle',...
                    'FontWeight', 'bold',...
                    'FontSize', 12);
            else
                text(coord(1)*1.2, coord(2), coord(3),...
                    sprintf('%s_{%d}', point.aparc, point.numInRegion),...
                    'Parent', GPSR_vars.axes_brain,...
                    'HorizontalAlignment', 'center',...
                    'VerticalAlignment', 'middle',...
                    'FontWeight', 'bold');
            end % If the point is highlit
        end % If showing text
    end % for each point
end % If showing centroids

% ROI Names
if(get(GPSR_vars.regions_show, 'Value') && get(GPSR_vars.regions_show_text, 'Value'));
    points = getappdata(GPSR_vars.datafig, 'points');
    highlights = get(GPSR_vars.regions_list, 'Value');
    
    for i_point = 1:length(points)
        point = points(i_point);
        
        if(point.ROI && isfield(point, 'vertices'))
            
            x_factor = 1.2;
            % Which surface is it being drawn on?
            if(strcmp(point.side, 'L')) % Lateral point
                if(strcmp(point.hemi, 'L')) % Left Hemisphere
                    coord = ll_coords(point.index, :);
                else % Right Hemisphere
                    coord = rl_coords(point.index - brain.N_L, :);
                end
            else % Medial point
                if(get(GPSR_vars.brain_perspective, 'Value') == 7) % If 4 brains
                    x_factor = 3;
                    if(strcmp(point.hemi, 'L')) % Left Hemisphere
                        coord = lm_coords(point.index, :);
                    else % Right Hemisphere
                        coord = rm_coords(point.index - brain.N_L, :);
                    end
                else
                    x_factor = 0.8;
                    if(strcmp(point.hemi, 'L')) % Left Hemisphere
                        coord = ll_coords(point.index, :);
                    else % Right Hemisphere
                        coord = rl_coords(point.index - brain.N_L, :);
                    end
                end
            end
            
            if(sum(highlights == i_point))
                text(coord(1) * x_factor, coord(2), coord(3),...
                    sprintf('%s_{%d}', point.aparc, point.numInRegion),...
                    'Parent', GPSR_vars.axes_brain,...
                    'HorizontalAlignment', 'center',...
                    'VerticalAlignment', 'middle',...
                    'FontWeight', 'bold',...
                    'FontSize', 12);
            else
                text(coord(1) * x_factor, coord(2), coord(3),...
                    sprintf('%s_{%d}', point.aparc, point.numInRegion),...
                    'Parent', GPSR_vars.axes_brain,...
                    'HorizontalAlignment', 'center',...
                    'VerticalAlignment', 'middle',...
                    'FontWeight', 'bold');
            end % If the point is highlit
        end % If the point is an ROI
    end % For all points
end % if showing ROIs

% Set View
if(isfield(GPSR_vars, 'angle'))
    angle = GPSR_vars.angle;
else
    angle = 0;
end

switch get(GPSR_vars.brain_perspective, 'Value')
    case {1, 2, 7} % Lateral, Medial, Lat & Med
        view(GPSR_vars.axes_brain, 90 + angle, 0)
    case 3 % Frontal
        view(GPSR_vars.axes_brain, 180 + angle, 0)
    case 4 % Occipital
        view(GPSR_vars.axes_brain, 0 + angle, 0)
    case 5 % Dorsal
        view(GPSR_vars.axes_brain, 0 + angle, 90)
    case 6 % Ventral
        view(GPSR_vars.axes_brain, 180 + angle, -90)
    case 8 % Free Rotate
%         view(GPSR_vars.axes, 180, 0)
        rotate3d(GPSR_vars.axes_brain, 'on');
        set(GPSR_vars.brain_shadows, 'Value', 0)
end

% Set Lighting
if(get(GPSR_vars.brain_shadows, 'Value'))
    [az, el] = view(GPSR_vars.axes_brain);
    [lightx, lighty, lightz] = sph2cart(az*pi/180, el*pi/180, 100);
    light('Parent', GPSR_vars.axes_brain,...
        'Position', [lighty -lightx lightz],...
        'Style', 'infinite');
end

% Set Axis Limits
axis(GPSR_vars.axes_brain, 'equal','tight');
ylim(GPSR_vars.axes_brain, [min([lm_coords(:, 2); rm_coords(:, 2); rl_coords(:, 2); ll_coords(:, 2)]) - 10 ...
    max([lm_coords(:, 2); rm_coords(:, 2); rl_coords(:, 2); ll_coords(:, 2)]) + 10]);
zlim(GPSR_vars.axes_brain, [min([lm_coords(:, 3); rm_coords(:, 3); rl_coords(:, 3); ll_coords(:, 3)]) - 10 ...
    max([lm_coords(:, 3); rm_coords(:, 3); rl_coords(:, 3); ll_coords(:, 3)]) + 10]);
axis(GPSR_vars.axes_brain, 'off');

%% Update the GUI
guidata(GPSR_vars.data_subject_list, GPSR_vars);

end % function
