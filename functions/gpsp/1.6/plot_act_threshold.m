function GPSP_vars = plot_act_threshold(GPSP_vars)
% Aligns the thresholds for the activation plot
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream Plotting variables/handle
% Output: none, refreshes the GPSP_vars figure
%
% Date Created: 2012.07.05 from granger_plot_act_threshold
% Last Modified: 2012.07.05
% 2012.10.11 - Loosely adapted to GPS1.7

hObject = GPSP_vars.act_p;

act = gpsp_get('act');

if(~isempty(act))

    %% Get the thresholds & synergize

    if(get(GPSP_vars.act_p,'Value') == 1) % Do it by percentiles
        p1 = str2double(get(GPSP_vars.act_p1, 'String'));
        p2 = str2double(get(GPSP_vars.act_p2, 'String'));
        p3 = str2double(get(GPSP_vars.act_p3, 'String'));
        vs = prctile(act.data, [p1 p2 p3]);
        v1 = vs(1);
        v2 = vs(2);
        v3 = vs(3);
        set(GPSP_vars.act_v1, 'String', num2str(v1));
        set(GPSP_vars.act_v2, 'String', num2str(v2));
        set(GPSP_vars.act_v3, 'String', num2str(v3));
    else % Do it by values
        v1 = str2double(get(GPSP_vars.act_v1, 'String'));
        v2 = str2double(get(GPSP_vars.act_v2, 'String'));
        v3 = str2double(get(GPSP_vars.act_v3, 'String'));
        p1 = mean(act.data < v1) * 100;
        p2 = mean(act.data < v2) * 100;
        p3 = mean(act.data < v3) * 100;
        set(GPSP_vars.act_p1, 'String', num2str(p1));
        set(GPSP_vars.act_p2, 'String', num2str(p2));
        set(GPSP_vars.act_p3, 'String', num2str(p3));
    end

%     act.percentiles = [p1 p2 p3 100];

    %% Update the GUI
%     setappdata(GPSP_vars.figure1, 'act', act);
    
    guidata(hObject, GPSP_vars);
    refresh(GPSP_vars.guifig);
    
    % Draw the brain
    plot_draw(GPSP_vars);
end

end % function