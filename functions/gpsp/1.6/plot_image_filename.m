function filename = plot_image_filename(GPSP_vars, varargin)
% Determines the filename for an image given the current state of the
% system
%
% Author: Conrad Nied
%
% Input: GPSP variables structure
% Output: String with filename
%
% Date Created: 2012.08.01 from granger_plot_image_filename
% Last Modified: 2012.08.01

filename = sprintf('%s_%s%s',...
    GPSP_vars.study, GPSP_vars.condition, GPSP_vars.set);

if(nargin == 2)
    movie = varargin{1};
else
    movie = '';
end

%% Brain

if(get(GPSP_vars.brain_show, 'Value'));
    add = '';
    if(get(GPSP_vars.brain_lh_lat, 'Value')); add = [add 'L']; end
    if(get(GPSP_vars.brain_rh_lat, 'Value')); add = [add 'R']; end
    if(get(GPSP_vars.brain_lh_med, 'Value')); add = [add 'l']; end
    if(get(GPSP_vars.brain_rh_med, 'Value')); add = [add 'r']; end
    if(get(GPSP_vars.brain_surface, 'Value') == 2); add = [add 'p']; end
    if(get(GPSP_vars.brain_gyrisulci, 'Value')); add = [add 'g']; end
    if(get(GPSP_vars.brain_aparc, 'Value')); add = [add 'a']; end
    if(get(GPSP_vars.brain_shading, 'Value')); add = [add 's']; end
    if(get(GPSP_vars.brain_order, 'Value') > 1); add = [add 'o' num2str(get(GPSP_vars.brain_order, 'Value'))]; end
    
    if(~isempty(add)); add = ['-' add]; end
        
    filename = sprintf('%s_brain%s', filename, add);
    
    %% Activation

    if(get(GPSP_vars.act_show, 'Value'));
        start = str2double(get(GPSP_vars.act_time_start, 'String'));
        stop = str2double(get(GPSP_vars.act_time_stop, 'String'));
        
        add = '';
        if(get(GPSP_vars.act_colorbar, 'Value')); add = [add 'c']; end
        % otherwise we should manually write the thresholds (or do that
        % anyway)
        
        if(~isempty(add)); add = ['-' add]; end
        
%         if strcmp(movie, 'act');
%             add = sprintf('%s-%sto%s', add,...
%                 get(GPSP_vars.act_time_start, 'String'),...
%                 get(GPSP_vars.act_time_stop, 'String'));
%         else
%             add = sprintf('%s-%dto%d', add,...
%                 GPSP_vars.frame(1),...
%                 GPSP_vars.frame(2));
%         end
        
        filename = sprintf('%s_act-%dto%d%s',...
            filename, start, stop, add);
    else
    %     filename = sprintf('%s', filename);
    end

    %% Phase Locking

%     if(get(GPSP_vars.feat_plv, 'Value'));
%         start = str2double(get(GPSP_vars.act_time_start, 'String'));
%         stop = str2double(get(GPSP_vars.act_time_stop, 'String'));
%         filename = sprintf('%s_plv-%dms-%dms',...
%             filename, start, stop);
%     else
%     %     filename = sprintf('%s', filename);
%     end
else
    filename = sprintf('%s_circle', filename);
end


%% Regions of Interest
if(get(GPSP_vars.rois_labels, 'Value') || get(GPSP_vars.rois_cortical, 'Value'));
    add = '';
    if(get(GPSP_vars.rois_labels, 'Value')); add = [add 'L']; end
    if(get(GPSP_vars.rois_cortical, 'Value'))
        add = [add 'C'];
        if(get(GPSP_vars.rois_smooth, 'Value')); add = [add 's']; end
    end
    
    if(~isempty(add)); add = ['-' add]; end
        
    filename = sprintf('%s_rois%s', filename, add);
else
%     filename = sprintf('%s', filename);
end

%% Causality

