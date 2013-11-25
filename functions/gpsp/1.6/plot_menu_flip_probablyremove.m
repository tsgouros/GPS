function granger_plot_load(GPSP_vars)
% Refreshes the graphics and checks the status of each GPS function
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream Plotting variables/handle
% Output: 
%
% Date Created: 2012.04.09 (as separate function)
% Last Modified: 2012.05.10

hObject = GPSP_vars.data_load;

set(GPSP_vars.data_load, 'String', 'Loading');
guidata(hObject, GPSP_vars);
refresh(GPSP_vars.figure1);

%% Get Study & Condition
study = data_load(GPSP_vars, GPSP_vars.study);
condition = data_load(GPSP_vars, GPSP_vars.condition);

%% Get Results

% datafile = load(handles.datafile, 'granger_results');
datafile = load(GPSP_vars.datafile);

GPSP_vars.granger_results = datafile.granger_results;
if(isfield(datafile, 'total_control_granger'))
    set(GPSP_vars.cause_quantile, 'Enable', 'on');
    set(GPSP_vars.cause_signif, 'Enable', 'on');
    
    % Compute alpha values
    if(isstruct(datafile.alpha_values))
        threshold = str2double(get(GPSP_vars.cause_quantile, 'String'));
        if(isempty(threshold))
            GPSP_vars.granger_results = datafile.alpha_values.p;
            threshold2 = str2double(get(GPSP_vars.cause_threshold, 'String'));
            alpha_values = ones(size(GPSP_vars.granger_results)) * threshold2;
        elseif(isfield(datafile.alpha_values, ['p' num2str(threshold*1000)]))
            alpha_values = datafile.alpha_values.(['p' num2str(threshold*1000)]);
        else
            alpha_values = quantile(datafile.total_control_granger, threshold, 4);
        end
    else
        alpha_values = datafile.alpha_values;
    end
    signif_conn = GPSP_vars.granger_results > alpha_values;
    
    GPSP_vars.signif_conn = signif_conn;
    GPSP_vars.alpha_values = alpha_values;
else
    set(GPSP_vars.cause_signif, 'Enable', 'off');
    set(GPSP_vars.cause_quantile, 'Enable', 'off');
    set(GPSP_vars.cause_signif, 'Value', 0);
end
    
    
%     threshold = str2double(get(handles.display_threshold, 'String'));
%     alpha_values = quantile(datafile.total_control_granger, threshold, 4);
%     signif_conn = granger_results > alpha_values;
%     
%     handles.signif_conn = signif_conn;
%     handles.alpha_values = alpha_values;
% else
%     handles.signif_conn = zeros(size(handles.granger_results));
%     handles.alpha_values = zeros(size(handles.granger_results));
% end

clear datafile;

%% Get ROI information

% Cut out the filenames and any excess numbering
areas = {};
area_counts = [];
stgloc = 0;

ROIdir = condition.granger.roidir;
ROIfiles = dir([ROIdir '/*.label']);
N_ROIs = length(ROIfiles);

labels = cell(N_ROIs, 1);
ROIhemi = zeros(N_ROIs, 1);
ROIcents = zeros(N_ROIs, 1);
ROIside = zeros(N_ROIs, 1);
ROIverts = cell(N_ROIs, 1);

for i_ROI = 1:N_ROIs
    %% Format Name
    filename = ROIfiles(i_ROI).name;
    dashes = strfind(filename, '-');
    area = filename(1:(dashes(2) - 1));
    
    switch area
        case 'L-Oper'
            area = 'L-ParsOper';
        case 'L-Tri'
            area = 'L-ParsTri';
        case 'L-Ling'
            area = 'L-ParaHip';
        case 'R-Oper'
            area = 'R-ParsOper';
        case 'R-Tri'
            area = 'R-ParsTri';
        case 'R-Ling'
            area = 'R-ParaHip';
        case 'L-STG'
            if(stgloc == 0); stgloc = i_ROI; end
    end
    
    %% Get area count
    % If the areas already exists
    i_area = find(strcmp(areas, area));
    if (isempty(i_area)) % Not found
        i_area = length(areas) + 1;
        area_counts(i_area) = 1;
        areas{i_area} = area;
    else
        area_counts(i_area) = area_counts(i_area) + 1;
    end % If the area already exists
    
    labels{i_ROI} = [area '_' num2str(area_counts(i_area))];
    
    % Which hemisphere is this ROI in?
    ROIhemi(i_ROI) = area(1) == 'L';
    
    %% Get Vertex info
    data = importdata([ROIdir '/' filename], ' ', 2);
    data = data.data;
    ROIverts{i_ROI} = data( :, 1);
    ROIcents(i_ROI) = data(10, 1);
    
    %% Get which side the vertex is on
    switch area(3:end)
        case {'STS', 'cMFG', 'AG', 'ITG', 'LOC', 'LOrb', 'MTG', 'Oper',...
                'ParsOper', 'ParsTri', 'Tri', 'OrbIFG', 'Calc',...
                'postCG', 'preCG', 'rMFG', 'SFG', 'SPC', 'STG', 'SMG',...
                'FPol', 'TPol', 'Aud', 'Insula'}
            ROIside(i_ROI) = 1;
        case {'ParaHip','Medial', 'caCing', 'Ent', 'CC', 'Isth', 'Cun', 'ParaC', 'MOrb', 'Fusi', 'pCing', 'preCun', 'raCing', 'Ling'}
            ROIside(i_ROI) = 0;
        otherwise
            ROIside(i_ROI) = 0;
    end
end

% Remove needless _1s if there are no _2s...
for i_label = 1:N_ROIs
    label = labels{i_label};
    dashes = strfind(label, '_');
    area = label(1:(dashes(1) - 1));

    i_area = find(strcmp(areas, area));

    if (area_counts(i_area) == 1)
        label = area;
    end

    labels{i_label} = label;
end % For each label

% Update focus list
set(GPSP_vars.focus_list, 'String', labels);
set(GPSP_vars.focus_list, 'Max', length(labels));
set(GPSP_vars.focus_list, 'Value', 1:length(labels));
% set(handles.focus_all, 'Value', 1);
% set(handles.focus_left, 'Value', 1);
% set(handles.focus_right, 'Value', 1);

GPSP_vars.labels = labels;
GPSP_vars.stgloc = stgloc;
GPSP_vars.ROIhemi = ROIhemi;
GPSP_vars.ROIside = ROIside;
GPSP_vars.ROIcents = ROIcents;
GPSP_vars.ROIverts = ROIverts;

%% Get Brain
GPSP_vars.subject = study.average_name;
dataset = data_loadroiset(GPSP_vars);
setappdata(GPSP_vars.figure1, 'brain', dataset);
% subject = data_load(handles, handles.subject);
% handles.brain = brain_load('Subject', subject);

%% Toggle Button Accessibility
set(GPSP_vars.data_load, 'Enable', 'off');
set(GPSP_vars.data_load, 'String', 'Loaded');

set(GPSP_vars.feat_brain, 'Enable', 'on');
set(GPSP_vars.feat_act, 'Enable', 'on');
set(GPSP_vars.feat_cause, 'Enable', 'on');
set(GPSP_vars.feat_node, 'Enable', 'on');

set(GPSP_vars.act_load, 'Enable', 'on');

%% Update the GUI (using the focus callback to also align focus)
% guidata(hObject, handles);
granger_plot_focus(GPSP_vars);

end % function