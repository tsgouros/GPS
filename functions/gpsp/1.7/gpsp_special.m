function gpsp_special(varargin)
% Does special (usually batch actions) for GPSP
%
% Author: Conrad Nied
%
% Input: The name of the structure you want to fetch
% Output: The structure from the GPSa guifig
%
% Changelog:
% 2012.10.15 - Created
% 2012.10.15 - Added PLV clause
% 2012.11.12 - Modified for PTC2

% Handle Input / Get State
if(nargin == 1)
    state = varargin{1};
else
    state = gpsp_get;
end

study = gpsp_parameter(state, state.study);

% For All subsets (we care about)

subsets = get(state.data_condition, 'String');

% i_subsets = 6:24;
% i_subsets = [8, 9, 10, 13, 17, 18, 19, 22];

for i_subset = i_subsets
    subset = subsets{i_subset};
    fprintf('%s\n', subset);
    
    %% Load Data
    
    % Subset
    set(state.data_condition, 'Value', i_subset);
    plot_data_condition(state);
    state = guidata(state.data_condition);
    
    % Granger Load
    plot_data_granger(state);
    state = guidata(state.data_condition);
    
    % Activation Select and Load
    %     state.file_activity = sprintf('%s/%s/stcs/%s_%s_%s_act-lh.stc',...
    %         study.meg.dir, study.average_name,...
    %         study.name, study.average_name, subset);
    state.file_activity = sprintf('%s/results/%s_%s_%s_plv_LSTG1_40Hz-lh.stc',...
        study.plv.dir, study.name, study.average_name, subset);
%     state.file_activity = sprintf('%s/%s/stcs/%s_%s_%s_act-lh.stc',...
%         study.meg.dir, study.average_name,...
%         study.name, study.average_name, subset);
    plot_data_activity(state);
    state = guidata(state.data_condition);
    
    %% Activation
    set(state.act_show, 'Value', 1);
    plot_draw(state);
%     state = guidata(state.data_condition);
    set(state.act_show, 'Value', 0);
    
%     folder = sprintf('%s/images/%s/activity', state.dir, datestr(now, 'yymmdd'));
    folder = sprintf('%s/images/%s/plvbl', state.dir, datestr(now, 'yymmdd'));
    if(~exist(folder, 'dir')); mkdir(folder); end
    filename = sprintf('%s/%s.png',...
        folder, plot_image_filename(state));
    
    frame = getframe(state.display_brainaxes);
    imwrite(frame.cdata, filename, 'png');
    
    %% Granger node interactions
