function plot_data_granger(state)
% Loads a granger file
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Input: The Granger Processing Stream Plotting variables/handle
% Output: 
%
% Changelog:
% 2012-07-05 Created from granger_plot_load
% 2012-09-07 Last changed in GPS1.6
% 2012-10-11 Loosely adapted to GPS1.7
% 2013-07-09 GPS1.8 Asks for the file now and handles information better

hObject = state.data_granger_load;

% Notify the GUI that is it loading
set(state.data_granger_load, 'String', 'Loading');
guidata(hObject, state);
refresh(state.guifig);
pause(5);

%% Get Study & Condition
study = gpsp_parameter(state, state.study);
condition = gpsp_parameter(state, state.condition);
brain = gpsp_get('brain');

%% Get Results

% Ask for results file
[filename, path] = uigetfile(state.file_granger);
state.file_granger = [path filename];

datafile = load(state.file_granger);

granger.name = 'granger';
granger.results = datafile.granger_results;

if(isfield(datafile, 'total_control_granger'))
    set(state.cause_quantile, 'Enable', 'on');
    set(state.cause_signif, 'Enable', 'on');
    set(state.cause_threshold_showp, 'Enable', 'on');
    
    granger.nullhypotheses = datafile.total_control_granger;
    N_ROIs = size(granger.results, 1);
    [M1_ROIs, M2_ROIs, N_time, N_comp] = size(granger.nullhypotheses);
    if(N_ROIs ~= M1_ROIs || N_ROIs ~= M2_ROIs)
        granger.null_srcs = datafile.src_ROIs;
        if(isfield(datafile, 'snk_ROIs'))
            granger.null_snks = datafile.snk_ROIs;
        else
            granger.null_snks = datafile.sink_ROIs;
        end
        granger.null_selective = 1;
    else
        granger.null_selective = 0;
    end
    
    gpsp_set(granger);
    
    gpsp_data_significance(state);
else
    set(state.cause_signif, 'Enable', 'off');
    set(state.cause_quantile, 'Enable', 'off');
    set(state.cause_signif, 'Value', 0);
    set(state.cause_threshold_showp, 'Enable', 'off');
    set(state.cause_threshold_showp, 'Value', 0);
    
    gpsp_set(granger);
end

clear datafile;

guidata(hObject, state);
plot_frames(state);
state = guidata(hObject);

%% Get ROI information

guidata(hObject, state);
plot_data_rois(state);


end % function