function gpsp_draw_granger
% Draws the Granger causality on a surface
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
% 
% Changelog:
% 2013-08-12 Made GPS1.8/gpsp_draw_granger from GPS1.8/gpsp_draw_circle
% 2013-08-13 Ironing out the cortical options
% 2013-09-17 Added asterisk options

%% Prepare figure

% Get data
state = gpsp_get;
study = gpsp_parameter(state, state.study);
condition = gpsp_parameter(state, state.condition);
granger = gpsp_get('granger');
plotdata = gpsp_get('plotdata');
if(isempty(plotdata))
    return
end
N_ROIs = length(plotdata.connections);

% % Load the axes
fig = gpsp_fig_surf;
axes = gpsp_fig_surf_axes;
% hold(axes, 'off'); Not useful right now
hold(axes, 'on');
fig_cortex = get(state.surf_cort, 'Value');
fig_circle = get(state.surf_circle, 'Value');

%% Set size and background
bgcolor = gpsp_draw_colors(get(state.surf_bg, 'Value'));
set(fig, 'Color', bgcolor);
set(axes, 'Color', bgcolor);

font = get(state.tcs_font, 'String');
font = font{get(state.tcs_font, 'Value')};
set(axes, 'FontName', font);

% Set asterisks early
if(~get(state.arrows_asterisk, 'Value'))
    plotdata.asterisk = zeros(size(plotdata.asterisk));
end
if(~get(state.bubbles_asterisk, 'Value'))
    plotdata.asterisk_src = zeros(size(plotdata.asterisk_src));
    plotdata.asterisk_snk = zeros(size(plotdata.asterisk_snk));
end

%% Set coloring

switch get(state.arrows_color, 'Value')
    case 1 % Blue-Red Solid
        %  Old Green/Red Solid system
