function plot_frames(GPSP_vars)
% Allocates the frames given the preferences
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream Plotting variables/handle
% Output: nothing, saved to handle
%
% Date Created: 2012.08.07 from granger_plot_frames
% Last Modified: 2012.08.07
% 2013.07.02 - Doesn't render the slider if it isn't useful

% Get frame parameters
start = str2double(get(GPSP_vars.frames_windowstart, 'String'));
stop = str2double(get(GPSP_vars.frames_windowstop, 'String'));
duration = str2double(get(GPSP_vars.frames_duration, 'String'));
interval = str2double(get(GPSP_vars.frames_interval, 'String'));

clusivity = get(GPSP_vars.frames_clusivity, 'Value');
clusivity(2) = clusivity(1) ~= 1;
clusivity(1) = clusivity(1) == 3;
orientation = (get(GPSP_vars.frames_orient, 'Value') == 2);

% Make frames
if(start < stop)
    frame_starts = (start:interval:stop - ~orientation)' - orientation * duration / 2;
    GPSP_vars.frames = [frame_starts + clusivity(1) (frame_starts + duration - clusivity(2))];
    GPSP_vars.frame = [(start + clusivity(1)) (start + duration - clusivity(2))];
end

% Set the slider's properties
N_frames = length(frame_starts);
if(N_frames > 1)
    slider_step = [1 / (N_frames - 1), 10 / (N_frames - 1)];
    set(GPSP_vars.frames_select, 'Enable', 'on');
    set(GPSP_vars.frames_select, 'Min', 1);
    set(GPSP_vars.frames_select, 'Max', N_frames);
    set(GPSP_vars.frames_select, 'Value', 1);
    set(GPSP_vars.frames_select, 'SliderStep',...
        slider_step);
else
    set(GPSP_vars.frames_select, 'Enable', 'off');
    set(GPSP_vars.frames_select, 'Min', 1);
    set(GPSP_vars.frames_select, 'Max', 2);
    set(GPSP_vars.frames_select, 'Value', 1);
    set(GPSP_vars.frames_select, 'SliderStep', [1 2]);
end

% Set the slider's text
select_text = sprintf('Viewing Frame: %d - %d',...
    start, (start + duration));
set(GPSP_vars.frames_select_text, 'String', select_text);

%% Update the GUI
guidata(GPSP_vars.frames_windowstart, GPSP_vars);

end % function