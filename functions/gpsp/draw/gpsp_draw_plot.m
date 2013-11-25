function gpsp_draw_plot
% Draws either plot (based on the settings)
% 
% Author: A. Conrad Nied (conrad.logos@gmail.com)
% 
% Changelog:
% 2013-07-15 Created GPS1.8/gpsp_draw_plot

% state = gpsp_get;
%
% switch get(state.base_plot, 'Value')
%     case 1 % Surface
%         gpsp_draw_surf;
%     case 2 % Timecourse
%         gpsp_draw_tc;
% end

gpsp_draw_surf;
gpsp_draw_tc;


end % function