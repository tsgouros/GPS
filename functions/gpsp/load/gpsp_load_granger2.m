function gpsp_load_granger2
% Loads a granger file
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-08-06 Created from GPS1.8/gpsp_load_granger.m
% 2013-08-12 Removed union contrast, doesn't make much sense

state = gpsp_get;

% Notify the GUI that is it loading
set(state.data_granger2_load, 'String', 'Loading');
set(state.data_granger2_load, 'FontWeight', 'Normal');
set(state.data_granger2_load, 'FontAngle', 'Italic');
guidata(state.data_granger2_load, state);
refresh(state.guifig);
pause(0.1);

%% Get Results

% Ask for results file
[filename, path] = uigetfile(state.file_granger2);

if(isnumeric(filename) && filename == 0)
    fprintf('Granger Loading Aborted\n\n');
    return
end

state.file_granger2 = [path filename];
datafile = load(state.file_granger2);
granger1 = gpsp_get('granger');

if(isfield(datafile, 'p_values') && isfield(granger1, 'p_values'))
    granger = datafile;
    set(state.method_thresh_p, 'Enable', 'on')
    set(state.method_thresh_p_val, 'Enable', 'on')
    set(state.tcs_pvals, 'Enable', 'on')
else
    granger.results = datafile.granger_results;
    granger.rois = datafile.rois;
    set(state.method_thresh_gci, 'Value', 1)
    set(state.method_thresh_p, 'Value', 0)
    set(state.method_thresh_p, 'Enable', 'off')
    set(state.method_thresh_p_val, 'Enable', 'off')
    set(state.tcs_pvals, 'Value', 0)
    set(state.tcs_pvals, 'Enable', 'off')
end

%% Simple ROI functions

% Convert complex rois structure to a simple one (so sad!)
if(isstruct(granger.rois))
    granger.rois = {granger.rois.name};
end

% Change second character to - instead of _ for formatting reasons
for i_roi = 1:length(granger.rois)
    granger.rois{i_roi}(2) = '-';
end

%% Save 

% Save the structures
granger.name = 'granger2';
gpsp_set(granger);
gpsp_set(state);

% Mark it as loaded in the GUI
set(state.data_granger2_load, 'String', 'Loaded');
set(state.data_granger2_load, 'FontWeight', 'Normal');
set(state.data_granger2_load, 'FontAngle', 'Normal');

% Get method list
methods = {state.condition, state.condition2};
% methods{3} = sprintf('%s and %s', state.condition, state.condition2);
methods{3} = sprintf('%s - %s', state.condition, state.condition2); 
methods{4} = sprintf('%2$s - %1$s', state.condition, state.condition2); 
set(state.method_condition, 'String', methods);
guidata(state.data_granger2_load, state);

end % function