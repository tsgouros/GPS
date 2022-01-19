function varargout = GPS_rois(varargin)
% GPS_ROIS MATLAB code for GPS_rois.fig
%      GPS_ROIS, by itself, creates a new GPS_ROIS or raises the existing
%      singleton*.
%
%      H = GPS_ROIS returns the handle to a new GPS_ROIS or the handle to
%      the existing singleton*.
%
%      GPS_ROIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GPS_ROIS.M with the given input arguments.
%
%      GPS_ROIS('Property','Value',...) creates a new GPS_ROIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GPS_rois_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GPS_rois_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GPS_rois

% Last Modified by GUIDE v2.5 15-Aug-2012 12:15:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GPS_rois_OpeningFcn, ...
                   'gui_OutputFcn',  @GPS_rois_OutputFcn, ...
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


% --- Executes just before GPS_rois is made visible.
function GPS_rois_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GPS_rois (see VARARGIN)

% Choose default command line output for GPS_rois
handles.output = hObject;

%% Set Environment

% Set the axes_brain to fill the right part of the screen
set(handles.axes_brain, 'Position', [300 20 800 600]);

% Banish unused menues
handles = rois_panels(handles.panels_data, handles);
handles = guidata(hObject);

% Set up auxiliary figure for saving data
handles.datafig = 675200;
figure(handles.datafig);

set(handles.datafig, 'Menubar', 'none');
set(handles.datafig, 'Toolbar', 'none');
set(handles.datafig, 'Name', 'GPS rois data figure <<Do not close>>');
set(handles.datafig, 'Numbertitle', 'off');
% title(gca, {'This figure contains data for GPS\_rois.', 'Do not close until you are done with GPS\_rois'});
axis(gca, 'off');
pos = get(handles.datafig, 'Position');
pos(2) = 10;
pos(4) = 10;

set(handles.datafig, 'Position', pos);
% text(handles.datafig, 0.5, 0.5, {'This figure contains data for GPS_rois.', '<b>Do not close until you are done with GPS_rois</b>'});
figure(handles.guifig);

axis(handles.axes_wave, 'off');
axis(handles.axes_histogram, 'off');

% Defaults
handles.name = 'state';
handles.dir = gps_presets('studydir');
handles.study = 'PTC3';
handles.subject = 'average';
handles.condition = 'HPword';
handles.set = '';
set(handles.quick_pauseautoredraw, 'Value', 1);

% Get a passed in GPS_vars structure
if(~isempty(varargin))
    state = varargin{1};
    if(isfield(state, 'dir')); handles.dir = state.datadir; end
    if(isfield(state, 'study')); handles.study = state.study; end
    if(isfield(state, 'subject')); handles.subject = state.subject; end
    if(isfield(state, 'condition')); handles.condition = state.condition; end
    if(isfield(state, 'subset')); handles.subset = state.subset; end
end

handles.savedir = [handles.dir '/parameters'];

%% Load studies and subjects

% Look through data directory and load entries that are studies
studies = dir(handles.savedir);
studies = {studies.name};
for i = length(studies):-1:1 % Weed out non-studies
    if(studies{i}(1) < 'A' || studies{i}(1) > 'Z')
        studies(i) = [];
    end
end
set(handles.data_study_list, 'String', studies);

% Pick the study
if(find(strcmp(studies, handles.study)))
    i_study = find(strcmp(studies, handles.study));
else
    i_study = 1;
end
set(handles.data_study_list, 'Value', i_study);

% Update handles structure
guidata(hObject, handles);

% Set the study
handles = rois_data_study_load(handles);

% UIWAIT makes GPS_rois wait for user response (see UIRESUME)
% uiwait(handles.guifig);


% --- Outputs from this function are returned to the command line.
function varargout = GPS_rois_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function brain_left_Callback(hObject, eventdata, handles)
set(handles.quick_left, 'Value', get(hObject, 'Value'));
handles = rois_draw(handles);

function brain_right_Callback(hObject, eventdata, handles)
set(handles.quick_right, 'Value', get(hObject, 'Value'));
handles = rois_draw(handles);

function brain_perspective_Callback(hObject, eventdata, handles)
handles = rois_draw(handles);

function brain_perspective_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function brain_surface_Callback(hObject, eventdata, handles)
handles = rois_draw(handles);

function brain_surface_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function brain_gyrisulci_Callback(hObject, eventdata, handles)
handles = rois_draw(handles);

function brain_fsregions_Callback(hObject, eventdata, handles)
handles = rois_draw(handles);

