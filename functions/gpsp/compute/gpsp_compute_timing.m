function gpsp_compute_timing
% Allocates the time windows given the preferences
%
% Author: A. Conrad Nied (conrad.logos@gmail.com
%
% Changelog:
% 2012-08-07 Created from granger_plot_frames as plot_frames
% 2013-07-02 Doesn't render the slider if it isn't useful
% 2013-07-15 Remade for GPS1.8/gpsp_compute_timing

state = gpsp_get;

% Get frame parameters
start = str2double(get(state.time_windowstart, 'String'));
stop = str2double(get(state.time_windowstop, 'String'));
duration = str2double(get(state.time_duration, 'String'));
interval = str2double(get(state.time_interval, 'String'));

bounds = get(state.time_bounds, 'Value');
bounds(2) = bounds(1) ~= 1;
bounds(1) = bounds(1) == 3;
anchor = (get(state.time_anchor, 'Value') == 2);

% Make frames
if(start < stop)
    frame_starts = (start:interval:stop - ~anchor)' - anchor * duration / 2;
    state.frames = [frame_starts + bounds(1) (frame_starts + duration - bounds(2))];
else
    error('Stop (%d) precedes start (%d)', stop, start);
end

% Set the slider's properties
N_frames = length(frame_starts);
if(N_frames > 1)
    slider_step = [1 / (N_frames - 1), 10 / (N_frames - 1)];
    set(state.time_select, 'Enable', 'on');
    set(state.time_select, 'Min', 1);
    set(state.time_select, 'Max', N_frames);
    set(state.time_select, 'SliderStep', slider_step);
else
    set(state.time_select, 'Enable', 'off');
    set(state.time_select, 'Min', 1);
    set(state.time_select, 'Max', 2);
    set(state.time_select, 'Value', 1);
    set(state.time_select, 'SliderStep', [1 2]);
end

% Get the currently selected frame
i_frame = get(state.time_select, 'Value');

if(i_frame > N_frames || i_frame < 1)
    i_frame = 1;
    set(state.time_select, 'Value', i_frame);
elseif(i_frame ~= round(i_frame))
    i_frame = round(i_frame);
    set(state.time_select, 'Value', i_frame);
end

state.frame = state.frames(i_frame, :);

% Set the slider's text and method text
select_text = sprintf('Viewing Frame: %d - %d',...
    state.frame(1), state.frame(2));
set(state.time_select_text, 'String', select_text);

method_text = sprintf('%d to %d',...
    state.frame(1), state.frame(2));
set(state.method_time, 'String', method_text);

%% Update the GUI
gpsp_set(state);
guidata(state.time_select, state);

gpsp_compute_granger;

end % function