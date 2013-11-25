function varargout = GPS_plot(varargin)
% GPS_PLOT MATLAB code for GPS_plot.fig
%      GPS_PLOT, by itself, creates a new GPS_PLOT or raises the existing
%      singleton*.
%
%      H = GPS_PLOT returns the handle to a new GPS_PLOT or the handle to
%      the existing singleton*.
%
%      GPS_PLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GPS_PLOT.M with the given input arguments.
%
%      GPS_PLOT('Property','Value',...) creates a new GPS_PLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GPS_plot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GPS_plot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GPS_plot

% Last Modified by GUIDE v2.5 11-Jul-2013 00:19:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GPS_plot_OpeningFcn, ...
                   'gui_OutputFcn',  @GPS_plot_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GPS_plot is made visible.
function GPS_plot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GPS_plot (see VARARGIN)

% Choose default command line output for GPS_plot
handles.output = hObject;

% Run setup script
plot_setup(handles);

% --- Outputs from this function are returned to the command line.
function varargout = GPS_plot_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function data_study_Callback(hObject, eventdata, handles)
plot_data_study(handles);

function data_study_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function data_condition_Callback(hObject, eventdata, handles)
plot_data_condition(handles);

function data_condition_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function data_compare_Callback(hObject, eventdata, handles)
plot_data_set(handles);

function data_compare_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function frames_windowstart_Callback(hObject, eventdata, handles)
plot_frames(handles);

function frames_windowstart_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function frames_windowstop_Callback(hObject, eventdata, handles)
plot_frames(handles);

function frames_windowstop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function frames_select_Callback(hObject, eventdata, handles)
% Get the Frame
i_frame = get(handles.frames_select, 'Value');
if(i_frame ~= round(i_frame))
    i_frame = round(i_frame);
    set(handles.frames_select, 'Value', i_frame);
end
handles.frame = handles.frames(i_frame, :);

% Set the slider's text
select_text = sprintf('Viewing Frame: %d - %d',...
    handles.frame(1), handles.frame(2));
set(handles.frames_select_text, 'String', select_text);

% base_draw
plot_draw(handles);

function frames_select_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function frames_duration_Callback(hObject, eventdata, handles)
plot_frames(handles);

function frames_duration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function frames_interval_Callback(hObject, eventdata, handles)
plot_frames(handles);

function frames_interval_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function frames_makemovie_Callback(hObject, eventdata, handles)

folder = sprintf('%s/images/%s', handles.dir, datestr(now, 'yymmdd'));
if(~exist(folder, 'dir')); mkdir(folder); end
% filename = sprintf('%s/%s_%s%s_movie_%s',...
%     folder, handles.study, handles.condition, handles.set, datestr(now, 'hhmmss'));

filename = sprintf('%s/movie_%s',...
    folder, plot_image_filename(handles, 'cause'));
if(~exist(filename, 'dir')); mkdir(filename); end

% Setup Movie
N_frames = length(handles.frames);
mov(1:N_frames) = struct('cdata', [],...
    'colormap', []);

% base_draw each frame
for i_frame = 1:N_frames
    handles.frame = handles.frames(i_frame, :);
    
    plot_draw(handles);
    
    frame = getframe(handles.display_brainaxes);
    mov(i_frame) = frame;
    framename = sprintf('%s/f%03d.png', filename, i_frame);
    imwrite(frame.cdata, framename, 'png');
end

% Create AVI file
% fps = get(handles.frames_fps, 'String');
% movfile = sprintf('%s.avi',...
%     filename);
% movie2avi(mov, movfile, 'compression', 'None', 'fps', fps);
movfile = sprintf('%s.zip',...
    filename);
zip(movfile, [filename '/*.png']);

fileattrib(movfile, '+w', 'a')

function cause_signif_Callback(hObject, eventdata, handles)
plot_draw(handles);

function base_draw_Callback(hObject, eventdata, handles)
plot_draw(handles);

function data_granger_load_Callback(hObject, eventdata, handles)
plot_data_granger(handles);

function cause_scale_Callback(hObject, eventdata, handles)
plot_draw(handles);

function cause_scale_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cause_threshold_Callback(hObject, eventdata, handles)
gpsp_data_significance(handles);
plot_draw(handles);

