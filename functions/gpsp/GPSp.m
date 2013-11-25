function varargout = GPSp(varargin)
% GPSp MATLAB code for GPSp.fig
%      GPSp, by itself, creates a new GPSp or raises the existing
%      singleton*.
%
%      H = GPSp returns the handle to a new GPSp or the handle to
%      the existing singleton*.
%
%      GPSp('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GPS_PLOT.M with the given input arguments.
%
%      GPSp('Property','Value',...) creates a new GPSp or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GPS_plot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GPS_plot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 14-Aug-2013 06:57:48

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GPSp_OpeningFcn, ...
                   'gui_OutputFcn',  @GPSp_OutputFcn, ...
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

function wave_smooth_Callback(hObject, eventdata, handles)
plot_draw(handles);

function wave_smooth_CreateFcn(hObject, eventdata, handles)
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

pairs_chosen = get(handles.tcs_pairs, 'Value');
wavelabels = get(handles.tcs_pairs, 'String');
wavelabels = wavelabels(pairs_chosen);

for i = 1:length(wavelabels)
    message{4 + i} = sprintf('\t%s', wavelabels{i});
end
    
% Send the base_email
sendmail(handles.mailto, 'Granger Wave Image', message, filename)

%% Updated

function GPSp_OpeningFcn(hObject, eventdata, handles, varargin)
state = handles;
state.name = 'GPSp_state';
state.type = 'state';
gpsp_set(state);
gpsp_fig_setup;

function varargout = GPSp_OutputFcn(hObject, eventdata, handles) 
state = gpsp_get;
varargout{1} = state;

function feat_dataset_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function feat_surf_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function feat_act_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function feat_regions_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function feat_arrows_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function feat_bubbles_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function feat_tcs_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function feat_method_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function feat_time_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function feat_gsetup_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function feat_gvis_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function gsetup_method_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function gsetup_time_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function gsetup_sel_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function gvis_arrows_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function gvis_bubbles_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function gvis_tcs_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function data_study_Callback(hObject, eventdata, handles)
gpsp_load_study;

function data_study_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function data_condition_Callback(hObject, eventdata, handles)
gpsp_load_condition;

function data_condition_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function data_granger_load_Callback(hObject, eventdata, handles)
gpsp_load_granger;

function data_act_load_Callback(hObject, eventdata, handles)
gpsp_load_activity;

function data_regions_load_Callback(hObject, eventdata, handles)
gpsp_load_regions;

function data_condition2_Callback(hObject, eventdata, handles)
gpsp_load_condition2;

function data_condition2_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function data_granger2_load_Callback(hObject, eventdata, handles)
gpsp_load_granger2;

function data_act2_load_Callback(hObject, eventdata, handles)
gpsp_load_activity2;

function time_windowstart_Callback(hObject, eventdata, handles)
gpsp_compute_timing;

function time_windowstart_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function time_windowstop_Callback(hObject, eventdata, handles)
gpsp_compute_timing;

function time_windowstop_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function time_select_Callback(hObject, eventdata, handles)
gpsp_compute_timing;

function time_select_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function time_duration_Callback(hObject, eventdata, handles)
gpsp_compute_timing;

function time_duration_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function time_interval_Callback(hObject, eventdata, handles)
gpsp_compute_timing;

function time_interval_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function time_timestamp_style_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function time_anchor_Callback(hObject, eventdata, handles)
gpsp_compute_timing;

function time_anchor_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
gpsp_draw_buttonbg(hObject);

function time_bounds_Callback(hObject, eventdata, handles)
gpsp_compute_timing;

function time_bounds_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function time_timestamp_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function time_timestamp_style_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function regions_sel_all_Callback(hObject, eventdata, handles)
gpsp_compute_selection(hObject);

function regions_sel_left_Callback(hObject, eventdata, handles)
gpsp_compute_selection(hObject);

function regions_sel_right_Callback(hObject, eventdata, handles)
gpsp_compute_selection(hObject);

function regions_sel_list_Callback(hObject, eventdata, handles)
gpsp_compute_selection(hObject);

function regions_sel_list_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function regions_pairs_interhemi_Callback(hObject, eventdata, handles)
gpsp_compute_selection(hObject);

function regions_pairs_exclusive_Callback(hObject, eventdata, handles)
gpsp_compute_selection(hObject);

function regions_pairs_inbound_Callback(hObject, eventdata, handles)
gpsp_compute_selection(hObject);

function regions_pairs_outbound_Callback(hObject, eventdata, handles)
gpsp_compute_selection(hObject);

function regions_pairs_Callback(hObject, eventdata, handles)
gpsp_compute_granger;

function regions_pairs_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function regions_labels_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function regions_labels_size_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function regions_labels_size_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function regions_labels_color_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function regions_labels_color_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function method_countsum_Callback(hObject, eventdata, handles)
gpsp_compute_granger;

function method_countsum_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function method_thresh_gci_Callback(hObject, eventdata, handles)
set(handles.method_thresh_p, 'Value', ~get(handles.method_thresh_gci, 'Value'))
gpsp_compute_granger;

function method_thresh_p_Callback(hObject, eventdata, handles)
set(handles.method_thresh_gci, 'Value', ~get(handles.method_thresh_p, 'Value'))
gpsp_compute_granger;

function method_thresh_gci_val_Callback(hObject, eventdata, handles)
gpsp_compute_granger;

function method_thresh_gci_val_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function method_thresh_p_val_Callback(hObject, eventdata, handles)
gpsp_compute_granger;

function method_thresh_p_val_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function method_rethresh_abs_Callback(hObject, eventdata, handles)
gpsp_compute_granger;

function method_rethresh_abs_val_Callback(hObject, eventdata, handles)
gpsp_compute_granger;

function method_rethresh_abs_val_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function method_rethresh_p_Callback(hObject, eventdata, handles)
gpsp_compute_granger;

function method_rethresh_p_val_Callback(hObject, eventdata, handles)
gpsp_compute_granger;

function method_rethresh_p_val_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function method_time_Callback(hObject, eventdata, handles)
% Nothing

function method_time_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function method_condition_Callback(hObject, eventdata, handles)
gpsp_compute_granger;

function method_condition_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function bubbles_weights_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function bubbles_borders_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function bubbles_scale_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function bubbles_sink_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function bubbles_source_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function bubbles_focus_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function bubbles_overlay_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function bubbles_overlay_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function arrows_scale_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function arrows_scale_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function arrows_weights_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function arrows_borders_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function arrows_style_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function arrows_style_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function arrows_color_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function arrows_color_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function arrows_show_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function surf_cort_Callback(hObject, eventdata, handles)
gpsp_fig_surf_buttons(hObject);
gpsp_draw_surf;

function surf_circle_Callback(hObject, eventdata, handles)
gpsp_fig_surf_buttons(hObject);
gpsp_draw_surf;

function surf_none_Callback(hObject, eventdata, handles)
gpsp_fig_surf_buttons(hObject);
gpsp_draw_surf;

function surf_atlas_layer_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function surf_atlas_border_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function surf_atlas_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function regions_labels_show_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function surf_atlas_labels_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function surf_atlas_layer_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function surf_left_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function surf_right_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function surf_med_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function surf_lat_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function surf_cort_surf_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function surf_cort_sulci_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function surf_cort_shadows_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function surf_bg_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function surf_bg_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function surf_width_Callback(hObject, eventdata, handles)
delete(gpsp_fig_surf);
gpsp_draw_surf;

function surf_width_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function surf_height_Callback(hObject, eventdata, handles)
delete(gpsp_fig_surf);
gpsp_draw_surf;

function surf_height_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function surf_cort_surf_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function surf_atlas_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function tcs_show_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_tipsonly_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_fill_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_legend_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_legend_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function tcs_nplots_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_nplots_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function tcs_reflect_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_logscale_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_flipydir_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_pvals_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_sigspikes_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_yaxisright_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_ymax_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_ymax_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function tcs_ymin_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_ymin_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function tcs_bg_Callback(hObject, eventdata, handles)
gpsp_draw_tc;

function tcs_bg_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function tcs_width_Callback(hObject, eventdata, handles)
delete(gpsp_fig_tc);
gpsp_draw_tc;

function tcs_width_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function tcs_height_Callback(hObject, eventdata, handles)
delete(gpsp_fig_tc);
gpsp_draw_tc;

function tcs_height_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function tcs_font_Callback(hObject, eventdata, handles)
gpsp_draw_plot;

function tcs_font_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function screenshot_surf_Callback(hObject, eventdata, handles)
gpsp_fig_screenshot;

function screenshot_tcs_Callback(hObject, eventdata, handles)
gpsp_fig_screenshot(gpsp_fig_tc);

function feat_movies_Callback(hObject, eventdata, handles)
gpsp_feat(hObject, handles);

function act_show_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function act_time_start_Callback(hObject, eventdata, handles)
gpsp_compute_activity;

function act_time_start_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function act_time_stop_Callback(hObject, eventdata, handles)
gpsp_compute_activity;

function act_time_stop_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function act_p_Callback(hObject, eventdata, handles)
isSelected = get(handles.act_v, 'Value');
set(handles.act_p, 'Value', ~isSelected);

gpsp_compute_activity_colors;

function act_p1_Callback(hObject, eventdata, handles)

set(handles.act_p, 'Value', 1);
set(handles.act_v, 'Value', 0);

gpsp_compute_activity_colors;

function act_p1_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function act_p2_Callback(hObject, eventdata, handles)

set(handles.act_p, 'Value', 1);
set(handles.act_v, 'Value', 0);

gpsp_compute_activity_colors;

function act_p2_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function act_p3_Callback(hObject, eventdata, handles)

set(handles.act_p, 'Value', 1);
set(handles.act_v, 'Value', 0);

gpsp_compute_activity_colors;

function act_p3_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function act_v_Callback(hObject, eventdata, handles)

isSelected = get(handles.act_v, 'Value');
set(handles.act_p, 'Value', ~isSelected);

gpsp_compute_activity_colors;

function act_v1_Callback(hObject, eventdata, handles)

set(handles.act_p, 'Value', 0);
set(handles.act_v, 'Value', 1);

gpsp_compute_activity_colors;

function act_v1_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function act_v2_Callback(hObject, eventdata, handles)

set(handles.act_p, 'Value', 0);
set(handles.act_v, 'Value', 1);

gpsp_compute_activity_colors;

function act_v2_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function act_v3_Callback(hObject, eventdata, handles)

set(handles.act_p, 'Value', 0);
set(handles.act_v, 'Value', 1);

gpsp_compute_activity_colors;

function act_v3_CreateFcn(hObject, eventdata, handles)
gpsp_draw_buttonbg(hObject);

function act_colorbar_Callback(hObject, eventdata, handles)
gpsp_draw_surf;

function act_movie_Callback(hObject, eventdata, handles)
gpsp_draw_activity_movie;
