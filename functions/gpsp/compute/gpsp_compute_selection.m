function gpsp_compute_selection(hObject)
% Reads the region selection
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012-07-10 GPS1.6/plot_focus from GPS1.5/granger_plot_focus
% 2012-10-11 Loosely adapted to GPS1.7
% 2013-07-15 Remade GPS1.8/gpsp_compute_selection
% 2013-08-05 Tweaks to work with region_pairs menu instead of tcs_pairs


%% Load Data
state = gpsp_get;
granger = gpsp_get('granger');
rois = granger.rois;
N_ROIs = length(rois);
focus_list = get(state.regions_sel_list, 'Value');

lefties = zeros(N_ROIs, 1);
for i = 1:N_ROIs
    lefties(i) = rois{i}(1) == 'L';
end % for all rois

%% Narrow Focusing

buttons = {'regions_sel_all', 'regions_sel_left', 'regions_sel_right'};
button = get(hObject, 'tag');

if(sum(strcmp(button, buttons)))
    on_off = get(hObject, 'Value');

    switch button
        case 'regions_sel_all'
            narrow = ones(N_ROIs, 1);
        case 'regions_sel_left'
            narrow = lefties;
        case 'regions_sel_right'
            narrow = ~lefties;
    end
    
    if(on_off)
        focus_list = union(focus_list, find(narrow));
    else
        focus_list = intersect(focus_list, find(~narrow));
    end
    
    set(state.regions_sel_list, 'Value', focus_list);
end

%% Configure toggle buttons

foci = zeros(N_ROIs, 1);
foci(focus_list) = 1;

for i_button = 1:length(buttons)
    button = buttons{i_button};
    
    switch button
        case 'regions_sel_all'
            narrow = ones(N_ROIs, 1);
        case 'regions_sel_left'
            narrow = lefties;
        case 'regions_sel_right'
            narrow = ~lefties;
    end
    
    set(state.(button), 'Value', mean(foci(find(narrow))) == 1); %#ok<FNDSB>
end

%% Determining the Focus
if(get(state.regions_pairs_exclusive, 'Value'))
    foci = foci * foci';
else
    foci = ~(double(~foci) * double(~foci)');
end

% Interhemisphere
if(get(state.regions_pairs_interhemi, 'Value'))
    hemifoci = single(lefties);
    hemifoci = hemifoci * ~hemifoci';
    hemifoci = mod(hemifoci + hemifoci', 2);
    foci(~hemifoci) = 0;
end

% Remove inbound or outbound connections
not_focus_list = setdiff(1:N_ROIs, focus_list);
if(~get(state.regions_pairs_inbound, 'Value'))
    foci(:, not_focus_list) = 0;
end
if(~get(state.regions_pairs_outbound, 'Value'))
    foci(not_focus_list, :) = 0;
end

% For now exclude self
foci = foci .* ~eye(N_ROIs);

state.region_selection = foci;

%% Set the possible connections for the wave plotter
[i_snks, i_srcs] = find(foci);
N_pairs = length(i_snks);

state.region_pairs = zeros(N_pairs, 2);

pairlabels = cell(N_pairs, 1);
for i_pair = 1:N_pairs
    state.region_pairs(i_pair, 1) = i_srcs(i_pair);
    state.region_pairs(i_pair, 2) = i_snks(i_pair);
    pairlabels{i_pair} = sprintf('%s -> %s',...
        rois{i_srcs(i_pair)}, rois{i_snks(i_pair)});
end

set(state.regions_pairs, 'String', pairlabels);
set(state.regions_pairs, 'Max', N_pairs);
set(state.regions_pairs, 'Value', 1:N_pairs);
set(state.regions_pairs, 'ListboxTop', 1);

%% If automatically redrawing, draw the brain

gpsp_set(state);
guidata(hObject, state);

% Recompute granger parameters
gpsp_compute_granger;

end % Function