function cause_threshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function display_autoredraw_Callback(hObject, eventdata, handles)
plot_draw(handles);

function focus_list_Callback(hObject, eventdata, handles)
plot_focus(handles);

function focus_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function focus_exclusive_Callback(hObject, eventdata, handles)
plot_focus(handles);

function feat_cause_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function base_email_Callback(hObject, eventdata, handles)

% Set mailto if not already set
if(~isfield(handles, 'mailto'))
    inputs = inputdlg({'Destination Email'},...
        'Configure Email Settings',...
        1, {[getenv('USER') '@nmr.mgh.harvard.edu']});
    handles.mailto = inputs{1};

    % update handles
    guidata(hObject, handles);
end

folder = sprintf('%s/images/%s', handles.dir, datestr(now, 'yymmdd'));
if(~exist(folder, 'dir')); mkdir(folder); end
filename = sprintf('%s/%s.png',...
    folder, plot_image_filename(handles));

frame = getframe(handles.display_brainaxes);
imwrite(frame.cdata, filename, 'png');
% To fix permissions problem
fileattrib(filename, '+w', 'a')
fileattrib(folder, '+w', 'a');

% Compose Message
message{1} = sprintf('Study: %s', handles.study);
message{2} = sprintf('Condition: %s', handles.condition);
message{3} = sprintf('Time Window: %d to %d', handles.frame(1), handles.frame(2));

% Send the base_email
sendmail(handles.mailto, 'Granger Image', message, filename);

function focus_all_Callback(hObject, eventdata, handles)
plot_focus(hObject, handles);

function focus_left_Callback(hObject, eventdata, handles)
plot_focus(hObject, handles);

function focus_right_Callback(hObject, eventdata, handles)
plot_focus(hObject, handles);

function base_email_config_Callback(hObject, eventdata, handles)

defaults{1} = '';
if(isfield(handles, 'mailto'))
    defaults{2} = handles.mailto;
else
    defaults{2} = [getenv('USER') '@nmr.mgh.harvard.edu'];
end

% Get the Users Password
inputs = inputdlg({'Martinos Network Password','Destination Email'},...
    'Configure Email Settings',...
    1, defaults);
handles.mailto = inputs{2};

% Set base_email Preferences and Options
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');

setpref('Internet', 'SMTP_Server', 'smtp.nmr.mgh.harvard.edu');
setpref('Internet', 'SMTP_Username', getenv('USER'));
setpref('Internet', 'SMTP_Password', inputs{1});
setpref('Internet', 'E_mail', [getenv('USER') '@nmr.mgh.harvard.edu']);

clear inputs;

% set(handles.base_email, 'Enable', 'on');

% Update handles structure
guidata(hObject, handles);

function cause_weights_Callback(hObject, eventdata, handles)
plot_draw(handles);

function cause_borders_Callback(hObject, eventdata, handles)
plot_draw(handles);

function rois_labels_Callback(hObject, eventdata, handles)
plot_draw(handles);

function focus_interhemi_Callback(hObject, eventdata, handles)
plot_focus(handles);

function brain_lh_lat_Callback(hObject, eventdata, handles)
plot_draw(handles);

function brain_rh_lat_Callback(hObject, eventdata, handles)
plot_draw(handles);

function brain_lh_med_Callback(hObject, eventdata, handles)
plot_draw(handles);

function brain_rh_med_Callback(hObject, eventdata, handles)
plot_draw(handles);

function frames_email_movie_Callback(hObject, eventdata, handles)

% Set mailto if not already set
if(~isfield(handles, 'mailto'))
    inputs = inputdlg({'Destination Email'},...
        'Configure Email Settings',...
        1, {[getenv('USER') '@nmr.mgh.harvard.edu']});
    handles.mailto = inputs{1};

    % update handles
    guidata(hObject, handles);
end

folder = sprintf('%s/images/%s', handles.dir, datestr(now, 'yymmdd'));
movfile = sprintf('%s/movie_%s.zip',...
    folder, plot_image_filename(handles, true));
% movfile = sprintf('%s/%s_%s_grangers.avi',...
%     handles.imagefolder, handles.study, handles.condition);


