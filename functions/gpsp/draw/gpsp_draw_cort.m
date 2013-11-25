function gpsp_draw_cort
% Draws a cortical surface with a granger overlay
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
% 
% Changelog:
% 2013-07-17 Make GPS1.8/gpsp_draw_cort from GPS1.7/plot_draw
% 2013-07-21 options.surface
% 2013-08-06 Background color can be changed
% 2013-08-12 Font customization
% 2013-08-14 Activity overlay

%% Prepare figure

% Get data
state = gpsp_get;

% Load the axes
fig = gpsp_fig_surf;
axes = gpsp_fig_surf_axes;
if(isempty(axes))
    axes = gpsp_fig_surf_axes;
end

cla(axes);

%% Setup brain image and draw

brain = gpsp_get('brain');
options.fig = fig;
options.axes = axes;
options.curvature = num2str(get(state.surf_cort_sulci, 'Value') * 2);
options.shading = get(state.surf_cort_shadows, 'Value');
options.surface = num2str(get(state.surf_cort_surf, 'Value'));
options.background = gpsp_draw_colors(get(state.surf_bg, 'Value'));
options.font = get(state.tcs_font, 'String');
options.font = options.font{get(state.tcs_font, 'Value')};

% Sides
switch get(state.surf_left, 'Value') + 2 * get(state.surf_right, 'Value')
    case 1
        options.hemi = 'Left';
    case 2
        options.hemi = 'Right';
    case 3
        options.hemi = 'Both';
end
switch get(state.surf_lat, 'Value') + 2 * get(state.surf_med, 'Value')
    case 1
        options.view = 'Lateral';
    case 2
        options.view = 'Medial';
    case 3
        options.view = 'Both';
end

% Parcellation
i_parc = get(state.surf_atlas, 'Value');
if(i_parc > 1)
    options.parcellation = get(state.surf_atlas, 'String');
    options.parcellation = options.parcellation{i_parc};
    
    options.parcellation_text = get(state.surf_atlas_labels, 'Value');
    options.parcellation_overlay = get(state.surf_atlas_layer, 'String');
    options.parcellation_overlay = options.parcellation_overlay{get(state.surf_atlas_layer, 'Value')};
    options.parcellation_border = str2double(get(state.surf_atlas_border, 'String'));
end

% Activity
if(get(state.act_show, 'Value'))
    act = gpsp_get('act');
    
    brain.act.data = act.data;
    options.overlays.name = 'act';
    options.overlays.percentiled = 'v';
    options.overlays.decimated = 0;
    options.overlays.coloring = 'Hot';
    v1 = str2double(get(state.act_v1, 'String'));
    v2 = str2double(get(state.act_v2, 'String'));
    v3 = str2double(get(state.act_v3, 'String'));
    v4 = max(abs(act.data));
    brain.act.v = [v1 v2 v3 v4];
    
%     act2 = gpsp_get('act2');
%     if(isfield(act2, 'data_raw') && get(state.method_condition, 'Value') >= 3)
%         options.overlays.negative = 1;
%     end
end

%% Plot the cortex then the granger data
cort = gps_brain_draw(brain, options);
cort.name = 'cort';
gpsp_set(cort);
hold(axes, 'on');

gpsp_draw_granger;

%% Old function
return


if(flag_brain) % Brain
    brain = gpsp_get('brain');
    act = gpsp_get('act');
    
    % Which Brain Surface
    switch get(GPSP_vars.brain_surface, 'Value')
        case 1 % Inflated
            coords = brain.infcoords;
        case 2 % Pial
            coords = brain.pialcoords;
    end

    %% Background
    N_bg = 1;
    CData_BG = ones(brain.N, 3); % White

    % Sulci/Gyri
    if(get(GPSP_vars.brain_gyrisulci, 'Value'))
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
    
    % Anatomical Regions
    if(get(GPSP_vars.brain_aparc, 'Value'))
        aparcI = brain.aparcI;
        CData_aparc = brain.aparcCmap(aparcI,:);
        CData_BG = CData_BG + CData_aparc;
        N_bg = N_bg + 1;
    end
    
    CData_BG = CData_BG / N_bg;

    %% Foreground
    CData_FG = zeros(brain.N, 3); % black

    % Activation
    if(get(GPSP_vars.act_show, 'Value') && ~isempty(act))
        
        p1 = str2double(get(GPSP_vars.act_p1, 'String'));
        p2 = str2double(get(GPSP_vars.act_p2, 'String'));
        p3 = str2double(get(GPSP_vars.act_p3, 'String'));
        percentiles = [p1 p2 p3 100];
        thresh = prctile(act.data, percentiles);
        CData_FG = gps_brain_colordata(act.data, thresh);
        
    end % if showing activation

    % Synthesize