%     set(state.node_focusspec, 'Value', 1);
%     
%     foci = [5 6 7 8 18 19];
%     for i_focus = 5%1:6
%         focusrois = {'LMTG', 'LSMG1', 'LSMG2', 'LSMG3', 'RSTG1', 'RSTG2'};
%         set(state.focus_list, 'Value', foci(i_focus));
%         plot_focus(state)
%         state = guidata(state.data_condition);
%         
%         set(state.node_source, 'Value', 1);
%         set(state.node_sink, 'Value', 0);
%         
%         plot_rois_compose(state);
%         state = guidata(state.data_condition);
% %         plot_draw(state);
% %         state = guidata(state.data_condition);
% %         
% %         folder = sprintf('%s/images/%s/sources', state.dir, datestr(now, 'yymmdd'));
% %         if(~exist(folder, 'dir')); mkdir(folder); end
% %         filename = sprintf('%s/%s_%s_%s_sources.png',...
% %             folder, study.name, subset, focusrois{i_focus});
% %         
% %         frame = getframe(state.display_brainaxes);
% %         imwrite(frame.cdata, filename, 'png');
%         
%         % Only Left Lateral Surface
%         set(state.brain_lh_med, 'Value', 0);
%         set(state.brain_rh_med, 'Value', 0);
%         set(state.brain_rh_lat, 'Value', 0);
%         
%         plot_draw(state);
%         state = guidata(state.data_condition);
%         
%         folder = sprintf('%s/images/%s/sources', state.dir, datestr(now, 'yymmdd'));
%         if(~exist(folder, 'dir')); mkdir(folder); end
%         filename = sprintf('%s/%s_%s_%s_sources_ll.png',...
%             folder, study.name, subset, focusrois{i_focus});
%         
%         frame = getframe(state.display_brainaxes);
%         imwrite(frame.cdata, filename, 'png');
%         
%         % Reset
%         set(state.brain_lh_med, 'Value', 1);
%         set(state.brain_rh_med, 'Value', 1);
%         set(state.brain_rh_lat, 'Value', 1);
%         
%         
%         % Both ways
% %         set(state.node_source, 'Value', 1);
% %         set(state.node_sink, 'Value', 1);
% %         
% %         plot_draw(state);
% %     state = guidata(state.data_condition);
% %         
% %         folder = sprintf('%s/images/%s/srcsnks', state.dir, datestr(now, 'yymmdd'));
% %         if(~exist(folder, 'dir')); mkdir(folder); end
% %         filename = sprintf('%s/%s_%s_%s_srcsnks.png',...
% %             folder, study.name, subset, focusrois{i_focus});
% %         
% %         frame = getframe(state.display_brainaxes);
% %         imwrite(frame.cdata, filename, 'png');
%     end
%     
%     state = guidata(state.data_condition);
%     set(state.node_focusspec, 'Value', 0);
%     set(state.node_source, 'Value', 0);
%     set(state.node_sink, 'Value', 0);
%     plot_draw(state);
    
    %% Granger timecourses
    
%     set(state.focus_list, 'Value', 18); % R-STG-1
%     plot_focus(state)
%     state = guidata(state.focus_list);
%     
%     foci = [5 6 7 8 22 23 24 25];
%     focusrois = {'LMTG', 'LSMG1', 'LSMG2', 'LSMG3'};
%     
%     for i_focus = 1:2
%         roiinteract = 'areas';
% %         roiinteract = focusrois{mod(i_focus - 1, 4) + 1};
%         set(state.wave_list, 'Value', foci((1:4) + 4 * (i_focus - 1)));
%         
% %         plot_wave(state);
% %     state = guidata(state.data_condition);
% %         
% %         % Single Timecourse
% %         folder = sprintf('%s/images/%s/gcitc_rstg1', state.dir, datestr(now, 'yymmdd'));
% %         if(~exist(folder, 'dir')); mkdir(folder); end
% %         fromto = 'from'; if(i_focus >= 2); fromto = 'to'; end
% %         filename = sprintf('%s/%s_%s_RSTG1_%s_%s.png',...
% %             folder, study.name, subset, fromto, roiinteract);
% %         
% %         frame = getframe(state.display_timecoursefig);
% %         imwrite(frame.cdata, filename, 'png');
% % %             saveas(state.display_timecoursefig, filename, 'png');
%         
%         % Both ways
%         if(i_focus <= 1)
%             set(state.wave_iceberg, 'Value', 1);
%             set(state.wave_reflections, 'Value', 1);
%             
%             plot_wave(state);
%             state = guidata(state.data_condition);
%             
%             folder = sprintf('%s/images/%s/gcitc_rstg1_grouped', state.dir, datestr(now, 'yymmdd'));
%             if(~exist(folder, 'dir')); mkdir(folder); end
%             filename = sprintf('%s/%s_%s_RSTG1_with_%s.png',...
%                 folder, study.name, subset, roiinteract);
%             
%             frame = getframe(state.display_timecoursefig);
%             imwrite(frame.cdata, filename, 'png');
% %             saveas(state.display_timecoursefig, filename, 'png');
%             
%             set(state.wave_iceberg, 'Value', 0);
%             set(state.wave_reflections, 'Value', 0);
%         end % In the first half
%     end
%     
%     
%     plot_wave(state);
    
end % for all subsets

end % function