if(get(GPSP_vars.cause_show, 'Value') || get(GPSP_vars.node_source, 'Value') || get(GPSP_vars.node_sink, 'Value'));
    add = '';
    
    if(get(GPSP_vars.cause_meanafterthresh, 'Value')); add = [add 'm']; end
    if(get(GPSP_vars.cause_zegnero, 'Value')); add = [add 'z']; end
    if(~isempty(add)); add = ['-' add]; end
    
    if(get(GPSP_vars.cause_signif, 'Value'))
        q_f = get(GPSP_vars.cause_quantile, 'String');
        q_f(q_f == '.') = 'p';
        add = [add 'q' q_f];
    else
        t_f = get(GPSP_vars.cause_threshold, 'String');
        t_f(t_f == '.') = 'p';
        add = [add 't' t_f];
    end
    if(get(GPSP_vars.cause_weights, 'Value')); add = [add 'w']; end
    if(get(GPSP_vars.cause_borders, 'Value')); add = [add 'b']; end
    
    % Arrows
    if(get(GPSP_vars.cause_show, 'Value'));
        s_f = get(GPSP_vars.cause_scale, 'String');
        s_f(s_f == '.') = 'p';
        
        add = [add '-As' s_f];
    end
    
    % Node
    if(get(GPSP_vars.node_source, 'Value') || get(GPSP_vars.node_sink, 'Value'))
        if(get(GPSP_vars.node_source, 'Value'))
            if(get(GPSP_vars.node_sink, 'Value'))
                add = [add '-N'];
            else
                add = [add '-NO'];
            end
        elseif(get(GPSP_vars.node_sink, 'Value'))
            add = [add '-NI'];
        end
        
        s_f = get(GPSP_vars.node_scale, 'String');
        s_f(s_f == '.') = 'p';
        add = [add 's' s_f];
        
        if(get(GPSP_vars.node_count, 'Value')); add = [add 'c']; end
%         if(get(GPSP_vars.node_cum, 'Value')); add = [add 'u']; end
        if(get(GPSP_vars.node_rel, 'Value')); add = [add 'r']; end
        if(get(GPSP_vars.node_focusspec, 'Value')); add = [add 'f']; end
    end
    
    % Focus
    add = [add '-F'];
    focus  = get(GPSP_vars.focus_list, 'Value');
    rois   = gpsp_get('rois');
    lefts  = intersect([rois.hemi] == 'L', focus);
    rights = intersect([rois.hemi] == 'R', focus);
    if(get(GPSP_vars.focus_all, 'Value'))
        add = [add 'a'];
    elseif(get(GPSP_vars.focus_left, 'Value'))
        add = [add 'L'];
        if(~isempty(rights))
            add = sprintf('%sr%x', add, sum(power(2, rights - 1)));
        end
    elseif(get(GPSP_vars.focus_right, 'Value'))
        add = [add 'R'];
        if(~isempty(lefts))
            add = sprintf('%sl%x', add, sum(power(2, lefts - 1)));
        end
    else
        if(~isempty(focus))
            add = sprintf('%s%x', add, sum(power(2, focus - 1)));
        end
    end
    if(get(GPSP_vars.focus_exclusive, 'Value')); add = [add 'x']; end
    if(get(GPSP_vars.focus_interhemi, 'Value')); add = [add 'i']; end
    
    % Frame
    add = [add '-R'];
    if(get(GPSP_vars.frames_orient, 'Value') > 1); add = [add 'c']; end
    if(get(GPSP_vars.frames_clusivity, 'Value') > 1); add = [add 'l']; end
    if(get(GPSP_vars.frames_timestamp, 'Value')); add = [add 's']; end
    
    if(~get(GPSP_vars.node_cum, 'Value'))
        if strcmp(movie, 'cause');
            add = sprintf('%s-%sto%s', add,...
                get(GPSP_vars.frames_windowstart, 'String'),...
                get(GPSP_vars.frames_windowstop, 'String'));
        else
            add = sprintf('%s-%dto%d', add,...
                GPSP_vars.frame(1),...
                GPSP_vars.frame(2));
        end
    else
        add = [add '-cum'];
    end
    
    % No pairings
    
    filename = sprintf('%s_cause%s', filename, add);
else
    filename = sprintf('%s', filename);
end

%% Display

switch get(GPSP_vars.display_bg, 'Value')
    case 1
        filename = sprintf('%s_bgW', filename);
    case 3
        filename = sprintf('%s_bgQ', filename);
    case 4
        filename = sprintf('%s_bgK', filename);
end % which background?

end % function