if(exist(movfile, 'file'))
    % Compose Message
    message{1} = sprintf('Type: %s', 'movie' );
    message{2} = sprintf('Study: %s', handles.study);
    message{3} = sprintf('Condition: %s', handles.condition);
%     message{4} = sprintf('Time Window: %d to %d', handles.frame(1), handles.frame(2));
    message{4} = sprintf('Filename: %s', movfile);
    message{5} = sprintf('What other variables do you want in this list?');

    % Send the base_email
    sendmail(handles.mailto, 'Granger Movie', message, movfile);
else
    [sound fs] = wavread('functions/wav/difficult.wav');
    soundsc(sound, fs);
end

function frames_fps_Callback(hObject, eventdata, handles)
% Nothing, fed into frames_make_movie

function frames_fps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function node_cum_Callback(hObject, eventdata, handles)
plot_draw(handles);

function node_count_Callback(hObject, eventdata, handles)

% Set the other radio button
set(handles.node_sum, 'Value', ~get(handles.node_count, 'Value'));

% If automatically refreshing, redraw the brain
plot_draw(handles);

function node_sum_Callback(hObject, eventdata, handles)

% Set the other radio button
set(handles.node_count, 'Value', ~get(handles.node_sum, 'Value'));

% If automatically refreshing, redraw the brain
plot_draw(handles);

function wave_smooth_Callback(hObject, eventdata, handles)
plot_draw(handles);

function wave_smooth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function wave_list_Callback(hObject, eventdata, handles)
plot_wave(handles);

function wave_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function wave_draw_Callback(hObject, eventdata, handles)
plot_wave(handles);

function cause_quantile_Callback(hObject, eventdata, handles)

threshold = str2double(get(handles.cause_quantile, 'String'));
if(threshold > 1)
    warndlg('Quantile may not exceed 1')
    set(handles.cause_quantile, 'String', '1.00');
%     threshold = 1;
elseif(threshold < 0)
    warndlg('Quantile may not be less than 0')
    set(handles.cause_quantile, 'String', '0.00');
%     threshold = 0;
end

gpsp_data_significance(handles);
plot_draw(handles);

% Compute new alpha values
% granger = plot_get('granger');
% datafile = load(handles.file_granger);
% 
% granger.name = 'granger';
% granger.results = datafile.granger_results;
% 
% if(isstruct(datafile.alpha_values))
%     threshold = str2double(get(handles.cause_quantile, 'String'));
%     if(isempty(threshold))
%         granger.granger_results = datafile.alpha_values.p;
%         threshold2 = str2double(get(handles.cause_threshold, 'String'));
%         alpha_values = ones(size(handles.granger_results)) * threshold2;
%     elseif(isfield(datafile.alpha_values, ['p' num2str(threshold*1000)]))
%         alpha_values = datafile.alpha_values.(['p' num2str(threshold*1000)]);
%     else
%         alpha_values = quantile(datafile.total_control_granger, threshold, 4);
%     end
% else
%     alpha_values = quantile(datafile.total_control_granger, threshold, 4);
% end
% 
% signif_conn = granger.results > alpha_values;
% 
% granger.signif_conn = signif_conn;
% granger.alpha_values = alpha_values;
% 
% plot_set(granger);

% guidata(hObject, handles);

function cause_quantile_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function wave_email_Callback(hObject, eventdata, handles)

% Set mailto if not already set
if(~isfield(handles, 'mailto'))
    inputs = inputdlg({'Destination Email'},...
        'Configure Email Settings',...
        1, {[getenv('USER') '@nmr.mgh.harvard.edu']});
    handles.mailto = inputs{1};

    % update handles
    guidata(hObject, handles);
end

folder = sprintf('%s/images/%s', handles.dir, datestr(now, 'yymmdd'));
if(~exist(folder, 'dir')); mkdir(folder); end
filename = sprintf('%s/%s', folder, plot_timecoursefig_filename(handles));

filename = sprintf('%s.png', filename);
saveas(handles.display_timecoursefig, filename);

% To fix permissions problem
fileattrib(filename, '+w', 'a')
fileattrib(folder, '+w', 'a')