%     CData_FG = zeros(size(CData_BG));
    CData = (CData_FG + CData_BG)/2;
    
    
    % ROIs
    rois_cortical = gpsp_get('rois_cortical');
    if(~isempty(rois_cortical) && ((get(GPSP_vars.rois_cortical, 'Value') || get(GPSP_vars.node_focusspec, 'Value'))));
        data = rois_cortical;
        
        if(get(GPSP_vars.rois_aparc_color, 'Value'))
%             CData = CData + data;
            CData = data;
        else % Old Regime
            CData(data > 0.15, 1) = 0; % Red
            CData(data > 0.15, 2) = 0; % Green
            CData(data > 0.15, 3) = 0; % Blue

            if(~get(GPSP_vars.node_focusspec, 'Value'))
                CData(data > 0.6, 1) = 0; % Red
                CData(data > 0.6, 2) = 1; % Green
                CData(data > 0.6, 3) = .5; % Blue
            else
                if(get(GPSP_vars.node_sink, 'Value')) % Showing sinks
                    if(get(GPSP_vars.node_source, 'Value')) % Showing Both
                        CData(data > 0.6, 1) = .75; % Red
                        CData(data > 0.6, 2) = .75; % Green
                        CData(data > 0.6, 3) = 0; % Blue
                    else % Just showing sinks
                        CData(data > 0.6, 1) = 0; % Red
                        CData(data > 0.6, 2) = 1; % Green
                        CData(data > 0.6, 3) = .5; % Blue
                    end
                else % just showing sources
                    CData(data > 0.6, 1) = 0; % Red
                    CData(data > 0.6, 2) = .5; % Green
                    CData(data > 0.6, 3) = 1; % Blue
                end
            end
                        CData(data > 0.6, 1) = .8; % Red
                        CData(data > 0.6, 2) = .8; % Green
                        CData(data > 0.6, 3) = 0; % Blue
        end

        clear data;
    end % if showing ROIs
    
    CData = min(CData,1);
    CData = max(CData,0);
    
    %% Draw Brains

    % Find out which brains are showing
    showside(1) = get(GPSP_vars.brain_lh_lat, 'Value');
    showside(2) = get(GPSP_vars.brain_rh_lat, 'Value');
    showside(3) = get(GPSP_vars.brain_lh_med, 'Value');
    showside(4) = get(GPSP_vars.brain_rh_med, 'Value');
    
    % Draw the brains (up to 4)
    if(showside(1))
        ll_coords = coords(1:brain.N_L, :);
        ll_coords(:, 1) = -ll_coords(:, 1);
        switch get(GPSP_vars.brain_order, 'Value')
            case 1
                ll_coords(:, 2) = -ll_coords(:, 2) + min(ll_coords(:, 2)) - 5;
                ll_coords(:, 3) = ll_coords(:, 3) - max(ll_coords(:, 3)) - 5;
            case 2
                ll_coords(:, 2) = -ll_coords(:, 2) + min(ll_coords(:, 2)) - 5;
                ll_coords(:, 3) = ll_coords(:, 3) - min(ll_coords(:, 3)) + 5;
            case 3
                ll_coords(:, 2) = -ll_coords(:, 2) + min(ll_coords(:, 2)) - 5;
                ll_coords(:, 3) = ll_coords(:, 3) - min(ll_coords(:, 3)) + 5;
        end
        ll_CData = CData(1:brain.N_L, :);
        
        patch('Parent', axes,...
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
        ll_coords = [0 0 0];
    end
    if(showside(2))
        rl_coords = coords(brain.N_L + 1:end, :);
        switch get(GPSP_vars.brain_order, 'Value')
            case 1
                rl_coords(:, 2) = rl_coords(:, 2) - max(rl_coords(:, 2)) - 5;
                rl_coords(:, 3) = rl_coords(:, 3) - min(rl_coords(:, 3)) + 5;
            case 2
                rl_coords(:, 2) = rl_coords(:, 2) - min(rl_coords(:, 2)) + 5;
                rl_coords(:, 3) = rl_coords(:, 3) - min(rl_coords(:, 3)) + 5;
            case 3
                rl_coords(:, 2) = rl_coords(:, 2) - min(rl_coords(:, 2)) + 5;
                rl_coords(:, 3) = rl_coords(:, 3) - min(rl_coords(:, 3)) + 5;
        end
        rl_CData = CData(brain.N_L + 1:end, :);
        
        patch('Parent', axes,...
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
        rl_coords = [0 0 0];
    end
    if(showside(3))
        lm_coords = coords(1:brain.N_L, :);
        switch get(GPSP_vars.brain_order, 'Value')
            case 1
flag_brain = get(GPSP_vars.brain_show, 'Value');
                lm_coords(:, 2) = lm_coords(:, 2) - min(lm_coords(:, 2)) + 5;
                lm_coords(:, 3) = lm_coords(:, 3) - max(lm_coords(:, 3)) - 5;
            case 2
                lm_coords(:, 2) = lm_coords(:, 2) - max(lm_coords(:, 2)) - 5;
                lm_coords(:, 3) = lm_coords(:, 3) - max(lm_coords(:, 3)) - 5;
            case 3
                lm_coords(:, 2) = lm_coords(:, 2) - max(lm_coords(:, 2)) + min(ll_coords(:, 2)) - 10;
                lm_coords(:, 3) = lm_coords(:, 3) - min(lm_coords(:, 3)) + 5;
        end
        lm_CData = CData(1:brain.N_L, :);
        
        patch('Parent', axes,...
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
        lm_coords = [0 0 0];
    end
    if(showside(4))
        rm_coords = coords(brain.N_L + 1:end, :);
        rm_coords(:, 1) = -rm_coords(:, 1);
        switch get(GPSP_vars.brain_order, 'Value')
            case 1
                rm_coords(:, 2) = -rm_coords(:, 2) + max(rm_coords(:, 2)) + 5;
                rm_coords(:, 3) = rm_coords(:, 3) - min(rm_coords(:, 3)) + 5;
            case 2
                rm_coords(:, 2) = -rm_coords(:, 2) + max(rm_coords(:, 2)) + 5;
                rm_coords(:, 3) = rm_coords(:, 3) - max(rm_coords(:, 3)) - 5;
            case 3
                rm_coords(:, 2) = -rm_coords(:, 2) + max(rm_coords(:, 2)) + max(rl_coords(:, 2)) + 10;
                rm_coords(:, 3) = rm_coords(:, 3) - min(rm_coords(:, 3)) + 5;
        end
        rm_CData = CData(brain.N_L + 1:end, :);
        
        patch('Parent', axes,...
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
        rm_coords = [0 0 0];
    end
    
    %% Set some more parameters

    % Set View
    view(axes, 90, 0)

    % Set Lighting
    if(get(GPSP_vars.brain_shading, 'Value'))
        [az, el] = view(axes);
        [lightx lighty lightz] = sph2cart(az*pi/180, el*pi/180, 100);
        light('Parent', axes,...
            'Position', [lighty -lightx lightz],...
            'Style', 'infinite');
    end
    
    % Set Axis Limits
    axis(axes, 'equal','tight');
    xlim(axes, [-80 80]);
    ylim(axes, [min([lm_coords(:, 2); rm_coords(:, 2); rl_coords(:, 2); ll_coords(:, 2)]) - 10 ...
        max([lm_coords(:, 2); rm_coords(:, 2); rl_coords(:, 2); ll_coords(:, 2)]) + 10]);
    zlim(axes, [min([lm_coords(:, 3); rm_coords(:, 3); rl_coords(:, 3); ll_coords(:, 3)]) - 10 ...
        max([lm_coords(:, 3); rm_coords(:, 3); rl_coords(:, 3); ll_coords(:, 3)]) + 10]);
    axis(axes, 'off');
    
    %% Add Colorbar if we are using activation
    
    if(get(GPSP_vars.act_show, 'Value') && get(GPSP_vars.act_colorbar, 'Value') && ~isempty(act))
        ylimits = ylim(axes);
        zlimits = zlim(axes);
        
        % Get value breaks
        v0 = 0;%min(act.data);
        v1 = str2double(get(GPSP_vars.act_v1, 'String'));
        v2 = str2double(get(GPSP_vars.act_v2, 'String'));
        v3 = str2double(get(GPSP_vars.act_v3, 'String'));
        v4s = v3 + (v3 - v0) / 10; % supplemental v4
        v4 = max(act.data);
        v4sd = (v4s - v3) / (v4 - v3); % supplemental v4 differential
        
        vertices = [v0 v1 v2 v3 v4s];
        vertices = vertices / (v4s - v0) - v0;
        vertices = vertices * (ylimits(2) - ylimits(1) - 20) + ylimits(1) + 10;
        FV.vertices = [zeros(1, 10);
                    vertices, fliplr(vertices);
                    ones(1, 5) * zlimits(1), ones(1, 5) * zlimits(1) - 20]';
        FV.facevertexcdata = [0 0 0; 0 0 0; 1 0 0; 1 1 0; 1 1 v4sd;
                              1 1 v4sd; 1 1 0; 1 0 0; 0 0 0; 0 0 0]*0.7 + 0.3;
        FV.faces = [1 2 9 10; 2 3 8 9; 3 4 7 8; 4 5 6 7];
        
        % Label landmarks
        text(0, vertices(1), zlimits(1) - 30, '0.00e-11',...
            'HorizontalAlignment', 'left',...
            'Color', repmat(get(GPSP_vars.display_bg, 'Value') == 4, 1, 3),...
            'Parent', axes);
        text(0, vertices(2), zlimits(1) - 30, sprintf('%1.2e', v1),...
            'HorizontalAlignment', 'center',...
            'Color', repmat(get(GPSP_vars.display_bg, 'Value') == 4, 1, 3),...
            'Parent', axes);
        text(0, vertices(3), zlimits(1) - 30, sprintf('%1.2e', v2),...
            'HorizontalAlignment', 'center',...
            'Color', repmat(get(GPSP_vars.display_bg, 'Value') == 4, 1, 3),...
            'Parent', axes);
        text(0, vertices(4), zlimits(1) - 30, sprintf('%1.2e', v3),...
            'HorizontalAlignment', 'center',...
            'Color', repmat(get(GPSP_vars.display_bg, 'Value') == 4, 1, 3),...
            'Parent', axes);
        text(0, vertices(5), zlimits(1) - 30, '...',...
            'HorizontalAlignment', 'right',...
            'Color', repmat(get(GPSP_vars.display_bg, 'Value') == 4, 1, 3),...
            'Parent', axes);
                          
        patch(FV,...
            'FaceColor', 'interp',...
            'EdgeColor', repmat(get(GPSP_vars.display_bg, 'Value') == 4, 1, 3),...
            'Parent', axes,...
            'LineStyle', '-',...
            'FaceLighting', 'none');
        
        zlimits(1) = zlimits(1) - 40;
        zlim(axes, zlimits);
        clear act;
    end
end


%% Get Granger Data
granger = gpsp_get('granger');
rois = gpsp_get('rois');

% End early if empty
if(isempty(granger))
    guidata(hObject, GPSP_vars);
    return
end

tstart = GPSP_vars.frame(1);
tstop = GPSP_vars.frame(2);
stgloc = GPSP_vars.stgloc;
threshold = str2double(get(GPSP_vars.cause_threshold, 'String'));
scale = str2double(get(GPSP_vars.cause_scale, 'String'));

% granger_values = granger.results(:,:,tstart:tstop);


if(get(GPSP_vars.cause_signif, 'Value'))
    alpha_values = granger.alpha_values;
else
    threshold = str2double(get(GPSP_vars.cause_threshold, 'String'));
    alpha_values = ones(size(granger.results)) * threshold;
end

granger_values = granger.results - alpha_values;
granger_values(granger_values < 0) = 0;
granger_values = granger_values(:,:,tstart:tstop);
granger_values = mean(granger_values, 3);

% granger_values(granger_values < 0.02) = 0;
% granger_values = granger_values - 0.03;
% granger_values(granger_values < 0) = 0;

% granger_values = mean(granger_values, 3) - 0.005;
% granger_values(granger_values < 0) = 0;

% if(~get(GPSP_vars.cause_zegnero, 'Value'))
%     granger_values(granger_values < 0) = 0;
% end
% if(~get(GPSP_vars.cause_meanafterthresh, 'Value'))
%     granger_values = mean(granger_values, 3);
% %     mean_weights = gaussian((1:size(granger_values, 3)) - (size(granger_values, 3)/2), 0, size(granger_values, 3)/2)';
% %     mean_weightsM = permute(repmat(mean_weights, [1 size(granger_values, 1) size(granger_values, 2)]), [2 3 1]);
% %     granger_values = sum(granger_values .* mean_weightsM, 3) / sum(mean_weights);
% end
N_ROIs = size(granger_values, 1);
% 
% % Replace bad values with 0
% granger_values(isnan(granger_values)) = 0;
% granger_values(isinf(granger_values)) = 0;
% granger_values(granger_values < threshold) = 0;
% 
% if(get(GPSP_vars.cause_meanafterthresh, 'Value'))
%     granger_values = mean(granger_values, 3);
% %     mean_weights = gaussian((1:size(granger_values, 3)) - (size(granger_values, 3)/2), 0, size(granger_values, 3)/2)';
% %     mean_weightsM = permute(repmat(mean_weights, [1 size(granger_values, 1) size(granger_values, 2)]), [2 3 1]);
% %     granger_values = sum(granger_values .* mean_weightsM, 3) / sum(mean_weights);
% %     granger_values(granger_values < threshold) = 0;
% end

% Get cumulative granger_values

if(get(GPSP_vars.node_cum, 'Value'))
    granger_values_cum = zeros(size(granger_values));
    N_frames = length(GPSP_vars.frames);
    
    for i_frame = 1:N_frames
        frame = GPSP_vars.frames(i_frame,:);
        
        gvs = granger.results(:, :, frame(1):frame(2));

        if(~get(GPSP_vars.cause_zegnero, 'Value'))
            gvs(gvs < 0) = 0;
        end
        if(~get(GPSP_vars.cause_meanafterthresh, 'Value'))
            gvs = mean(gvs, 3);
        end

        % Replace bad values with 0
        gvs(isnan(gvs)) = 0;
        gvs(isinf(gvs)) = 0;
        gvs(gvs < threshold) = 0;

        if(get(GPSP_vars.cause_meanafterthresh, 'Value'))
            gvs = mean(gvs, 3);
        end
        
        granger_values_cum = granger_values_cum + gvs / N_frames;
    end % for each time frame
    
    % Right now overrides the granger values
    granger_values = granger_values_cum;
end % if we are doing the cumulative measure

size(GPSP_vars.foci)
size(granger_values)
% Highlight only focused areas
granger_values(~GPSP_vars.foci) = 0;
% hemidiff = double([rois.hemi] == 'L');
% hemidiff = hemidiff' * hemidiff;
% granger_values(find(~hemidiff)) = 0;

for i = 1:length(granger_values)
    for j = 1:length(granger_values)
        
        if granger_values(j,i) > 0
            fprintf('%s -> %s\n', rois(i).name, rois(j).name)
        end
    end
end

% granger_values_count = granger_values > 0;

%% Setup Coloring and Borders

switch get(GPSP_vars.cause_color, 'Value')
    case 1 % Green/Red Solid
        color_recip = 0;
        color_direc = 2.5;
        color_snk = 5;
        color_src = 0;
        
        cmap_line = 0:0.005:1;
        cmap_line = sqrt(cmap_line);
        cmap = [flipud(cmap_line') cmap_line' zeros(length(cmap_line), 1)];
        cmap2 = [zeros(length(cmap_line), 1) flipud(cmap_line') cmap_line'];
        cmap = [cmap; cmap2];
        colormap(axes, cmap);
    case 2 % Green Blue Gradient
        color_snk = 0;
        color_src = 5;
%         color_recip = (color_snk + color_src) / 2;
        color_direc = [color_snk color_src];
        color_recip = color_direc;
        
        cmap_line = 0.1:0.005:.9;
        cmap_line = sqrt(cmap_line);
        cmap = [zeros(length(cmap_line), 1) cmap_line' flipud(cmap_line')];
        colormap(axes, cmap);
    case 3 % Green Blue Gradient
        color_snk = 0;
        color_src = 5;
        color_direc = [color_snk color_src];
        color_recip = color_direc;
        
%         cmap_line = 0.1:0.05:.9;
%         cmap_line = sqrt(cmap_line);
%         cmap = [zeros(length(cmap_line), 1) cmap_lineG' flipud(cmap_line')];
        cmap = [0 1 .5; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 0 .5 1];
        cmap = [0 .5 1; cmap; cmap; cmap; cmap; cmap; cmap; cmap; cmap; cmap; cmap; 0 1 .5];
%         cmap = [cmap; cmap; cmap; cmap; cmap; cmap];
colormap(axes, cmap);
end

caxis(axes, [0 5]);

if(get(GPSP_vars.cause_borders, 'Value'))
    border = '-';
else
    border = 'none';
end

%% Plot Nodes and Source/Sink Strength

x_nodes = zeros(N_ROIs, 1);
y_nodes = zeros(N_ROIs, 1);
z_nodes = zeros(N_ROIs, 1);

%     x_peri = maxFront:(maxOccit - maxFront)/(N_peri + 1):maxOccit;

% For each ROI, determine if it is seeable or on the periphery
peripheral = zeros(N_ROIs, 1);

for i_ROI = 1:N_ROIs
    roi = rois(i_ROI);
    x_nodes(i_ROI) = 80;
    
    switch [roi.hemi roi.side]
        case 'LL'
            peripheral(i_ROI) = ~showside(1);
            
            if(~peripheral(i_ROI))
                y_nodes(i_ROI) = mean(ll_coords(roi.centroid, 2));
                z_nodes(i_ROI) = mean(ll_coords(roi.centroid, 3));
            end
        case 'RL'
            peripheral(i_ROI) = ~showside(2);
            
            if(~peripheral(i_ROI))
                y_nodes(i_ROI) = mean(rl_coords(roi.centroid - brain.N_L, 2));
                z_nodes(i_ROI) = mean(rl_coords(roi.centroid - brain.N_L, 3));
            end
        case 'LM'
            peripheral(i_ROI) = ~showside(3);
            
            if(~peripheral(i_ROI))
                y_nodes(i_ROI) = mean(lm_coords(roi.centroid, 2));
                z_nodes(i_ROI) = mean(lm_coords(roi.centroid, 3));
            end
        case 'RM'
            peripheral(i_ROI) = ~showside(4);
            
            if(~peripheral(i_ROI))
                y_nodes(i_ROI) = mean(rm_coords(roi.centroid - brain.N_L, 2));
                z_nodes(i_ROI) = mean(rm_coords(roi.centroid - brain.N_L, 3));
            end
    end
    
    if(peripheral(i_ROI))
        x_nodes(i_ROI) = 80;
        y_nodes(i_ROI) = 0;
        z_nodes(i_ROI) = 0;
    end
end

% If Showing Source/Sink strength or just dots
if(get(GPSP_vars.node_source, 'Value') || get(GPSP_vars.node_sink, 'Value'))
    %         % Compute Strength
    %         if(get(GPSP_vars.node_cum, 'Value'))
    %             val_src = sum(granger_values_cum) * scale;
    %             val_snk = sum(granger_values_cum, 2) * scale;
    %         else
    %             val_src = sum(granger_values) * scale;
    %             val_snk = sum(granger_values, 2) * scale;
    %         end
    
    nodescale = str2double(get(GPSP_vars.node_scale, 'String'));
    
    if(get(GPSP_vars.node_sum, 'Value')) % Summing
        val_src = sum(granger_values);
        val_snk = sum(granger_values, 2);
    else % Counting
        val_src = sum(granger_values > 0) * 0.2;
        val_snk = sum(granger_values > 0, 2) * 0.2;
    end % If Counting or summing
    
    % Omit focused ROI if focus special
    if(get(GPSP_vars.node_focusspec, 'Value'))
        ROIfocus = get(GPSP_vars.focus_list, 'Value');
        ROIfocusstr = get(GPSP_vars.focus_list, 'String');
        for i = ROIfocus; fprintf('%s Outgoing: %d, Incoming: %d\n', ROIfocusstr{i}, val_src(i), val_snk(i)); end
        val_src(ROIfocus) = 0;
        val_snk(ROIfocus) = 0;
    end
    
    if(~get(GPSP_vars.node_source, 'Value')); val_src(:) = 0; end
    if(~get(GPSP_vars.node_sink, 'Value')); val_snk(:) = 0; end
    
    % Relative
    if(get(GPSP_vars.node_rel, 'Value'))
        max_move = max([val_src val_snk']);
        val_src = val_src / max_move;
        val_snk = val_snk / max_move;
    end
    
    % Scale
    val_src = val_src * nodescale;
    val_snk = val_snk * nodescale;
    val_src = power(val_src, 0.5); % Scale so the area doesn't get massive
    val_snk = power(val_snk, 0.5);
    
    for i_ROI = 1:N_ROIs
        
        % No peripheral nodes
        if(~peripheral(i_ROI))
            alwayspartition = 0;
            %                 partition_factor = 1/2;
            
            if(alwayspartition || val_snk(i_ROI) > 0)
                [y1, z1, x1] = cylinder(val_src(i_ROI), 100);
                %                         [y1 z1 x1] = cylinder(val_src(i_ROI) / power(partition_factor, 0.5), 100);
                c1 = color_src;
                x1 = x1(:, 25:77); y1 = y1(:, 25:77); z1 = z1(:, 25:77);
            else
                [y1, z1, x1] = cylinder(val_src(i_ROI), 100);
                c1 = color_src;
            end
            
            %                 if(i_ROI ~= 4 && i_ROI ~= 7)
            %                 if(i_ROI ~= 1 && i_ROI ~= 2)
            %                     c1 = color_snk;
            %                  end
            
            if(alwayspartition || val_src(i_ROI) > 0)
                [y2, z2, x2] = cylinder(val_snk(i_ROI), 100);
                %                         [y2 z2 x2] = cylinder(val_snk(i_ROI) / power(1 - partition_factor, 0.5), 100);
                c2 = color_snk;
                x2 = x2(:, [77:100 1:25]); y2 = y2(:, [77:100 1:25]); z2 = z2(:, [77:100 1:25]);
            else
                [y2, z2, x2] = cylinder(val_snk(i_ROI), 100);
                c2 = color_snk;
            end
            
            % Draw the circles
            h = fill3(x1(1, :) + x_nodes(i_ROI),...
                y1(1, :) + y_nodes(i_ROI),...
                z1(1, :) + z_nodes(i_ROI),...
                c1,...
                'FaceLighting', 'none',...
                'Parent', axes);
            set(h, 'LineStyle', border)
            h = fill3(x2(1, :) + x_nodes(i_ROI),...
                y2(1, :) + y_nodes(i_ROI),...
                z2(1, :) + z_nodes(i_ROI),...
                c2,...
                'FaceLighting', 'none',...
                'Parent', axes);
            set(h, 'LineStyle', border)
        end % no peripheral nodes
    end % for each ROI
    
end % If showing strength

%% Plot Reciprocal Edges

if(get(GPSP_vars.cause_show, 'Value'))
    % Find set of all ROIs pointing to eachother
    reciprocal_granger = granger_values .* granger_values';
    [i_snks, i_srcs] = find(reciprocal_granger); % Sources and Sinks
    edges_recip = [i_snks i_srcs];

    for i_pair = 1:length(i_snks)
        
        % Coordinates
        x_src = x_nodes(i_srcs(i_pair));
        y_src = y_nodes(i_srcs(i_pair));
        x_snk = x_nodes(i_snks(i_pair));
        y_snk = y_nodes(i_snks(i_pair));
        z_src = z_nodes(i_srcs(i_pair));
        z_snk = z_nodes(i_snks(i_pair));
        
        x_mid = (x_src + x_snk) / 2;
        y_mid = (y_src + y_snk) / 2;
        z_mid = (z_src + z_snk) / 2;
        
        value = granger_values(i_snks(i_pair), i_srcs(i_pair)) .* scale;
        value2 = granger_values(i_srcs(i_pair), i_snks(i_pair)) .* scale;
        
        if(~flag_brain)
            width = [value value2] / 100;
            width_tri = width + 0.15;
        else
            width = [value value2];
            width_tri = width + 5;
        end

        if(i_srcs(i_pair) < i_snks(i_pair))
            plot_arrow([x_src y_src z_src], [x_snk y_snk z_snk],...
                'Width', width,...
                'Triangle Width', width_tri,...
                'Color', color_recip,...
                'Reciprocal', true,...
                'Border', border,...
                'Style', get(GPSP_vars.cause_style, 'Value'),...
                'Surface', 1,...
                'Parent', axes);

            if(get(GPSP_vars.cause_weights, 'Value'))
                text(x_mid, y_mid, z_mid,...
                    sprintf('%.2f&%.2f', value, value2),...
                    'HorizontalAlignment', 'center',...
                    'Color', repmat(get(GPSP_vars.display_bg, 'Value')==4, 3, 1),...
                    'FontWeight', 'bold',...
                    'FontSize', 14,...
                    'Parent', axes);
            end
        end
    end % for each pair of activity

    %% Plot Directed Edges

    % Find set of vertices
    [i_snks, i_srcs] = find(granger_values);
    edges_drctd = [i_snks i_srcs];
    edges_drctd = setdiff(edges_drctd, edges_recip, 'rows');
    i_snks = edges_drctd(:, 1);
    i_srcs = edges_drctd(:, 2);

    for i_pair = 1:length(i_snks)
        % Coordinates
        x_src = x_nodes(i_srcs(i_pair));
        y_src = y_nodes(i_srcs(i_pair));
        x_snk = x_nodes(i_snks(i_pair));
        y_snk = y_nodes(i_snks(i_pair));
        z_src = z_nodes(i_srcs(i_pair));
        z_snk = z_nodes(i_snks(i_pair));
        x_mid = (x_src + x_snk) / 2;
        y_mid = (y_src + y_snk) / 2;
        z_mid = (z_src + z_snk) / 2;

        value = granger_values(i_snks(i_pair), i_srcs(i_pair)) .* scale;
        if(~flag_brain)
            width = value / 100;
            width_tri = width + 0.1;
        else
            width = value;
            width_tri = width + 5;
        end

        plot_arrow([x_src y_src z_src], [x_snk y_snk z_snk],...
            'Width', width,...
            'Triangle Width', width_tri,...
            'Color', color_direc,...
            'Reciprocal', false,...
            'Border', border,...
            'Style', get(GPSP_vars.cause_style, 'Value'),...
            'Surface', 1,...
            'Parent', axes);

        if(get(GPSP_vars.cause_weights, 'Value'))
            text(x_mid, y_mid, z_mid,...
                sprintf('%.2f', value),...
                'HorizontalAlignment', 'center',...
                'Color', repmat(get(GPSP_vars.display_bg, 'Value')==4, 3, 1),...
                'FontWeight', 'bold',...
                'FontSize', 14,...
                'Parent', axes);
        end
    end % For each pair

end % if showing arrows

%% Format Axis

% Write Timestamp
if(get(GPSP_vars.frames_timestamp, 'Value') || isfield(GPSP_vars, 'customstamp'))
    if(get(GPSP_vars.node_cum, 'Value'))
        stamp = 'Cumulative';
    elseif(isfield(GPSP_vars, 'customstamp'))
        stamp = GPSP_vars.customstamp;
    else
        switch get(GPSP_vars.frames_timestamp_style, 'Value')
            case 1 % Start and Stop
                stamp = sprintf('%03d to %d ms', tstart, tstop);
            case 2 % Start
                stamp = sprintf('%03d ms', tstart);
            case 3 % Center
                stamp = sprintf('%03g ms', (tstart + tstop) / 2);
        end % which timestamp
    end % cumulative or not?
    
    position = [xlim(axes) ylim(axes) zlim(axes)];
    if(get(GPSP_vars.act_show, 'Value')); position(5) = position(5) + 40; end
    h = text(position(2), position(3)+10, position(5)+10,...
        stamp,...
        'HorizontalAlignment', 'left',...
        'VerticalAlignment', 'bottom',...
        'Color', repmat(get(GPSP_vars.display_bg, 'Value')==4, 3, 1),...
        'Parent', axes);
    set(h, 'FontSize', 14);
end
    
%% Label Nodes

if(get(GPSP_vars.rois_labels, 'Value'))
    labels = {rois.name};
    fontsize = str2double(get(GPSP_vars.rois_labels_size, 'String'));
    fontcolors = [1 1 1; 0.712 0.712 0.712; .5 .5 .5; 0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 1 1; 0 0 1; 1 0 1];
    fontcolor = get(GPSP_vars.rois_labels_color, 'Value');
    fontcolor = fontcolors(fontcolor, :);
    
%     for i_ROI = get(GPSP_vars.focus_list, 'Value')%1:N_ROIs
    for i_ROI = 1:N_ROIs
        if(isempty(labels))
            nodename = num2str(i_ROI);
        else
            nodename = labels{i_ROI};
        end
        
        %             if(sum(granger_values(i_ROI, :)) > 0 || sum(granger_values(:, i_ROI)) > 0)
        text(x_nodes(i_ROI)* 1.2,...
            y_nodes(i_ROI),...
            z_nodes(i_ROI),...
            nodename,...
            'FontSize', fontsize,...
            'Color', fontcolor,...
            'VerticalAlignment', 'middle',...
            'HorizontalAlignment', 'center',...
            'FontWeight', 'bold',...
            'Parent', axes);
        
        %                 set(h, 'Color', repmat(get(GPSP_vars.display_bg, 'Value')==4, 3, 1));
        %         end % If there is causation with this ROI
    end % For each ROI
end % If we are displaying labels

%% Save Snapshot

% frame = getframe(axes);
% 
% if(~exist(GPSP_vars.imagefolder, 'dir'))
%     mkdir(GPSP_vars.imagefolder);
% end
% imfile = sprintf('%s/%s_%s_grangers_%dto%d.png',...
%     GPSP_vars.imagefolder, GPSP_vars.study, GPSP_vars.condition,...
%     tstart, tstop);
% imwrite(frame.cdata, imfile, 'png');

%% Update the GUI
guidata(hObject, GPSP_vars);

%% Plot Wave?

plot_wave(GPSP_vars);

end