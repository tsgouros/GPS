function rois_centroids_findmaximal(GPSR_vars)
% Finds the top percentile of points for the maximal activity map
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI
%
% Based on pick_ROI_centroids last edited 2012.06.11
% Date Created: 2012.06.21
% Last Modified: 2012.06.25
% 2013.07.02 - Added warning dialog when trying to load maximal activity
% but it isn't ready yet

%% Get Metrics

% Activity
metric = getappdata(GPSR_vars.datafig, 'maxact');

if(~isfield(metric, 'data'))
    warndlg({'Unable to process.', 'Load the maximal activity data under metrics.'});
    return
end

data = metric.data.decVerts;
N = length(data);

clear measures;

% Coordinates
brain = getappdata(GPSR_vars.datafig, 'brain');

switch get(GPSR_vars.centroids_spatialex_surface, 'Value')
    case 1 % Inflated
        coords = brain.infcoords;
    case 2 % Pial
        coords = brain.pialcoords;
    case 3 % White Matter
        coords = brain.origcoords;
end
coords = coords(brain.decIndices, :);

% Spatial Exclusion
dist_thresh = str2double(get(GPSR_vars.centroids_spatialex_distance, 'String'));
useDistThresh = get(GPSR_vars.centroids_spatialex, 'Value');

% Percentile
percentile = str2double(get(GPSR_vars.centroids_percentile, 'String')) / 100;

%% Compute the Maximal centroids

[~, data_sortedI] = sortrows(data); % Formerlly called be ndata
data_sortedI = flipud(data_sortedI); % Descending order not ascending
centroids_originalindices = data_sortedI(1); % Indices of the chosen elements of C out of B, we know the first is in here
N_C = 1;
        points(N_C).dist = NaN;
N_potential_C = floor(N * (1 - percentile));

for i_Bsorted = 2:N_potential_C % For each element in B, ordered by PLV activity
    distances = distL2(coords(data_sortedI(i_Bsorted), :),...
                       coords(centroids_originalindices, :));
    
    if (~useDistThresh || mean(distances > dist_thresh) == 1)
        N_C = N_C + 1;
        points(N_C).dist = min(distances);
        centroids_originalindices(N_C) = data_sortedI(i_Bsorted);
    end
end % for i_Bsorted

%% Save the points

% points = getappdata(GPSR_vars.datafig, 'points');
% points = []; % remove this later
% Screen out already included vertices
% if(~isempty(points))
%     oldindices = [points.decIndex];
%     centroids_originalindices = setdiff(centroids_originalindices, oldindices);
%     N_C = length(centroids_originalindices);
% end

% Add new points
for i = 1 : N_C
% for i = length(points) + 1 : N_C
    decIndex = centroids_originalindices(i);
    index = brain.decIndices(decIndex);
    points(i).ROI = 0;
    points(i).imported = 0;
    points(i).decIndex = decIndex;
    points(i).index = index;
    points(i).maxact = data(decIndex);
    points(i).coords = brain.origcoords(index, :);

    % Naming
    points(i).aparcI = brain.aparcI(index);
    points(i).aparc = brain.aparcShort{points(i).aparcI};
    if(index <= brain.N_L); points(i).hemi = 'L';
    else                    points(i).hemi = 'R'; end
    points(i).numInRegion = sum(...
        strcmp({points.aparc}, points(i).aparc) &...
        strcmp({points.hemi}, points(i).hemi));
    points(i).name = sprintf('%s_%s_%d',...
        points(i).hemi, points(i).aparc, points(i).numInRegion);
    points(i).number = (points(i).hemi == 'R') * 10000 + points(i).aparcI * 100 + points(i).numInRegion;
    
    % Medial or Lateral?
    switch points(i).aparc
        case {'STS', 'cMFG', 'AG', 'ITG', 'LOC', 'LOrb', 'MTG', 'Oper',...
                'ParsOper', 'ParsTri', 'Tri', 'OrbIFG', 'Calc',...
                'postCG', 'preCG', 'rMFG', 'SFG', 'SPC', 'STG', 'SMG',...
                'FPol', 'TPol', 'Aud', 'Insula', 'ParsOrb'}
            points(i).side = 'L';
        case {'ParaHip','Medial', 'caCing', 'Ent', 'CC', 'Isth', 'Cun',...
                'ParaC', 'MOrb', 'Fusi', 'pCing', 'preCun', 'raCing', 'Ling'}
            points(i).side = 'M';
        otherwise
            points(i).side = 'M';
    end
end

% Save to data fig
setappdata(GPSR_vars.datafig, 'points', points);

%% Update GUI buttons

% Unlock some buttons
set(GPSR_vars.quick_centroids, 'Enable', 'on');
set(GPSR_vars.centroids_show, 'Enable', 'on');

% Update the GUI
guidata(GPSR_vars.centroids_find, GPSR_vars);
rois_centroids_list(GPSR_vars);
GPSR_vars = guidata(GPSR_vars.centroids_find);
rois_draw(GPSR_vars);
% rois_draw_thresh(GPSR_vars.brain_maxact_color, GPSR_vars);
            
end % function