%         color_recip = 0;
%         color_direc = 2.5;
%         color_snk = 5;
%         color_src = 0;
%         
%         cmap_line = 0:0.005:1;
%         cmap_line = sqrt(cmap_line);
%         cmap = [flipud(cmap_line') cmap_line' zeros(length(cmap_line), 1)];
%         cmap2 = [zeros(length(cmap_line), 1) flipud(cmap_line') cmap_line'];
%         cmap = [cmap; cmap2];
%         colormap(axes, cmap);
%         
%         %  Negative colors
%         color_snk_neg = color_snk;
%         color_src_neg = color_src;
%         color_direc_neg = color_direc;
%         color_recip_neg = color_recip;
%         caxis(axes, [0 5]);
        
        color_recip = 0; color_direc = 0;
        color_snk = 0; color_src = 0;
        color_snk_neg = 15; color_src_neg = 15;
        color_direc_neg = 15; color_recip_neg = 15;
        cmap = [0 0 0.9; 0.9 0 0];
        colormap(axes, cmap);
        caxis(axes, [0 15]);
        
    case 2 % Green Blue Gradient
        color_snk = 0;
        color_src = 5;
        color_direc = [color_snk color_src];
        color_recip = color_direc;
        
        cmap_line = 0.1:0.005:.9;
        cmap_line = sqrt(cmap_line);
        cmap = [zeros(length(cmap_line), 1) cmap_line' flipud(cmap_line')];
        
        %  Negative colors
        color_snk_neg = 10;
        color_src_neg = 15;
        color_direc_neg = [color_snk_neg color_src_neg];
        color_recip_neg = color_direc_neg;
        
        cmap = [cmap; flipud(cmap); 1 - flipud(cmap)];
        colormap(axes, cmap);
        
        caxis(axes, [0 15]);
    case 3 % Green Blue arrow skip
        color_snk = 0;
        color_src = 5;
        color_direc = [color_snk color_src];
        color_recip = color_direc;
        
        cmap = [0 1 .5; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 0 .5 1];
        cmap = [0 .5 1; cmap; cmap; cmap; cmap; cmap; cmap; cmap; cmap; cmap; cmap; 0 1 .5];
        colormap(axes, cmap);
        
        %  Negative colors
        color_snk_neg = 10;
        color_src_neg = 15;
        color_direc_neg = [color_snk_neg color_src_neg];
        color_recip_neg = color_direc_neg;
        
        cmap = [cmap; flipud(cmap); rot90(cmap, 2)];
        colormap(axes, cmap);
end


%% Find ROI locations

x_nodes = zeros(N_ROIs, 1);
y_nodes = zeros(N_ROIs, 1);
z_nodes = zeros(N_ROIs, 1);

peripheral = (~get(state.surf_left, 'Value') & (granger.rois_hemi == 'L')) | ...
    (~get(state.surf_right, 'Value') & (granger.rois_hemi == 'R')) | ...
    (~get(state.surf_lat, 'Value') & (granger.rois_side == 'L')) | ...
    (~get(state.surf_med, 'Value') & (granger.rois_side == 'M'));

if(fig_circle)
    view(axes, 0, 90);
    
    angle = (2 * pi) / sum(~peripheral);
    
    % Build the coordinates for each node based on a polar graph
    for i_roi = 1:N_ROIs
        if(peripheral(i_roi))
            x_nodes(i_roi) = 1.2;
            y_nodes(i_roi) = -1.2;
        else
            i_node = sum(~peripheral(1:i_roi));
            x_nodes(i_roi) = cos(angle * (i_node - state.stg_loc) + pi/2);
            y_nodes(i_roi) = sin(angle * (i_node - state.stg_loc) + pi/2);
        end
    end
elseif(fig_cortex)
%     view(axes, 90, 0);
    brain = gpsp_get('brain');
    cort = gpsp_get('cort');
    
    if(~isfield(brain, condition.cortex.roiset))
        answer = questdlg('Must process the condition''s ROI annotation', 'Problem detected', 'OK', 'Cancel', 'Cancel');
        if(~strcmp(answer, 'OK')); return; end
        substate = state;
        substate.condition = condition.cortex.roiset;
%         labeldir = sprintf('%s/rois/%s', study.name, condition.cortex.roiset);
%         gps_labels2annot(state, labeldir);
        gps_labels2annot(substate);
        gpsa_mri_brain2mat(substate);
        subject.name = condition.cortex.brain;
        subject.mri.dir = sprintf('%s/%s', study.mri.dir, subject.name);
        brain = gps_brain_get(state, subject);
        gpsp_set(brain);
    end
    
    parcI = brain.(condition.cortex.roiset).I;
    parc_names = brain.(condition.cortex.roiset).text;
    
    parc_extant = unique(parcI);
    N_parc_regions = length(parc_extant);
    
    for i_region = 1:N_parc_regions
        region = parc_extant(i_region);
        region_name = parc_names{region};
        
        i_ROI = find(strcmp(granger.rois, region_name));
        if(~isempty(i_ROI))
            
            if(peripheral(i_ROI))
                x_nodes(i_ROI) = 80;
                y_nodes(i_ROI) = 0;
                z_nodes(i_ROI) = 0;
            else
                switch sprintf('%s%s', granger.rois_hemi(i_ROI), granger.rois_side(i_ROI))
                    case 'LL'
                        coord = mean(cort.ll_coords(parcI(1:brain.N_L) == region, :), 1);
                    case 'RL'
                        coord = mean(cort.rl_coords(parcI(brain.N_L + 1:end) == region, :), 1);
                    case 'LM'
                        coord = mean(cort.lm_coords(parcI(1:brain.N_L) == region, :), 1);
                    case 'RM'
                        coord = mean(cort.rm_coords(parcI(brain.N_L + 1:end) == region, :), 1);
                end
                
                x_nodes(i_ROI) = 80;%coord(1);
                y_nodes(i_ROI) = coord(2);
                z_nodes(i_ROI) = coord(3);
            end
        end % if the region is 
    end % for each region
end

%% Plot Bubbles

% If Showing Source/Sink strength or just dots
if(get(state.bubbles_source, 'Value') || get(state.bubbles_sink, 'Value'))
    nodescale = str2double(get(state.bubbles_scale, 'String'));
    if(get(state.bubbles_borders, 'Value'))
        border = '-';
    else
        border = 'none';
    end
    flag_overlay = get(state.bubbles_overlay, 'Value');
    
    val_src = plotdata.source_strength;
    val_snk = plotdata.sink_strength;
    
    if(~get(state.bubbles_source, 'Value')); val_src(:) = 0; end
    if(~get(state.bubbles_sink, 'Value')); val_snk(:) = 0; end
    if(get(state.bubbles_focus, 'Value'));
        select = get(state.regions_sel_list, 'Value');
        val_src(select) = 0;
        val_snk(select) = 0;
    end
    
    if(fig_circle)
        val_src = val_src * nodescale / 1000;
        val_snk = val_snk * nodescale / 1000;
    elseif(fig_cortex)
        val_src = val_src * nodescale / 10;
        val_snk = val_snk * nodescale / 10;
    end
    
    for i_ROI = 1:N_ROIs
        
        % Format Source circle
        if(flag_overlay == 3 || (flag_overlay == 2 && val_snk(i_ROI) ~= 0))
            [y1, z1, x1] = cylinder(abs(val_src(i_ROI)), 100);
            x1 = x1(:, 25:77); y1 = y1(:, 25:77); z1 = z1(:, 25:77);
        else
            [y1, z1, x1] = cylinder(abs(val_src(i_ROI)), 100);
        end
        if(val_src(i_ROI) > 0); c1 = color_src;
        else c1 = color_src_neg;
        end
        
        % Format Sink Circle
        if(flag_overlay == 3 || (flag_overlay == 2 && val_src(i_ROI) ~= 0))
            [y2, z2, x2] = cylinder(abs(val_snk(i_ROI)), 100);
            x2 = x2(:, [77:100 1:25]); y2 = y2(:, [77:100 1:25]); z2 = z2(:, [77:100 1:25]);
        else
            [y2, z2, x2] = cylinder(abs(val_snk(i_ROI)), 100);
        end
        if(val_snk(i_ROI) > 0); c2 = color_snk;
        else c2 = color_snk_neg;
        end
        
        % Figure out if the source should go first
        if(flag_overlay == 1 && abs(val_snk(i_ROI)) > abs(val_src(i_ROI)))
            x3 = x1; y3 = y1; z3 = z1; c3 = c1;
            x1 = x2; y1 = y2; z1 = z2; c1 = c2;
            x2 = x3; y2 = y3; z2 = z3; c2 = c3;
        end
        
        % Draw the circles
        if(fig_circle)
            h = fill(y1(1, :) + x_nodes(i_ROI),...
                z1(1, :) + y_nodes(i_ROI),...
                c1,...
                'FaceLighting', 'none',...
                'Parent', axes);
            set(h, 'LineStyle', border)
            h = fill(y2(1, :) + x_nodes(i_ROI),...
                z2(1, :) + y_nodes(i_ROI),...
                c2,...
                'FaceLighting', 'none',...
                'Parent', axes);
            set(h, 'LineStyle', border)
        elseif(fig_cortex)
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
        end
    end % for each ROI
elseif(fig_circle) % Normal dots
    % Plot each node
    for i_node = 1:N_ROIs
        h = plot(axes, x_nodes(i_node), y_nodes(i_node), '.');
        set(h, 'Color', repmat(get(state.surf_bg, 'Value')==4, 3, 1));
        set(h, 'MarkerSize', 8);
    end
end % If showing strength or doing normal dots

%% Plot Reciprocal Edges

if(get(state.arrows_borders, 'Value'))
    border = '-';
else
    border = 'none';
end

if(get(state.arrows_show, 'Value'))
    scale = str2double(get(state.arrows_scale, 'String'));
    
    % Find set of all ROIs pointing to each other
    reciprocal_granger = plotdata.connections .* plotdata.connections';
    [i_snks, i_srcs] = find(reciprocal_granger); % Sources and Sinks
    edges_recip = [i_snks i_srcs];

    for i_pair = 1:length(i_snks)
        i_src = i_srcs(i_pair);
        i_snk = i_snks(i_pair);
        
        % Coordinates
        x_src = x_nodes(i_src);
        y_src = y_nodes(i_src);
        x_snk = x_nodes(i_snk);
        y_snk = y_nodes(i_snk);
        z_src = z_nodes(i_src);
        z_snk = z_nodes(i_snk);
        
        x_mid = (x_src + x_snk) / 2;
        y_mid = (y_src + y_snk) / 2;
        z_mid = (z_src + z_snk) / 2;
        
        value = plotdata.connections(i_snk, i_src);
        value2 = plotdata.connections(i_src, i_snk);
        if(plotdata.asterisk(i_snk, i_src)); star1 = '*'; else star1 = ''; end
        if(plotdata.asterisk(i_src, i_snk)); star2 = '*'; else star2 = ''; end
        if(mod(value, 1) && mod(value2, 1))
            value_str = sprintf('%.2f%s&%.2f%s', value, star1, value2, star2);
        else
            value_str = sprintf('%d%s&%d%s', value, star1, value2, star2);
        end
        
        if(fig_circle)
            width = abs([value value2] .* scale / 1000);
            width_tri = width + 0.15;
        elseif(fig_cortex)
            width = abs([value value2] .* scale / 10);
            width_tri = width + 5;
        end
        
        switch double(value > 0) + double(value2 > 0) * 2
            case 0
                col = [color_recip_neg color_recip_neg];
            case 1
                col = [color_recip color_recip_neg];
            case 2
                col = [color_recip_neg color_recip];
            case 3
                col = [color_recip color_recip];
        end
        
        if(i_src < i_snk)
            gpsp_draw_arrow([x_src y_src z_src], [x_snk y_snk z_snk],...
                'Width', width,...
                'Triangle Width', width_tri,...
                'Color', col,...
                'Reciprocal', true,...
                'Border', border,...
                'Style', get(state.arrows_style, 'Value'),...
                'Surface', fig_cortex,... % Circle or Cortex
                'Parent', axes);

            if(get(state.arrows_weights, 'Value'))
                text(x_mid, y_mid, z_mid,...
                    value_str,...
                    'HorizontalAlignment', 'center',...
                    'Color', repmat(get(state.surf_bg, 'Value')==4, 3, 1),...
                    'FontWeight', 'bold',...
                    'FontSize', 14,...
                    'FontName', font,...
                    'Parent', axes);
            elseif(~isempty(star1) || ~isempty(star2))
                text(x_mid, y_mid, z_mid,...
                    [star1 '&' star2],...
                    'HorizontalAlignment', 'center',...
                    'Color', repmat(get(state.surf_bg, 'Value')==4, 3, 1),...
                    'FontWeight', 'bold',...
                    'FontSize', 14,...
                    'FontName', font,...
                    'Parent', axes);
            end
        end
    end % for each pair of activity

    %% Plot Directed Edges

    % Find set of vertices
    [i_snks, i_srcs] = find(plotdata.connections);
    edges_drctd = [i_snks i_srcs];
    edges_drctd = setdiff(edges_drctd, edges_recip, 'rows');
    i_snks = edges_drctd(:, 1);
    i_srcs = edges_drctd(:, 2);

    for i_pair = 1:length(i_snks)
        i_src = i_srcs(i_pair);
        i_snk = i_snks(i_pair);
        
        % Coordinates
        x_src = x_nodes(i_src);
        y_src = y_nodes(i_src);
        x_snk = x_nodes(i_snk);
        y_snk = y_nodes(i_snk);
        z_src = z_nodes(i_src);
        z_snk = z_nodes(i_snk);
        x_mid = (x_src + x_snk) / 2;
        y_mid = (y_src + y_snk) / 2;
        z_mid = (z_src + z_snk) / 2;

        value = plotdata.connections(i_snk, i_src);
        if(plotdata.asterisk(i_snk, i_src)); star = '*'; else star = ''; end
        if(mod(value, 1))
            value_str = sprintf('%.2f%s', value, star);
        else
            value_str = sprintf('%d%s', value, star);
        end
        
        if(fig_circle)
            width = abs(value .* scale / 1000);
            width_tri = width + 0.1;
        elseif(fig_cortex)
            width = abs(value .* scale / 10);
            width_tri = width + 5;
        end
        
        
        if(value > 0)
            col = color_direc;
        else
            col = color_direc_neg;
        end
        
        gpsp_draw_arrow([x_src y_src z_src], [x_snk y_snk z_snk],...
            'Width', width,...
            'Triangle Width', width_tri,...
            'Color', col,...
            'Reciprocal', false,...
            'Border', border,...
            'Style', get(state.arrows_style, 'Value'),...
            'Surface', fig_cortex,... % Circle or Cortex
            'Parent', axes);
        
        if(get(state.arrows_weights, 'Value'))
            text(x_mid, y_mid, z_mid,...
                value_str,...
                'HorizontalAlignment', 'center',...
                'Color', repmat(get(state.surf_bg, 'Value')==4, 3, 1),...
                'FontWeight', 'bold',...
                'FontSize', 14,...
                'FontName', font,...
                'Parent', axes);
        elseif(~isempty(star))
            text(x_mid, y_mid, z_mid,...
                star,...
                'HorizontalAlignment', 'center',...
                'Color', repmat(get(state.surf_bg, 'Value')==4, 3, 1),...
                'FontWeight', 'bold',...
                'FontSize', 14,...
                'FontName', font,...
                'Parent', axes);
        end
    end % For each pair
    
end % if showing arrows

%% Format Axis

set(axes, 'Box', 'off');
if(fig_circle)
    axis(axes, 'square');
    axis(axes, 'off');
    
    xlim(axes, [-1.4 1.4]);
    ylim(axes, [-1.4 1.4]);
elseif(fig_cortex)
    % Set Axis Limits
    axis(axes, 'equal','tight');
    xlim(axes, [-80 80]);
    ylim(axes, [min([cort.lm_coords(:, 2); cort.rm_coords(:, 2); cort.rl_coords(:, 2); cort.ll_coords(:, 2)]) - 10 ...
        max([cort.lm_coords(:, 2); cort.rm_coords(:, 2); cort.rl_coords(:, 2); cort.ll_coords(:, 2)]) + 10]);
    zlim(axes, [min([cort.lm_coords(:, 3); cort.rm_coords(:, 3); cort.rl_coords(:, 3); cort.ll_coords(:, 3)]) - 10 ...
        max([cort.lm_coords(:, 3); cort.rm_coords(:, 3); cort.rl_coords(:, 3); cort.ll_coords(:, 3)]) + 10]);
    axis(axes, 'off');
end

% Write Timestamp
if(get(state.time_timestamp, 'Value') || isfield(state, 'customstamp'))
    if(isfield(state, 'customstamp'))
        stamp = state.customstamp;
    else
        switch get(state.time_timestamp_style, 'Value')
            case 1 % Start and Stop
                stamp = sprintf('%03d to %d ms', plotdata.tstart, plotdata.tstop);
            case 2 % Start
                stamp = sprintf('%03d ms', plotdata.tstart);
            case 3 % Center
                stamp = sprintf('%03g ms', (plotdata.tstart + plotdata.tstop) / 2);
        end % which timestamp
    end % cumulative or not?
    
    if(fig_circle)
        h = text(-1.3, -1.2,...
            stamp,...
            'Color', repmat(get(state.surf_bg, 'Value')==4, 3, 1),...
            'Parent', axes);
    elseif(fig_cortex)
        position = [xlim(axes) ylim(axes) zlim(axes)];
        if(get(state.act_show, 'Value')); position(5) = position(5) + 40; end
        h = text(position(2), position(3)+10, position(5)+10,...
            stamp,...
            'HorizontalAlignment', 'left',...
            'VerticalAlignment', 'bottom',...
            'Color', repmat(get(state.surf_bg, 'Value')==4, 3, 1),...
            'Parent', axes);
    end
    set(h, 'FontSize', 14);
    set(h, 'FontName', font);
end

%% Label Nodes

% if(get(state.regions_labels_show, 'Value') || get(state.bubbles_weights, 'Value'))
    fontsize = str2double(get(state.regions_labels_size, 'String'));
%     fontcolors = [1 1 1; 0.712 0.712 0.712; .5 .5 .5; 0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 1 1; 0 0 1; 1 0 1];
%     fontcolor = get(state.regions_labels_color, 'Value');
%     fontcolor = fontcolors(fontcolor, :);
    fontcolor = gpsp_draw_colors(get(state.regions_labels_color, 'Value'));
    
    for i_ROI = 1:N_ROIs
        nodetext = {};
        if get(state.regions_labels_show, 'Value')
            nodetext{1} = plotdata.rois{i_ROI};
        end
        if(get(state.bubbles_source, 'Value'))
            
            value = plotdata.source_strength(i_ROI);
            if(get(state.bubbles_weights, 'Value'))
                if(mod(value, 1))
                    valuestr = sprintf('%.2f ->', value);
                else
                    valuestr = sprintf('%d ->', value);
                end
            else
                valuestr = '';
            end
            
            if(plotdata.asterisk_src(i_ROI)); star = '\ast'; else star = ''; end
            this_nodetext = [valuestr star];
            if(~isempty(this_nodetext))
                nodetext{length(nodetext) + 1} = this_nodetext; %#ok<*AGROW>
            end
        end
        if(get(state.bubbles_sink, 'Value'))

            value = plotdata.sink_strength(i_ROI);
            if(get(state.bubbles_weights, 'Value'))
                if(mod(value, 1))
                    valuestr = sprintf('%.2f ->', value);
                else
                    valuestr = sprintf('%d ->', value);
                end
            else
                valuestr = '';
            end
            
            if(plotdata.asterisk_snk(i_ROI)); star = '\ast'; else star = ''; end
            this_nodetext = [valuestr star];
            if(~isempty(this_nodetext))
                nodetext{length(nodetext) + 1} = this_nodetext;
            end
        end
        if(~isempty(nodetext))
            if(fig_circle)
                text(x_nodes(i_ROI) * 1.2,...
                    y_nodes(i_ROI) * 1.2,...
                    nodetext,...
                    'FontSize', fontsize,...
                    'Color', fontcolor,...
                    'VerticalAlignment', 'middle',...
                    'HorizontalAlignment', 'center',...
                    'FontName', font,...
                    'Parent', axes);
            elseif(fig_cortex)
                text(x_nodes(i_ROI) * 1.2,...
                    y_nodes(i_ROI),...
                    z_nodes(i_ROI),...
                    nodetext,...
                    'FontSize', fontsize,...
                    'FontWeight', 'bold',...
                    'Color', fontcolor,...
                    'VerticalAlignment', 'middle',...
                    'HorizontalAlignment', 'center',...
                    'FontName', font,...
                    'Parent', axes);
            end
        end
    end % For each ROI
% end % If we are displaying labels

end % function