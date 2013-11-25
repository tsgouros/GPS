function gpsp_compute_activity_colors
% Aligns the thresholds for the activation plot
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-08-14 Created GPS1.8/ from GPS1.7/plot_act_threshold

state = gpsp_get;
act = gpsp_get('act');

if(~isempty(act) && isfield(act, 'data'))

    %% Get the thresholds & synergize

    if(get(state.act_p,'Value') == 1) % Do it by percentiles
        p1 = str2double(get(state.act_p1, 'String'));
        p2 = str2double(get(state.act_p2, 'String'));
        p3 = str2double(get(state.act_p3, 'String'));
        vs = prctile(act.data, [p1 p2 p3]);
        v1 = vs(1);
        v2 = vs(2);
        v3 = vs(3);
        set(state.act_v1, 'String', num2str(v1));
        set(state.act_v2, 'String', num2str(v2));
        set(state.act_v3, 'String', num2str(v3));
    else % Do it by values
        v1 = str2double(get(state.act_v1, 'String'));
        v2 = str2double(get(state.act_v2, 'String'));
        v3 = str2double(get(state.act_v3, 'String'));
        p1 = mean(act.data < v1) * 100;
        p2 = mean(act.data < v2) * 100;
        p3 = mean(act.data < v3) * 100;
        set(state.act_p1, 'String', num2str(p1));
        set(state.act_p2, 'String', num2str(p2));
        set(state.act_p3, 'String', num2str(p3));
    end

    %% Update the GUI
    
    % Draw the activity on the brain
    gpsp_draw_surf;
end

end % function