% Compose Message
message{1} = sprintf('Granger Wave Plot');
message{2} = sprintf('Study: %s', handles.study);
message{3} = sprintf('Condition: %s', handles.condition);
message{4} = sprintf('Showing Interations between');

pairs_chosen = get(handles.wave_list, 'Value');
wavelabels = get(handles.wave_list, 'String');
wavelabels = wavelabels(pairs_chosen);

for i = 1:length(wavelabels)
    message{4 + i} = sprintf('\t%s', wavelabels{i});
end
    
% Send the base_email
sendmail(handles.mailto, 'Granger Wave Image', message, filename)

function feat_brain_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function feat_act_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function feat_plv_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function feat_rois_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function cause_style_Callback(hObject, eventdata, handles)
plot_draw(handles);

function cause_style_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cause_color_Callback(hObject, eventdata, handles)
plot_draw(handles);

function cause_color_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function brain_gyrisulci_Callback(hObject, eventdata, handles)
plot_draw(handles);

function brain_aparc_Callback(hObject, eventdata, handles)
plot_draw(handles);

function brain_surface_Callback(hObject, eventdata, handles)
plot_draw(handles);

function brain_surface_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function act_time_start_Callback(hObject, eventdata, handles)

act = plot_get('act');
if(~isempty(act))
    plot_act_compose(handles);
end

function act_time_start_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function act_time_stop_Callback(hObject, eventdata, handles)

act = plot_get('act');
if(~isempty(act))
    plot_act_compose(handles);
end

function act_time_stop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function act_p1_Callback(hObject, eventdata, handles)

set(handles.act_p, 'Value', 1);
set(handles.act_v, 'Value', 0);

plot_act_threshold(handles);

function act_p1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function act_p3_Callback(hObject, eventdata, handles)

set(handles.act_p, 'Value', 1);
set(handles.act_v, 'Value', 0);

plot_act_threshold(handles);

function act_p3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function act_p2_Callback(hObject, eventdata, handles)

set(handles.act_p, 'Value', 1);
set(handles.act_v, 'Value', 0);

plot_act_threshold(handles);

function act_p2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function act_p_Callback(hObject, eventdata, handles)
isSelected = get(handles.act_v, 'Value');
set(handles.act_p, 'Value', ~isSelected);

plot_act_threshold(handles);

function act_v1_Callback(hObject, eventdata, handles)

set(handles.act_p, 'Value', 0);
set(handles.act_v, 'Value', 1);

plot_act_threshold(handles);

function act_v1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function act_v3_Callback(hObject, eventdata, handles)

set(handles.act_p, 'Value', 0);
set(handles.act_v, 'Value', 1);

plot_act_threshold(handles);

function act_v3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function act_v2_Callback(hObject, eventdata, handles)

set(handles.act_p, 'Value', 0);
set(handles.act_v, 'Value', 1);

plot_act_threshold(handles);

function act_v2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function act_v_Callback(hObject, eventdata, handles)

isSelected = get(handles.act_v, 'Value');
set(handles.act_p, 'Value', ~isSelected);

plot_act_threshold(handles);

function node_source_Callback(hObject, eventdata, handles)
plot_draw(handles);

function node_sink_Callback(hObject, eventdata, handles)
plot_draw(handles);

function rois_smooth_Callback(hObject, eventdata, handles)
plot_rois_compose(handles)

function rois_compose_Callback(hObject, eventdata, handles)
plot_rois_compose(handles)

function act_compose_Callback(hObject, eventdata, handles)
plot_act_compose(handles);

function base_save_Callback(hObject, eventdata, handles)

folder = sprintf('%s/images/%s', handles.dir, datestr(now, 'yymmdd'));
if(~exist(folder, 'dir')); mkdir(folder); end
filename = sprintf('%s/%s.png',...
    folder, plot_image_filename(handles));

frame = getframe(handles.display_brainaxes);
imwrite(frame.cdata, filename, 'png');

function brain_order_Callback(hObject, eventdata, handles)
plot_draw(handles);

function brain_order_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function display_bg_Callback(hObject, eventdata, handles)

