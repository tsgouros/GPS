function gpsp_load_granger
% Loads a granger file
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012-07-05 Created from granger_plot_load to GPS1.6/plot_data_granger
% 2012-09-07 Last changed in GPS1.6
% 2012-10-11 Loosely adapted to GPS1.7
% 2013-07-09 GPS1.8 Asks for the file now and handles information better
% 2013-07-15 Overhauling for the new GUI
% 2013-08-06 Changes the method conditions

state = gpsp_get;

% Notify the GUI that is it loading
set(state.data_granger_load, 'String', 'Loading');
set(state.data_granger_load, 'FontWeight', 'Normal');
set(state.data_granger_load, 'FontAngle', 'Italic');
guidata(state.data_granger_load, state);
refresh(state.guifig);
pause(0.1);

%% Get Results

% Ask for results file
[filename, path] = uigetfile(state.file_granger);

if(isnumeric(filename) && filename == 0)
    fprintf('Granger Loading Aborted\n\n');
    return
end

state.file_granger = [path filename];
datafile = load(state.file_granger);

if(isfield(datafile, 'p_values'))
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

% Find the STG location to align the circle to the top
state.stg_loc = find(strcmp(granger.rois, 'L-STG_1'));
if(isempty(state.stg_loc))
    state.stg_loc = find(strcmp(granger.rois, 'L_STG_1')); end
if(isempty(state.stg_loc))
    state.stg_loc = find(strcmp(granger.rois, 'L-STG')); end
if(isempty(state.stg_loc))
    state.stg_loc = 1; end

% Update region selection list
set(state.regions_sel_list, 'String', granger.rois);
set(state.regions_sel_list, 'Max', length(granger.rois));
set(state.regions_sel_list, 'Value', 1:length(granger.rois));

% Find which side a region is on
granger.rois_side = '';
granger.rois_hemi = '';
for i_roi = 1:length(granger.rois)
    granger.rois_hemi(i_roi) = granger.rois{i_roi}(1);
    
    area_name = granger.rois{i_roi};
    i_hyphen = find(area_name ==  '-');
    if(~isempty(i_hyphen)); area_name = area_name(i_hyphen + 1:end); end
    i_underscore = find(area_name ==  '_');
    if(~isempty(i_underscore)); area_name = area_name(1: i_underscore - 1); end
    
    switch area_name
        case {'PCN', 'LG', 'TOF', 'pTF', 'pCG', 'SMA', 'preSMA',...
                'SCC', 'aCC', 'pPH', 'None', 'FMC', 'aTF', 'aPH',...
                'aCG', 'midCG',... Now for Desikan:
                'ParaC', 'preCun', 'Cun', 'Calc', 'ParaHip', 'Fusi',...
                'Medial', 'Ent', 'Isth', 'pCing', 'caCing',...
                'raCing', 'MOrb', 'CC'}
            granger.rois_side(i_roi) = 'M'; % Medial
        case {'FP', 'SFg', 'aMFg', 'pMFg', 'adPMC', 'mdPMC',...
                'pdPMC', 'dMC', 'dSC', 'SPL', 'AG', 'OC', 'MTO',...
                'ITO', 'pITg', 'aITg', 'aINS', 'pINS', 'pSTg',...
                'aSTg', 'asSTs', 'pdSTs', 'avSTs', 'pvSTs', 'pMTg',...
                'aMTg', 'TP', 'vPMC', 'vMC', 'vSC', 'aSMg', 'pSMg',...
                'adSTs', 'H', 'PP', 'midPMC', 'midMC', 'pIFs',...
                'aIFs', 'dIFt', 'vIFt', 'FOC', 'PT', 'PO', 'pCO',...
                'aCO', 'vIFo', 'dIFo', 'aFO', 'pFO',... Desikan:
                'LOC', 'ITG', 'MTG', 'STG', 'TPol', 'Aud', 'Insula',...
                'LOrb', 'ParsOrb', 'ParsTri', 'ParsOper', 'FPol',...
                'rMFG', 'SFG', 'cMFG', 'preCG', 'postCG', 'SMG',...
                'SPC', 'STS'}
            granger.rois_side(i_roi) = 'L'; % Lateral
        otherwise
            granger.rois_side(i_roi) = 'M'; % Medial
    end % Find out whether a region is on the left or right
end % for all regions

%% Save 

% Save the structures
granger.name = 'granger';
gpsp_set(granger);
gpsp_set(state);

% Mark it as loaded in the GUI
set(state.data_granger_load, 'String', 'Loaded');
set(state.data_granger_load, 'FontWeight', 'Normal');
set(state.data_granger_load, 'FontAngle', 'Normal');
set(state.method_condition, 'String', state.condition);
set(state.method_condition, 'Value', 1);
guidata(state.data_granger_load, state);

% Compute the region selection list
gpsp_compute_selection(state.data_granger_load)

end % function