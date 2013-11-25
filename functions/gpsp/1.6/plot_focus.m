function plot_focus(GPSP_vars, varargin)
% Configures the focusing list in the granger plotting GUI
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream Plotting variables/handle, and
% optionally the object handles calling this (for narrow focusing)
% Output: 
%
% Date Created: 2012.07.10 from granger_plot_focus
% Last Modified: 2012.07.10
% 2012.10.11 - Loosely adapted to GPS1.7

if(nargin == 2)
    hObject = GPSP_vars;
    GPSP_vars = varargin{1};
else
    hObject = GPSP_vars.focus_list;
end

%% Load Data
rois = gpsp_get('rois');
N_ROIs = length(rois);
focus_list = get(GPSP_vars.focus_list, 'Value');

%% Narrow Focusing

buttons = {'focus_all', 'focus_left', 'focus_right',...
        'focus_stg', 'focus_mtg', 'focus_smg'};
button = get(hObject, 'tag');

if(sum(strcmp(button, buttons)))
    on_off = get(hObject, 'Value');

    switch button
        case 'focus_all'
            narrow = 1:N_ROIs;
        case 'focus_left'
            narrow = strcmp({rois.hemi}, 'L');
        case 'focus_right'
            narrow = strcmp({rois.hemi}, 'R');
        case 'focus_stg'
            narrow = strcmp({rois.area}, 'STG');
            narrow = strcmp({rois.hemi}, 'L') & narrow;
        case 'focus_mtg'
            narrow = strcmp({rois.area}, 'MTG');
            narrow = strcmp({rois.hemi}, 'L') & narrow;
        case 'focus_smg'
            narrow = strcmp({rois.area}, 'SMG');
            narrow = strcmp({rois.hemi}, 'L') & narrow;
    end
    
    if(on_off)
        focus_list = union(focus_list, find(narrow));
    else
        focus_list = intersect(focus_list, find(~narrow));
    end
    
    set(GPSP_vars.focus_list, 'Value', focus_list);
end

%% Configure toggle buttons

foci = zeros(N_ROIs, 1);
foci(focus_list) = 1;

for i_button = 1:length(buttons)
    button = buttons{i_button};
    
    switch button
        case 'focus_all'
            narrow = 1:N_ROIs;
        case 'focus_left'
            narrow = strcmp({rois.hemi}, 'L');
        case 'focus_right'
            narrow = strcmp({rois.hemi}, 'R');
        case 'focus_stg'
            narrow = strcmp({rois.area}, 'STG');
            narrow = strcmp({rois.hemi}, 'L') & narrow;
        case 'focus_mtg'
            narrow = strcmp({rois.area}, 'MTG');
            narrow = strcmp({rois.hemi}, 'L') & narrow;
        case 'focus_smg'
            narrow = strcmp({rois.area}, 'SMG');
            narrow = strcmp({rois.hemi}, 'L') & narrow;
    end
    
    set(GPSP_vars.(button), 'Value', mean(foci(narrow)) == 1);
end

%% Determining the Focus
if(get(GPSP_vars.focus_exclusive, 'Value'))
    foci = foci * foci';
else
    foci = ~(double(~foci) * double(~foci)');
end

% Interhemisphere
if(get(GPSP_vars.focus_interhemi, 'Value'))
    hemifoci = single(strcmp({rois.hemi}', 'L'));
    hemifoci = hemifoci * ~hemifoci';
    hemifoci = mod(hemifoci + hemifoci', 2);
    foci(~hemifoci) = 0;
end

% For now exclude self
% foci = foci .* ~eye(N_ROIs);

GPSP_vars.foci = foci;

%% Set the possible connections for the wave plotter
[i_snks, i_srcs] = find(foci);
N_pairs = length(i_snks);

pairlabels = cell(N_pairs, 1);
for i_pair = 1:N_pairs
    pairlabels{i_pair} = sprintf('%s -> %s',...
        rois(i_srcs(i_pair)).name, rois(i_snks(i_pair)).name);
end

set(GPSP_vars.wave_list, 'String', pairlabels);
set(GPSP_vars.wave_list, 'Max', N_pairs);
set(GPSP_vars.wave_list, 'Value', 1);
set(GPSP_vars.wave_list, 'ListboxTop', 1);

%% If automatically redrawing, draw the brain

guidata(hObject, GPSP_vars);

plot_draw(GPSP_vars);

end % Function