switch(get(hObject, 'Value'))
    case 1 % White
        bgcolor = [1 1 1];
    case 2 % Grey
        bgcolor = [0.702 0.702 0.702];
    case 3 % Gray
        bgcolor = [0.5 0.5 0.5];
    case 4 % Black
        bgcolor = [0 0 0];
end

% Change colors
% set(handles.guifig, 'Color', bgcolor);
set(handles.display_brainaxes, 'Color', bgcolor);
set(handles.display_brainfig, 'Color', bgcolor);
set(handles.display_timecourseaxes, 'Color', bgcolor);
set(handles.display_timecoursefig, 'Color', bgcolor);
guidata(hObject, handles);
% objects = fieldnames(handles);
% excluded = {'display_brainaxes', 'display_brainfig',...
%     'act_v1', 'act_v2', 'act_v3', 'act_p1', 'act_p2', 'act_p3',...
%     'act_file', 'granger_results',...
%     'file_granger', 'dir_rois', 'file_activity', 'N_ROIs'};
% 
% for i = 1:length(objects)
%     obj = objects{i};
%     if(sum(obj == '_') > 0 && sum(strcmp(excluded, obj)) == 0 && isempty(strfind(obj, 'menu')))
%         set(handles.(obj), 'BackgroundColor', bgcolor);
% 
%         if(sum(bgcolor) < 1)
%             set(handles.(obj), 'ForegroundColor', [1 1 1]);
%         else
%             set(handles.(obj), 'ForegroundColor', [0 0 0]);
%         end % white or black text
%     end % if the handles field is an object
% end % for each handles field

plot_draw(handles);

function display_bg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function wave_auto_Callback(hObject, eventdata, handles)

%% Set the possible connections for the wave plotter
[i_snks, i_srcs] = find(tril(handles.foci,-1));
i_snks = [i_snks; i_srcs];
i_srcs = [i_srcs; i_snks];
N_pairs = length(i_snks);

pairlabels = cell(N_pairs, 1);
for i_pair = 1:N_pairs
    pairlabels{i_pair} = sprintf('%s -> %s',...
        handles.labels{i_srcs(i_pair)}, handles.labels{i_snks(i_pair)});
end

set(handles.wave_list, 'String', pairlabels);
set(handles.wave_list, 'Max', N_pairs);

folder = sprintf('%s/images/%s/%s_%s%s_waveplot', handles.dir,...
    datestr(now, 'yymmdd'), handles.study, handles.condition, handles.set);
if(~exist(folder, 'dir')); mkdir(folder); end

for i_pair = 1:N_pairs
    set(handles.wave_list, 'Value', i_pair);
    
    wave_draw_Callback(hObject, eventdata, handles);
    
    filename = sprintf('%s/%s-to-%s.png', folder,...
        handles.labels{i_srcs(i_pair)}, handles.labels{i_snks(i_pair)});

    saveas(figure(1), filename);
end

for i_pair = 1:(N_pairs/2)
    set(handles.wave_list, 'Value', [0 N_pairs/2] + i_pair);
    
    wave_draw_Callback(hObject, eventdata, handles);
    
    filename = sprintf('%s/%s-and-%s.png', folder,...
        handles.labels{i_srcs(i_pair)}, handles.labels{i_snks(i_pair)});

    saveas(figure(1), filename);
end

function wave_save_Callback(hObject, eventdata, handles) %#ok<*INUSL>

folder = sprintf('%s/images/%s', handles.dir, datestr(now, 'yymmdd'));
if(~exist(folder, 'dir'))
    mkdir(folder);
end
filename = sprintf('%s/%s.png', folder, plot_timecoursefig_filename(handles));

frame = getframe(handles.display_timecoursefig);
imwrite(frame.cdata, filename, 'png');

% filename = sprintf('%s.png', filename);
% saveas(handles.display_timecoursefig, filename);

function cause_op_general_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function cause_op_focus_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function cause_op_frames_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function rois_cortical_Callback(hObject, eventdata, handles)
plot_draw(handles);

function feat_circle_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function cause_op_pairings_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function feat_dataset_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function brain_shading_Callback(hObject, eventdata, handles)
plot_draw(handles);

