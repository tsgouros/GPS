function gpsp_feat(object, state)
% Arranges feature menus for GPS: Plotting
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Input: The object clicked and state (handles)
% Output: none, affects the GUI
%
% Changelog:
% 2012-08-07 Created as GPS1.6/plot_menus.m
% 2013-07-11 Overhauled as GPS1.8/gpsp_feat.m
% 2013-07-12 Finished Revision
% 2013-07-17 Exception for the surface panel height

%% Get Parameters

option_name = get(object, 'Tag');
enabling = ~strcmp(option_name, 'guifig') && get(object, 'Value');
parent = @(name) name(1:find(name == '_', 1, 'last') - 1);
feature = @(name) name(find(name == '_', 1, 'last') + 1:end);
panelof = @(name) [feature(name) '_panel'];

%% Set all menus aside and set all buttons to off

% Set option buttons off
% options = {'feat_dataset', 'feat_surf', 'feat_act', 'feat_regions',...
%     'feat_gsetup', 'feat_gvis', 'gsetup_method', 'gsetup_time',...
%     'gvis_arrows', 'gvis_bubbles', 'gvis_tcs', 'feat_display'};
options = {'feat_dataset', 'feat_surf', 'feat_act', 'feat_regions',...
    'feat_method', 'feat_time',...
    'feat_arrows', 'feat_bubbles', 'feat_tcs'};

for i = 1:length(options)
    button = state.(options{i});
    panel = state.(panelof(options{i}));
    
    set(button, 'Value', 0);
    pos = get(panel, 'Position');
    pos(1) = 10;
    pos(2) = 610;
    set(panel, 'Position', pos);
end

%% Retrieve the ones wanted

if(enabling)
    button = state.(option_name);
    panel = state.(panelof(option_name));
    
    set(button, 'Value', 1);
    pos = get(panel, 'Position');
    
    switch feature(option_name)
        case {'gsetup', 'gvis'}
            pos(2) = 290;
        otherwise
            pos(2) = 10;
    end
    
    set(panel, 'Position', pos);
end

% If it has a parent, make it active / up
if(~strcmp(parent(option_name), 'feat'))
    parent_ = ['feat_' parent(option_name)];
    button = state.(parent_);
    panel = state.(panelof(parent_));
    
    set(button, 'Value', 1);
    pos = get(panel, 'Position');
    pos(2) = 290;
    set(panel, 'Position', pos);
end

%% Update the GUI
guidata(object, state);

end