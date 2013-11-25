function gpsp_load_regions
% Loads ROI information from labels
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012-07-17 Created, based off of plot_data_granger to plot_data_rois
% 2012-10-11 Loosely adapted to GPS1.7
% 2013-07-09 GPS1.8 Changed how it loads the information
% 2013-07-15 Updated to new GUI, renamed to gpsp_load_regions;

state = gpsp_get;

set(state.data_regions_load, 'String', 'Loading');
set(state.data_regions_load, 'FontWeight', 'Normal');
set(state.data_regions_load, 'FontAngle', 'Italic');
guidata(state.data_regions_load, state);
refresh(state.guifig);
pause(0.1)

%% Get Study & Condition
brain = gpsp_get('brain');

[filename, path] = uigetfile(state.file_regions);
state.file_regions = [path filename];



set(state.data_regions_load, 'String', 'Loaded');
set(state.data_regions_load, 'FontWeight', 'Normal');
set(state.data_regions_load, 'FontAngle', 'Normal');
guidata(state.data_regions_load, state);

return

filename = gps_filename(state, study, condition, 'granger_rois_set_subject_mat');
if(exist(filename, 'file'))
    rois = load(filename);
else
    error('No ROIs file found, look again');
end

return
%% Get ROI information

aparc = load('aparc_labels.mat');

files = dir([GPSP_vars.dir_rois '/*.label']);
GPSP_vars.N_ROIs = length(files);
if(isempty(files))
    error('No ROIs found in %s\n', GPSP_vars.dir_rois);
end
GPSP_vars.stgloc = 0;

for i_ROI = 1:GPSP_vars.N_ROIs
    roi.filename = files(i_ROI).name;
    roi.hemi = roi.filename(1);
    dashes = find(roi.filename == '-' | roi.filename == '_');
    roi.area = roi.filename(dashes(1) + 1:dashes(2) - 1);
    
    % Change the area name if necessary
    switch roi.area
        case 'Oper'
            roi.area = 'ParsOper';
        case 'Tri'
            roi.area = 'ParsTri';
        case 'Ling'
            roi.area = 'ParaHip';
        case 'STG'
            if(roi.hemi == 'L' && GPSP_vars.stgloc == 0)
                GPSP_vars.stgloc = i_ROI;
            end
    end
    roi.aparcI = find(strcmp(aparc.aparc_labels(:, 2), roi.area));
    if(isempty(roi.aparcI))
        roi.aparcI = 1;
    elseif(length(roi.aparcI) > 1)
        roi.aparcI = roi.aparcI(1);
    end
    roi.aparcColor = brain.aparcCmap(roi.aparcI, :);
    
    % Determine the Side
    switch roi.area
        case {'STS', 'cMFG', 'AG', 'ITG', 'LOC', 'LOrb', 'MTG', 'Oper',...
                'ParsOper', 'ParsTri', 'Tri', 'OrbIFG', 'Calc',...
                'postCG', 'preCG', 'rMFG', 'SFG', 'SPC', 'STG', 'SMG',...
                'FPol', 'TPol', 'Aud', 'Insula', 'ParsOrb'}
            roi.side = 'L';
        case {'ParaHip','Medial', 'caCing', 'Ent', 'CC', 'Isth', 'Cun',...
                'ParaC', 'MOrb', 'Fusi', 'pCing', 'preCun', 'raCing', 'Ling'}
            roi.side = 'M';
        otherwise
            roi.side = 'L';
    end
    
    
    %% Get Vertex info
    
    data = importdata([GPSP_vars.dir_rois '/' roi.filename], ' ', 2);
    
    if(strfind(data.textdata{1}, 'GPS_rois.m'))
        data = data.data;
        roi.vertices = data(:, 1) + 1;
        roi.centroid = data(1, 1) + 1;
        if(roi.hemi == 'R');
            roi.centroid = roi.centroid + brain.N_L;
        end
    else % ROI Analyzer
        data = data.data;
        roi.vertices = data(:, 1) + 1;
        roi.centroid = data(1, 5);
    end
    
    if(roi.hemi == 'R');
        roi.vertices = roi.vertices + brain.N_L;
    end
    
    if(sum(roi.vertices == roi.centroid) == 0)
        fprintf('centroid vertex not in vertices list\n');
    end
    
%         chosen = min(size(data, 1), 10);
%         rois.centroid = data(chosen, 1);
    rois(i_ROI) = roi;
end % For each ROI

% Go back over the list and figure out the numbers in region and name
for i_ROI = 1:GPSP_vars.N_ROIs
    rois(i_ROI).numInRegion = sum(...
        strcmp({rois(1:i_ROI).hemi}, rois(i_ROI).hemi) &...
        strcmp({rois(1:i_ROI).area}, rois(i_ROI).area));
    rois(i_ROI).onlyInRegion = sum(...
        strcmp({rois.hemi}, rois(i_ROI).hemi) &...
        strcmp({rois.area}, rois(i_ROI).area)) == 1;
    
    if(rois(i_ROI).onlyInRegion)
        rois(i_ROI).uNumInRegion = '';
    else
        rois(i_ROI).uNumInRegion = sprintf('_%d', rois(i_ROI).numInRegion);
    end
    
    % Name
    rois(i_ROI).name = sprintf('%s-%s%s',...
        rois(i_ROI).hemi, rois(i_ROI).area, rois(i_ROI).uNumInRegion);
    
    % Add here an automated way to point out directions ie posterior,
    % anterior, central...
end % for each ROI

gpsp_set(rois, 'rois');

% Update focus list
set(GPSP_vars.focus_list, 'String', {rois.name});
set(GPSP_vars.focus_list, 'Max', GPSP_vars.N_ROIs);
set(GPSP_vars.focus_list, 'Value', 1:GPSP_vars.N_ROIs);

guidata(GPSP_vars.data_granger_load, GPSP_vars);

%% Update the GUI (using the focus callback to also align focus)
set(GPSP_vars.data_granger_load, 'String', 'Loaded');

plot_focus(GPSP_vars);

end % function