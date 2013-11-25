function gpsp_draw_granger
% Draws the Granger causality on a surface
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
% 
% Changelog:
% 2013-08-12 Made GPS1.8/gpsp_draw_granger from GPS1.8/gpsp_draw_circle

%% Prepare figure

% Get data
state = gpsp_get;
plotdata = gpsp_get('plotdata');
if(isempty(plotdata))
    return
end
N_ROIs = length(plotdata.connections);

% Load the axes
fig = gpsp_fig_surf;
axes = gpsp_fig_surf_axes;
if(isempty(axes))
    pause(1);
    axes = gpsp_fig_surf_axes;
end
cla(axes);
if(isempty(axes))
    pause(1);
    axes = gpsp_fig_surf_axes;
end
view(axes, 0, 90);
legend(axes, 'off')
hold(axes, 'on');

%% Set size and background
set(fig, 'Color', gpsp_draw_colors(get(state.surf_bg, 'Value')));
set(axes, 'Color', gpsp_draw_colors(get(state.surf_bg, 'Value')));

font = get(state.tcs_font, 'String');
font = font{get(state.tcs_font, 'Value')};
set(axes, 'FontName', font);

%% Set coloring

switch get(state.arrows_color, 'Value')
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
        
    case 3 % Green Blue arrow skip
        color_snk = 0;
        color_src = 5;
        color_direc = [color_snk color_src];
        color_recip = color_direc;
        
        cmap = [0 1 .5; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 0 .5 1];
        cmap = [0 .5 1; cmap; cmap; cmap; cmap; cmap; cmap; cmap; cmap; cmap; cmap; 0 1 .5];
        colormap(axes, cmap);
end

caxis(axes, [0 15]);

angle = (2 * pi) / N_ROIs;

% Build the coordinates for each node based on a polar graph
x_nodes = zeros(N_ROIs, 1);
y_nodes = zeros(N_ROIs, 1);
z_nodes = zeros(N_ROIs, 1);
for i_node = 1:N_ROIs
    x_nodes(i_node) = cos(angle * (i_node - state.stg_loc) + pi/2);
    y_nodes(i_node) = sin(angle * (i_node - state.stg_loc) + pi/2);
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
    
    val_src = val_src * nodescale / 1000;
    val_snk = val_snk * nodescale / 1000;
    
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
        
%         % Draw the circles
%         h = fill3(x1(1, :) + x_nodes(i_ROI),...
%             y1(1, :) + y_nodes(i_ROI),...
%             z1(1, :) + z_nodes(i_ROI),...
%             c1,...
%             'FaceLighting', 'none',...
%             'Parent', axes);
%         set(h, 'LineStyle', border)
%         h = fill3(x2(1, :) + x_nodes(i_ROI),...
%             y2(1, :) + y_nodes(i_ROI),...
%             z2(1, :) + z_nodes(i_ROI),...
%             c2,...
%             'FaceLighting', 'none',...
%             'Parent', axes);
%         set(h, 'LineStyle', border)
    end % for each ROI
else % Normal dots
    % Plot each node
    for i_node = 1:N_ROIs
        h = plot(axes, x_nodes(i_node), y_nodes(i_node), '.');
        set(h, 'Color', repmat(get(state.surf_bg, 'Value')==4, 3, 1));
        set(h, 'MarkerSize', 8);
        hold(axes, 'on');
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
        
        value = plotdata.connections(i_snks(i_pair), i_srcs(i_pair));
        value2 = plotdata.connections(i_srcs(i_pair), i_snks(i_pair));
        if(mod(value, 1) && mod(value2, 1))
            value_str = sprintf('%.2f&%.2f', value, value2);
        else
            value_str = sprintf('%d&%d', value, value2);
        end
        
        width = abs([value value2] .* scale / 1000);
        width_tri = width + 0.15;
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
        
        if(i_srcs(i_pair) < i_snks(i_pair))
            gpsp_draw_arrow([x_src y_src z_src], [x_snk y_snk z_snk],...
                'Width', width,...
                'Triangle Width', width_tri,...
                'Color', col,...
                'Reciprocal', true,...
                'Border', border,...
                'Style', get(state.arrows_style, 'Value'),...
                'Surface', 0,... % Circle
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

        value = plotdata.connections(i_snks(i_pair), i_srcs(i_pair));
        if(mod(value, 1))
            value_str = sprintf('%.2f', value);
        else
            value_str = sprintf('%d', value);
        end
        
        width = abs(value .* scale / 1000);
        width_tri = width + 0.1;
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
            'Surface', 0,... % Circle
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
        end
    end % For each pair
    
end % if showing arrows

%% Format Axis

set(axes, 'Box', 'off');
axis(axes, 'square');
axis(axes, 'off');

xlim(axes, [-1.4 1.4]);
ylim(axes, [-1.4 1.4]);

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
    
    h = text(-1.3, -1.2,...
        stamp,...
        'Color', repmat(get(state.surf_bg, 'Value')==4, 3, 1),...
        'Parent', axes);
    set(h, 'FontSize', 14);
    set(h, 'FontName', font);
end

%% Label Nodes

if(get(state.regions_labels_show, 'Value') || get(state.bubbles_weights, 'Value'))
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
        if(get(state.bubbles_weights, 'Value') && get(state.bubbles_source, 'Value'))
            value = plotdata.source_strength(i_ROI);
            if(mod(value, 1))
                nodetext{length(nodetext) + 1} = sprintf('%.2f ->', value); %#ok<*AGROW>
            else
                nodetext{length(nodetext) + 1} = sprintf('%d ->', value);
            end
        end
        if(get(state.bubbles_weights, 'Value') && get(state.bubbles_sink, 'Value'))
            value = plotdata.sink_strength(i_ROI);
            if(mod(value, 1))
                nodetext{length(nodetext) + 1} = sprintf('-> %.2f', value);
            else
                nodetext{length(nodetext) + 1} = sprintf('-> %d', value);
            end
        end
        
        text(x_nodes(i_ROI) * 1.2,...
            y_nodes(i_ROI) * 1.2,...
            nodetext,...
            'FontSize', fontsize,...
            'Color', fontcolor,...
            'VerticalAlignment', 'middle',...
            'HorizontalAlignment', 'center',...
            'FontName', font,...
            'Parent', axes);
    end % For each ROI
end % If we are displaying labels

end % function