function brain_shadows_Callback(hObject, eventdata, handles)
handles = rois_draw(handles);

function panels_data_Callback(hObject, eventdata, handles)
handles = rois_panels(hObject, handles)

function panels_brain_Callback(hObject, eventdata, handles)
handles = rois_panels(hObject, handles)

function panels_centroids_Callback(hObject, eventdata, handles)
handles = rois_panels(hObject, handles)

function data_study_list_Callback(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
handles = rois_data_study_load(handles);

function data_study_list_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function data_subject_list_Callback(hObject, eventdata, handles)
handles = rois_data_subject_load(handles);

function data_subject_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function data_condition_list_Callback(hObject, eventdata, handles)
handles = rois_data_condition_load(handles);

function data_condition_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function data_set_list_Callback(hObject, eventdata, handles)
handles = rois_data_set_load(handles);

function data_set_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function quick_pauseautoredraw_Callback(hObject, eventdata, handles)
handles = rois_draw(handles);

function panels_metrics_Callback(hObject, eventdata, handles)
handles = rois_panels(hObject, handles)

function panels_regions_Callback(hObject, eventdata, handles)
set(handles.metrics_list, 'Value', 5);
handles = rois_metrics_settings_load(handles, 0);
handles = rois_panels(hObject, handles)

function panels_save_Callback(hObject, eventdata, handles)
handles = rois_panels(hObject, handles)

function data_mne_load_Callback(hObject, eventdata, handles)
handles = rois_data_measure_load(hObject, handles);

function data_mne_browse_Callback(hObject, eventdata, handles)
handles = rois_data_measure_browse(handles, 'mne');

function data_plv_load_Callback(hObject, eventdata, handles)
handles = rois_data_measure_load(hObject, handles);

function data_plv_browse_Callback(hObject, eventdata, handles)
handles = rois_data_measure_browse(handles, 'plv');

function data_custom_load_Callback(hObject, eventdata, handles)
handles = rois_data_measure_load(hObject, handles);

function data_custom_browse_Callback(hObject, eventdata, handles)
handles = rois_data_measure_browse(handles, 'custom');

function data_custom_text_Callback(hObject, eventdata, handles)
rois_data_measure_rename(handles, 'custom');

function data_custom_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function data_plv_text_Callback(hObject, eventdata, handles)
rois_data_measure_rename(handles, 'plv');

function data_plv_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function data_mne_text_Callback(hObject, eventdata, handles)
rois_data_measure_rename(handles, 'mne');

function data_mne_text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function data_oldregions_load_Callback(hObject, eventdata, handles)
handles = rois_data_measure_load(hObject, handles);

function data_oldregions_browse_Callback(hObject, eventdata, handles)
handles = rois_data_measure_browse(handles, 'oldregions');

function data_oldregions_text_Callback(hObject, eventdata, handles)
rois_data_measure_rename(handles, 'oldregions');

function data_oldregions_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function quick_left_Callback(hObject, eventdata, handles)
set(handles.brain_left, 'Value', get(hObject, 'Value'));
handles = rois_draw(handles);

function quick_right_Callback(hObject, eventdata, handles)
set(handles.brain_right, 'Value', get(hObject, 'Value'));
handles = rois_draw(handles);

function quick_mne_Callback(hObject, eventdata, handles)
metric = getappdata(handles.datafig, 'mne');
metric.vis.show = get(hObject, 'Value');
setappdata(handles.datafig, 'mne', metric);
set(handles.metrics_list, 'Value', 1);
handles = rois_metrics_settings_load(handles, 0)
handles = rois_metrics_settings_change(hObject, handles);

function quick_plv_Callback(hObject, eventdata, handles)
metric = getappdata(handles.datafig, 'plv');
metric.vis.show = get(hObject, 'Value');
setappdata(handles.datafig, 'plv', metric);
set(handles.metrics_list, 'Value', 2);
handles = rois_metrics_settings_load(handles, 0);
handles = rois_metrics_settings_change(hObject, handles);

function quick_custom_Callback(hObject, eventdata, handles)
metric = getappdata(handles.datafig, 'custom');
metric.vis.show = get(hObject, 'Value');
setappdata(handles.datafig, 'custom', metric);
set(handles.metrics_list, 'Value', 3);
handles = rois_metrics_settings_load(handles, 0)
handles = rois_metrics_settings_change(hObject, handles);

function quick_maxact_Callback(hObject, eventdata, handles)
metric = getappdata(handles.datafig, 'maxact');
metric.vis.show = get(hObject, 'Value');
setappdata(handles.datafig, 'maxact', metric);
set(handles.metrics_list, 'Value', 4);
handles = rois_metrics_settings_load(handles, 0)
handles = rois_metrics_settings_change(hObject, handles);

function quick_sim_Callback(hObject, eventdata, handles)
metric = getappdata(handles.datafig, 'sim');
metric.vis.show = get(hObject, 'Value');
setappdata(handles.datafig, 'sim', metric);
set(handles.metrics_list, 'Value', 5);
handles = rois_metrics_settings_load(handles, 0)
handles = rois_metrics_settings_change(hObject, handles);

function quick_centroids_Callback(hObject, eventdata, handles)
set(handles.centroids_show, 'Value', get(hObject, 'Value'));
handles = rois_draw(handles);

function quick_regions_Callback(hObject, eventdata, handles)
set(handles.regions_show, 'Value', get(hObject, 'Value'));
handles = rois_draw(handles);

function metrics_maxact_basis_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function metrics_maxact_basis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_maxact_basis2_on_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function metrics_maxact_basis2_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function metrics_maxact_basis2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_regional_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function metrics_standard_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function metrics_standard_mean_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function centroids_spatialex_Callback(hObject, eventdata, handles)
% Nothing

function centroids_spatialex_surface_Callback(hObject, eventdata, handles)
% Nothing

function centroids_spatialex_surface_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function centroids_spatialex_distance_Callback(hObject, eventdata, handles)
% Nothing

function centroids_spatialex_distance_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function centroids_find_Callback(hObject, eventdata, handles)
% if(~isappdata(handles.datafig, 'maxact'))
    set(handles.metrics_list, 'Value', 4);
    handles = rois_metrics_settings_load(handles, 0);
%     rois_metrics_settings_change(handles.metrics_list, handles);
% end
handles = rois_centroids_findmaximal(handles);

function centroids_percentile_Callback(hObject, eventdata, handles)
% Nothing

function centroids_percentile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_time_start_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function metrics_time_start_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_time_stop_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function metrics_time_stop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function centroids_show_Callback(hObject, eventdata, handles)
set(handles.quick_centroids, 'Value', get(hObject, 'Value'));
handles = rois_draw(handles);

function regions_list_Callback(hObject, eventdata, handles)
% centroid = get(hObject, 'Value');
% 
% % metric = getappdata(handles.datafig, 'sim');
% % metric.point = centroid;
% % setappdata(handles.datafig, 'sim', metric);
% 
% % guidata(hObject, handles)
% handles = guidata(hObject);
% % set(handles.metrics_sim_centroids, 'Value', centroid);
% % rois_metrics_compute(handles.metrics_sim_centroids, handles);
% if(get(handles.quick_sim, 'Value'))
%     set(handles.metrics_list, 'Value', 5);
%     rois_metrics_settings_load(handles, 0);
%     set(handles.metrics_sim_centroids, 'Value', centroid(1));
%     rois_metrics_settings_change(handles.metrics_sim_centroids, handles);
% else
%     rois_draw(handles);
% end
% % rois_draw(handles);

% centroid = get(hObject, 'Value');
% handles = guidata(hObject);
% if(get(handles.quick_sim, 'Value'))
%     set(handles.metrics_list, 'Value', 5);
%     rois_metrics_settings_load(handles, 0);
%     set(handles.metrics_sim_centroids, 'Value', centroid(1));
%     rois_metrics_settings_change(handles.metrics_sim_centroids, handles);
% else
%     rois_draw(handles);
% end

value = get(hObject, 'Value');
set(handles.metrics_list, 'Value', 5);
handles = rois_metrics_settings_load(handles, 0);
set(hObject, 'Value', value);
set(handles.metrics_sim_centroids, 'Value', value(1));
handles = rois_metrics_settings_change(hObject, handles);

guidata(hObject, handles);

function regions_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_list_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_load(handles);
handles = rois_metrics_settings_change(hObject, handles);
% handles = rois_panels(hObject, handles);

function metrics_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_vis_show_Callback(hObject, eventdata, handles)
% Get Type and Configure Metric
i_type = get(handles.metrics_list, 'Value');
types = {'mne', 'plv', 'custom', 'maxact', 'sim'};
type = types{i_type};
metric = getappdata(handles.datafig, type);
metric.vis.show = get(hObject, 'Value');
setappdata(handles.datafig, type, metric);

% Load Settings and alter the graph
handles = rois_metrics_settings_load(handles)
handles = rois_metrics_settings_change(hObject, handles);

metric = getappdata(handles.datafig, 'mne');
metric.vis.show = get(hObject, 'Value');
setappdata(handles.datafig, 'mne', metric);
handles = rois_metrics_settings_load(handles);
handles = rois_metrics_settings_change(hObject, handles);

function metrics_vis_color_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function metrics_vis_color_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_vis_t1_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function metrics_vis_t1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_vis_t2_Callback(hObject, eventdata, handles)
if(get(handles.metrics_list, 'Value') == 5)
    set(handles.regions_redun, 'String', get(hObject, 'String'));
end
handles = rois_metrics_settings_change(hObject, handles);

function metrics_vis_t2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_vis_t3_Callback(hObject, eventdata, handles)
if(get(handles.metrics_list, 'Value') == 5)
    set(handles.regions_sim, 'String', get(hObject, 'String'));
end
handles = rois_metrics_settings_change(hObject, handles);

function metrics_vis_t3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_vis_perc_Callback(hObject, eventdata, handles)
set(handles.metrics_vis_abs, 'Value', ~get(hObject, 'Value'));
handles = rois_metrics_settings_change(hObject, handles);

function metrics_vis_abs_Callback(hObject, eventdata, handles)
set(handles.metrics_vis_perc, 'Value', ~get(hObject, 'Value'));
handles = rois_metrics_settings_change(hObject, handles);

function metrics_time_comp_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function metrics_time_comp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_time_comp2_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function metrics_time_comp2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_standard_scope_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function metrics_standard_scope_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function save_labels_Callback(hObject, eventdata, handles)

rois_save_labels(handles);

function save_images_Callback(hObject, eventdata, handles)

% F = getframe(handles.axes_brain);



function save_auto_Callback(hObject, eventdata, handles)

folder = sprintf('%s/images/%s', handles.savedir, datestr(now, 'yymmdd'));
[~, ~, ~] = mkdir(folder);

% For each subject
subjects = get(handles.data_subject_list, 'String');
% for i_subject = 1:length(subjects)
for i_subject = 10:11
    % Set the subject
    subject = subjects{i_subject};
    set(handles.data_subject_list, 'Value', i_subject);
    data_subject_list_Callback(handles.data_subject_list, eventdata, handles);
    handles = guidata(handles.data_subject_list);
    
    % For each condition
    conditions = get(handles.data_condition_list, 'String');
% for i_condition = 11:12
    for i_condition = 1:length(conditions)
        % Set the condition
        condition = conditions{i_condition};
        set(handles.data_condition_list, 'Value', i_condition);
        data_condition_list_Callback(handles.data_condition_list, eventdata, handles);
        handles = guidata(handles.data_condition_list);
    
        % Load MNE
        data_mne_load_Callback(handles.data_mne_load, eventdata, handles);
        handles = guidata(handles.data_mne_load);

        % Take screenshot & save
%         files = getappdata(handles.datafig, 'files');
        frame = getframe(handles.axes_brain);
        filename = sprintf('%s/%s_%s_mne.png', folder, subject, condition);
        imwrite(frame.cdata, filename, 'png');
        
        filename = sprintf('%s/%s_%s_mnescale.png', folder, subject, condition);
        saveas(6753, filename, 'png');
%         clear files
    end % For each condition
end % For each subject

function save_images_dir_Callback(hObject, eventdata, handles)

files = getappdata(handles.datafig, 'files');

% Let user browse for a new directory
direc = uigetdir(files.imdir);

if(~isnumeric(direc))
    % Set Data file
    files.imdir = direc;

    % Update structure
    setappdata(handles.datafig, 'files', files);
end

function save_labels_dir_Callback(hObject, eventdata, handles)

files = getappdata(handles.datafig, 'files');

% Let user browse for a new directory
direc = uigetdir(files.roidir);

if(~isnumeric(direc))
    % Set Data file
    files.roidir = direc;

    % Update structure
    setappdata(handles.datafig, 'files', files);
end

function regions_make_Callback(hObject, eventdata, handles)
handles = rois_regions_make(handles);

function regions_show_Callback(hObject, eventdata, handles)
set(handles.quick_regions, 'Value', get(hObject, 'Value'));
handles = rois_draw(handles);

function regions_sim_Callback(hObject, eventdata, handles)
set(handles.metrics_vis_t3, 'String', get(hObject, 'String'));
handles = rois_metrics_settings_change(hObject, handles);

function regions_sim_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function regions_act_weight_Callback(hObject, eventdata, handles)
set(handles.metrics_sim_act_weight, 'String', get(hObject, 'String'));
handles = rois_metrics_settings_change(hObject, handles);

function regions_act_weight_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function regions_act_Callback(hObject, eventdata, handles)
set(handles.metrics_sim_act, 'Value', get(hObject, 'Value'));
handles = rois_metrics_settings_change(hObject, handles);

function regions_act_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function regions_redun_Callback(hObject, eventdata, handles)
set(handles.metrics_vis_t2, 'String', get(hObject, 'String'));
handles = rois_metrics_settings_change(hObject, handles);

function regions_redun_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function regions_cont_Callback(hObject, eventdata, handles)
% Nothing, just a parameter

function regions_cont_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function regions_make_all_Callback(hObject, eventdata, handles)
handles = rois_regions_make(handles, 'all');

function regions_spatial_Callback(hObject, eventdata, handles)
set(handles.metrics_sim_locality, 'String', get(hObject, 'String'));
handles = rois_metrics_settings_change(hObject, handles);

function regions_spatial_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_sim_centroids_Callback(hObject, eventdata, handles)
set(handles.regions_list, 'Value', get(hObject, 'Value'));
handles = rois_metrics_settings_change(hObject, handles);

function metrics_sim_centroids_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function centroids_cluster_Callback(hObject, eventdata, handles)
% hObject    handle to centroids_cluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in centroids_cluster_show.
function centroids_cluster_show_Callback(hObject, eventdata, handles)
% hObject    handle to centroids_cluster_show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of centroids_cluster_show



function centroids_cluster_n_Callback(hObject, eventdata, handles)
% hObject    handle to centroids_cluster_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of centroids_cluster_n as text
%        str2double(get(hObject,'String')) returns contents of centroids_cluster_n as a double


% --- Executes during object creation, after setting all properties.
function centroids_cluster_n_CreateFcn(hObject, eventdata, handles)
% hObject    handle to centroids_cluster_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function regions_rois_n_Callback(hObject, eventdata, handles)
% Nothing

function regions_rois_n_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function regions_poten_n_Callback(hObject, eventdata, handles)
% Nothing

function regions_poten_n_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function regions_imp_n_Callback(hObject, eventdata, handles)
% Nothing

function regions_imp_n_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function regions_diff_n_Callback(hObject, eventdata, handles)
% Nothing

function regions_diff_n_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_sim_norm_Callback(hObject, eventdata, handles)
handles = rois_metrics_settings_change(hObject, handles);

function metrics_sim_norm_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function centroids_show_text_Callback(hObject, eventdata, handles)
handles = rois_draw(handles);

function regions_show_text_Callback(hObject, eventdata, handles)
handles = rois_draw(handles);

function regions_remove_Callback(hObject, eventdata, handles)
handles = rois_regions_remove(handles);

function regions_remove_all_Callback(hObject, eventdata, handles)
handles = rois_regions_remove(handles, 'all');

function metrics_sim_act_weight_Callback(hObject, eventdata, handles)
set(handles.regions_act_weight, 'String', get(hObject, 'String'));
handles = rois_metrics_settings_change(hObject, handles);

function metrics_sim_act_weight_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_sim_act_Callback(hObject, eventdata, handles)
set(handles.regions_act, 'Value', get(hObject, 'Value'));
handles = rois_metrics_settings_change(hObject, handles);

function metrics_sim_act_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function metrics_sim_locality_Callback(hObject, eventdata, handles)
set(handles.regions_spatial, 'String', get(hObject, 'String'));
handles = rois_metrics_settings_change(hObject, handles);

function metrics_sim_locality_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function brain_rotatemovie_Callback(hObject, eventdata, handles)

folder = sprintf('%s/images/%s/%s_%s_%s%s_rotatingmovie',...
    handles.savedir, datestr(now, 'yymmdd'), handles.study,...
    handles.subject, handles.condition, handles.uset);
if(~exist(folder, 'dir')); mkdir(folder); end

% draw each angle persppective and save to a file
for angle = 0:10:360
    handles.angle = angle;
    
    handles = rois_draw(handles);
    
    frame = getframe(handles.axes_brain);
%     mov(i_frame) = frame;
    framename = sprintf('%s/d%03d.png', folder, angle);
    imwrite(frame.cdata, framename, 'png');
end

handles = rmfield(handles, 'angle');

handles = rois_draw(handles);

% Create AVI file
% fps = get(handles.frames_fps, 'String');
% movfile = sprintf('%s.avi',...
%     filename);
% movie2avi(mov, movfile, 'compression', 'None', 'fps', fps);
movfile = sprintf('%s.zip',...
    folder);
zip(movfile, [folder '/*.png']);