function cause_op_node_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function display_size_x_Callback(hObject, eventdata, handles)
x = str2double(get(handles.display_size_x, 'String'));
y = str2double(get(handles.display_size_y, 'String'));
position = get(handles.display_brainfig, 'Position');
position(3) = x / 0.9;
position(4) = y / 0.9;
set(handles.display_brainfig, 'Position', position);

function display_size_x_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function display_size_y_Callback(hObject, eventdata, handles)
x = str2double(get(handles.display_size_x, 'String'));
y = str2double(get(handles.display_size_y, 'String'));
position = get(handles.display_brainfig, 'Position');
position(3) = x / 0.9;
position(4) = y / 0.9;
set(handles.display_brainfig, 'Position', position);

function display_size_y_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function brain_show_Callback(hObject, eventdata, handles)
plot_draw(handles);

function act_show_Callback(hObject, eventdata, handles)
plot_draw(handles);

function cause_show_Callback(hObject, eventdata, handles)
plot_draw(handles);

function node_scale_Callback(hObject, eventdata, handles)
plot_draw(handles);

function node_scale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function node_rel_Callback(hObject, eventdata, handles)

% Set the other radio button
set(handles.node_abs, 'Value', ~get(handles.node_rel, 'Value'));

% Save and draw
guidata(hObject, handles);
plot_draw(handles);

function node_abs_Callback(hObject, eventdata, handles)

% Set the other radio button
set(handles.node_rel, 'Value', ~get(handles.node_abs, 'Value'));

% Save and draw
guidata(hObject, handles);
plot_draw(handles);

function data_act_load_Callback(hObject, eventdata, handles)
plot_data_activity(handles);

function feat_display_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function frames_timestamp_Callback(hObject, eventdata, handles)
plot_draw(handles);

function cause_meanafterthresh_Callback(hObject, eventdata, handles)
plot_draw(handles);

function display_secsize_x_Callback(hObject, eventdata, handles)
x = str2double(get(handles.display_secsize_x, 'String'));
y = str2double(get(handles.display_secsize_y, 'String'));
position = get(handles.display_timecoursefig, 'Position');
position(3) = x / 0.9;
position(4) = y / 0.9;
set(handles.display_timecoursefig, 'Position', position);

function display_secsize_x_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function display_secsize_y_Callback(hObject, eventdata, handles)
x = str2double(get(handles.display_secsize_x, 'String'));
y = str2double(get(handles.display_secsize_y, 'String'));
position = get(handles.display_timecoursefig, 'Position');
position(3) = x / 0.9;
position(4) = y / 0.9;
set(handles.display_timecoursefig, 'Position', position);

function display_secsize_y_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function node_focusspec_Callback(hObject, eventdata, handles)
plot_rois_compose(handles);
plot_draw(handles);

function frames_timestamp_style_Callback(hObject, eventdata, handles)
plot_draw(handles);

function frames_timestamp_style_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cause_zegnero_Callback(hObject, eventdata, handles)
plot_draw(handles);

function act_movie_Callback(hObject, eventdata, handles)
% plot_act_movie(handles);
% edited for special actions

%% Only LL
set(handles.brain_lh_lat, 'Value', 1);
set(handles.brain_rh_lat, 'Value', 0);
set(handles.brain_lh_med, 'Value', 0);
set(handles.brain_rh_med, 'Value', 0);

% Inflated, Gryi/Sulci, No APARC
set(handles.brain_surface, 'Value', 1)
set(handles.brain_gyrisulci, 'Value', 1)
set(handles.brain_aparc, 'Value', 0)
plot_act_movie(handles);

% Pial, No Gryi/Sulci, No APARC
set(handles.brain_surface, 'Value', 2)
set(handles.brain_gyrisulci, 'Value', 0)
set(handles.brain_aparc, 'Value', 0)
plot_act_movie(handles);

% Inflated, No Gryi/Sulci, APARC
set(handles.brain_surface, 'Value', 1)
set(handles.brain_gyrisulci, 'Value', 0)
set(handles.brain_aparc, 'Value', 1)
plot_act_movie(handles);

%% All surfaces
set(handles.brain_lh_lat, 'Value', 1);
set(handles.brain_rh_lat, 'Value', 1);
set(handles.brain_lh_med, 'Value', 1);
set(handles.brain_rh_med, 'Value', 1);

