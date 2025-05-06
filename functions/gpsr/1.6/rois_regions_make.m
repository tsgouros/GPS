function GPSR_vars = rois_regions_make(GPSR_vars, varargin)
% Makes ROIs based on similarity and other metrics
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI datafig
%
% Date Created: 2012.06.26
% Last Modified: 2012.06.27

%% Get settings from GUI

brain = getappdata(GPSR_vars.datafig, 'brain');
coords = brain.origcoords;
points = getappdata(GPSR_vars.datafig, 'points');
all_points = 1:length(points);
nonredun_points = all_points;

if(length(varargin) > 0)
    if(strcmp(varargin{1}, 'all'))
        selection = all_points;
    else
        selection = get(GPSR_vars.regions_list, 'Value');
    end
else
    selection = get(GPSR_vars.regions_list, 'Value');
end

% Set up log file
log_filename = '';

% Setup Similarity processing
set(GPSR_vars.metrics_list, 'Value', 5);
GPSR_vars = rois_metrics_settings_load(GPSR_vars, 0);
set(GPSR_vars.regions_list, 'Value', selection);

redundant_points = [];

% Weighting Parameters
% rois.thresh.sim     = str2double(get(GPSR_vars.regions_sim,        'String'));
% rois.thresh.redun   = str2double(get(GPSR_vars.regions_redun,      'String'));
rois.thresh.cont    = str2double(get(GPSR_vars.regions_cont,       'String'));
% rois.weight.spatial = str2double(get(GPSR_vars.regions_spatial,    'String'));
% rois.weight.act     = str2double(get(GPSR_vars.regions_act_weight, 'String'));
% rois.weight.actnum  =            get(GPSR_vars.regions_act,        'Value');

% rois.thresh.sim = -abs(rois.thresh.sim);
% rois.thresh.redun = -abs(rois.thresh.redun);

% Prepare output text file
files = getappdata(GPSR_vars.datafig, 'files');
filename = sprintf('%s/%s_%s%s_rois_%s.txt',...
    files.roidir, GPSR_vars.study, GPSR_vars.condition, GPSR_vars.uset,...
    datestr(now, 'yymmdd_hhMMss'));
fid = fopen(filename);

% While the selection list still has points
while(~isempty(selection))
    i_point = selection(1);
    point = points(i_point);
    selection(1) = [];
    fprintf('Processing %s\n', point.name);
    
    %% Compute ROI
    
    % Compute similarity
    set(GPSR_vars.metrics_sim_centroids, 'Value', i_point);
    GPSR_vars = rois_metrics_settings_change(GPSR_vars.metrics_sim_centroids, GPSR_vars);

    % Get similarity
%     simmetric = getappdata(GPSR_vars.datafig, 'sim');
%     if(simmetric.point == 1)
%         simmetric.point = i_point;
%         setappdata(GPSR_vars.datafig, 'sim', simmetric);
%         rois_metrics_compute(GPSR_vars.regions_make, GPSR_vars);
%         simmetric = getappdata(GPSR_vars.datafig, 'sim');
%     end
%     sim = simmetric.data.cort;
%     fprintf('\tsim:\tmean=%1.3f\tmin=%1.3f\tmax=%1.3f\n', mean(sim), min(sim), max(sim));
%     sim = sim * (1 - rois.weight.act - rois.weight.spatial);
%     
%     % Add activity?
%     if(rois.weight.act > 0)
%         switch rois.weight.actnum
%             case 1; act = getappdata(GPSR_vars.datafig, 'mne');
%             case 2; act = getappdata(GPSR_vars.datafig, 'plv');
%             case 3; act = getappdata(GPSR_vars.datafig, 'custom');
%             case 4; act = getappdata(GPSR_vars.datafig, 'maxact');
%         end
%         
%         act = act.data.cort;
%         act = act - act(point.index);
%         act = act / std(act);
%         fprintf('\tact:\tmean=%1.3f\tmin=%1.3f\tmax=%1.3f\n', mean(act), min(act), max(act));
%         sim = sim + act * rois.weight.act;
%     end
%     
%     % Add locality?
%     if(rois.weight.spatial > 0)
%         spatial = -distL2(coords(point.index, :), coords);
%         spatial = spatial - max(spatial);
%         spatial = spatial / std(spatial);
%         fprintf('\tspatial:\tmean=%1.3f min=%1.3f\tmax=%1.3f\n', mean(spatial), min(spatial), max(spatial));
%         sim = sim + spatial * rois.weight.spatial;
%     end

    simmetric = getappdata(GPSR_vars.datafig, 'sim');
    sim = simmetric.data.cort;
    
    rois.thresh.redun  = simmetric.data.v(2);
    rois.thresh.sim    = simmetric.data.v(3);
    rois.weight.local  = simmetric.sim.local_weight;
    rois.weight.act    = simmetric.sim.act_weight;
    rois.weight.actnum = simmetric.sim.act;
    
    % Threshold
%     fprintf('\tsim:\tmean=%1.3f\tmin=%1.3f\tmax=%1.3f\n', mean(sim), min(sim), max(sim))
    fprintf('\t%d total vertices\n', length(sim));
    redun = find(sim > rois.thresh.redun);
    simverts   = find(sim > rois.thresh.sim);
    fprintf('\t%d redundant vertices\n', length(redun));
    fprintf('\t%d similar vertices\n', length(simverts));
    if(length(simverts) == 0)
        keyboard
    end
    
    % Limit to the side of the brain the point is on
    if(point.hemi == 'L')
        simverts(simverts > brain.N_L) = [];
    else
        simverts(simverts <= brain.N_L) = [];
    end
    
    % Avoid already selected vertices?
    
    % Get continuity
    simverts = setdiff(simverts, point.index);
    simverts = [point.index; simverts];
    cont = rois_regions_continuous(coords(simverts, :), rois.thresh.cont, 1000);
    if(length(cont) == 1000)
        fprintf('\tToo many continous vertices found, truncated\n');
    end
    simverts = simverts(cont);
    fprintf('\t%d continuous vertices\n', length(simverts));
    
    % Mark redundant points for removal
    nonredun_search = nonredun_points(nonredun_points > i_point);
    [redun, redunI] = intersect([points(nonredun_search).index], redun, 'stable');
    redunI = nonredun_search(redunI);
    if(length(redunI) > 0)
        fprintf('\t% 3d redundant points:', length(redunI));
        for i = redunI
            fprintf(' %s', points(i).name);
        end
        fprintf('\n');
    end
    redundant_points = [redundant_points, redunI];
    nonredun_points = setdiff(nonredun_points, redunI);
    selection = setdiff(selection, redunI);
    
    % Save
    points(i_point).redun = redun;
    points(i_point).sim = sim;
    points(i_point).vertices = simverts;
    points(i_point).ROI = 1;
    points(i_point).imported = 0;
    points(i_point).thresh = rois.thresh;
    points(i_point).weight = rois.weight;
    
    fprintf('\tdone with %s\n', point.name);
    clear sim simverts
end

%% Update points
points(redundant_points) = [];
set(GPSR_vars.metrics_sim_centroids, 'Value', min(i_point, length(points)));

setappdata(GPSR_vars.datafig, 'points', points);
setappdata(GPSR_vars.datafig, 'rois_settings', rois);
GPSR_vars = rois_centroids_list(GPSR_vars)
GPSR_vars = guidata(GPSR_vars.regions_list);
GPSR_vars = rois_draw(GPSR_vars);

end % function


