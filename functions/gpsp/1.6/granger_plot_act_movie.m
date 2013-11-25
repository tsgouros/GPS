function GPSP_vars = granger_plot_act_movie(GPSP_vars)
% Compose map of brain activation data in a movie
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream Plotting variables/handle
% Output: none, refreshes the GPSP_vars figure and saves to files
%
% Date Created: 2012.05.15
% Last Modified: 2012.05.23

hObject = GPSP_vars.act_movie;

%% Movie Setup

folder = sprintf('%s/images/%s', GPSP_vars.savedir, datestr(now, 'yymmdd'));
if(~exist(folder, 'dir')); mkdir(folder); end

filename = sprintf('%s/actm_%s',...
    folder, granger_plot_image_filename(GPSP_vars, 'act'));
if(~exist(filename, 'dir')); mkdir(filename); end

start = str2double(get(GPSP_vars.act_time_start, 'String'));
stop = str2double(get(GPSP_vars.act_time_stop, 'String'));

% Setup Movie
N_frames = stop - start + 1;
mov(1:N_frames) = struct('cdata', [],...
    'colormap', []);

%% Acquire Data
brain = getappdata(GPSP_vars.figure1, 'brain');
act = getappdata(GPSP_vars.figure1, 'act');

%% Draw frames

% base_draw each frame
for i_frame = 1:N_frames
    
    act.data = act.data_raw(:, i_frame + start - 1);
    data = zeros(brain.N,1);
    data(act.decIndices) = act.data;

    % Left Side
    face = brain.lface;
    actcoords = brain.pialcoords(1:brain.N_L, :);
    ldata = data(1:brain.N_L);
    ldata = inverse_smooth('', 'value', ldata,...
        'step', 5,...
        'face', double(face' - 1),...
        'vertex', actcoords');

    % Right Side
    face = brain.rface;
    actcoords = brain.pialcoords((brain.N_L + 1):end, :);
    rdata = data((brain.N_L + 1):end);
    rdata = inverse_smooth('', 'value', rdata,...
        'step', 5,...
        'face', double(face' - 1),...
        'vertex', actcoords');

    % Synthesize
    act.data = [ldata; rdata];

    % Update the GUI
    GPSP_vars.customstamp = sprintf('%03d ms', i_frame + start - 1);
    setappdata(GPSP_vars.figure1, 'act', act);
    granger_plot_act_threshold(GPSP_vars);
    
    % Get Frame into
    frame = getframe(GPSP_vars.display_axes);
    mov(i_frame) = frame;
    framename = sprintf('%s/f%03d.png', filename, i_frame);
    imwrite(frame.cdata, framename, 'png');
end

%% Create AVI file
% fps = get(handles.frames_fps, 'String');
% movfile = sprintf('%s.avi',...
%     filename);
% movie2avi(mov, movfile, 'compression', 'None', 'fps', fps);
movfile = sprintf('%s.zip',...
    filename);
zip(movfile, [filename '/*.png']);

fileattrib(movfile, '+w', 'a')

GPSP_vars = rmfield(GPSP_vars, 'customstamp');
guidata(hObject, GPSP_vars);

end % function