% Inflated, Gryi/Sulci, No APARC
set(handles.brain_surface, 'Value', 1)
set(handles.brain_gyrisulci, 'Value', 1)
set(handles.brain_aparc, 'Value', 0)
plot_act_movie(handles);

function frames_orient_Callback(hObject, eventdata, handles)
plot_frames(handles);

function frames_orient_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function act_movie_email_Callback(hObject, eventdata, handles)

% Set mailto if not already set
if(~isfield(handles, 'mailto'))
    inputs = inputdlg({'Destination Email'},...
        'Configure Email Settings',...
        1, {[getenv('USER') '@nmr.mgh.harvard.edu']});
    handles.mailto = inputs{1};

    % update handles
    guidata(hObject, handles);
end

% Content

movfile = sprintf('%s/images/%s/actm_%s.zip', handles.dir,...
    datestr(now, 'yymmdd'), plot_image_filename(handles, 'act'));

if(exist(movfile, 'file'))
    % Compose Message
    message{1} = sprintf('Type: %s', 'Activation Movie' );
    message{2} = sprintf('Study: %s', handles.study);
    message{3} = sprintf('Condition: %s', handles.condition);
    message{4} = sprintf('Filename: %s', movfile);

    % Send the base_email
    sendmail(handles.mailto, 'Granger Movie', message, movfile);
else
    [sound fs] = wavread('functions/wav/difficult.wav');
    soundsc(sound, fs);
end

function frames_clusivity_Callback(hObject, eventdata, handles)
plot_frames(handles);

function frames_clusivity_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function act_colorbar_Callback(hObject, eventdata, handles)
plot_draw(handles);

function wave_iceberg_Callback(hObject, eventdata, handles)
plot_wave(handles);

function focus_smg_Callback(hObject, eventdata, handles)
plot_focus(hObject, handles);

function focus_mtg_Callback(hObject, eventdata, handles)
plot_focus(hObject, handles);

function focus_stg_Callback(hObject, eventdata, handles)
plot_focus(hObject, handles);

function data_regions_browse_Callback(hObject, eventdata, handles)

path = uigetdir(handles.dir_rois);

if(~isnumeric(path))
    % Set Data file
    handles.dir_rois = path;

    % Turn on the load button
    set(handles.data_granger_load, 'Enable', 'on');
    set(handles.data_granger_load, 'String', 'Load');
    
    % Update handles structure
    guidata(hObject, handles);
end

function wave_reflections_Callback(hObject, eventdata, handles)
plot_wave(handles);

function rois_labels_size_Callback(hObject, eventdata, handles)
plot_draw(handles);

function rois_labels_size_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rois_labels_color_Callback(hObject, eventdata, handles)
plot_draw(handles);

function rois_labels_color_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rois_aparc_color_Callback(hObject, eventdata, handles)
plot_draw(handles);

function base_special_Callback(hObject, eventdata, handles)
gpsp_special(handles);
% plot_all_gci(handles)
% plot_all_rois(handles)

function wave_legend_Callback(hObject, eventdata, handles)
plot_wave(handles);

function wave_legend_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cause_threshold_showp_Callback(hObject, eventdata, handles)
plot_draw(handles);

function cause_op_threshold_Callback(hObject, eventdata, handles)
plot_menus(hObject, handles)

function wave_nplots_Callback(hObject, eventdata, handles)
plot_wave(handles);

function wave_nplots_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function wave_scale_Callback(hObject, eventdata, handles)
plot_wave(handles);

function wave_scale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function wave_axislim_Callback(hObject, eventdata, handles)
plot_wave(handles);

function wave_axislim_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in data_granger2_load.
function data_granger2_load_Callback(hObject, eventdata, handles)
% hObject    handle to data_granger2_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in values_condition.
function values_condition_Callback(hObject, eventdata, handles)
% hObject    handle to values_condition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns values_condition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from values_condition


% --- Executes during object creation, after setting all properties.
function values_condition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to values_condition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in data_act2_load.
function data_act2_load_Callback(hObject, eventdata, handles)
% hObject    handle to data_act2_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
