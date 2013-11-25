function gpsa_load_stage
% Loads stage functions for GPS: Analysis
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.09.21 - Created, based on gpsa_load_subject
% 2012.09.27 - Changed completely to reflect hardcoded stage functions and
% button presentation
% 2012.10.03 - Added gpsa_do callback and fleshed out tag
% 2012.10.10 - Added room for more functions

state = gpsa_get;

%% Determine Stage Components
% This is hard coded for now, soft code this in the future

function_list  = {};
function_tags = {};

switch state.stage
    case 'util'
        set(state.gui.function_title, 'String', 'Utilities');
        
        [function_tags, function_list] = gpsa_util_functions;
    case 'meg'
        set(state.gui.function_title, 'String', 'MEG Preprocessing');
        
        [function_tags, function_list] = gpsa_meg_functions;
        function_list{end + 1} = 'Batch';
        function_tags{end + 1} = 'batch';
    case 'mri'
        set(state.gui.function_title, 'String', 'MRI Processing');
        
        [function_tags, function_list] = gpsa_mri_functions;
        function_list{end + 1} = 'Batch';
        function_tags{end + 1} = 'batch';
    case 'mne'
        set(state.gui.function_title, 'String', 'MNE Analysis');
        
        [function_tags, function_list] = gpsa_mne_functions;
        function_list{end + 1} = 'Batch';
        function_tags{end + 1} = 'batch';
    case 'plv'
        set(state.gui.function_title, 'String', 'PLV Analysis');
        
        [function_tags, function_list] = gpsa_plv_functions;
        function_list{end + 1} = 'Batch';
        function_tags{end + 1} = 'batch';
    case 'granger'
        set(state.gui.function_title, 'String', 'Granger Analysis');
        
        [function_tags, function_list] = gpsa_granger_functions;
        function_list{end + 1} = 'Batch';
        function_tags{end + 1} = 'batch';
    otherwise
        set(state.gui.function_title, 'String', 'Functions');
end

%% Delete any old function components

for i = 1:12
    % Checkbox used for batch functions
    name = sprintf('f%d_check', i);
    if(isfield(state.gui, name) && ishandle(state.gui.(name)))
        delete(state.gui.(name))
    end
    
    % Main Function Button
    name = sprintf('f%d_button', i);
    if(isfield(state.gui, name) && ishandle(state.gui.(name)))
        delete(state.gui.(name))
    end
    
    % Axes indicating function progress
    name = sprintf('f%d_status', i);
    if(isfield(state.gui, name) && ishandle(state.gui.(name)))
        delete(state.gui.(name))
    end
end

%% Make new function components

h = state.gui.position.fig(4);

for i = 1:length(function_tags)
    % Checkbox used for batch functions
    if(~strcmp(state.stage, 'util'));
        name = sprintf('f%d_check', i);
        state.gui.(name) = uicontrol(state.gui.fig);
        set(state.gui.(name), 'Style', 'CheckBox');
        set(state.gui.(name), 'Units', 'pixels');
        set(state.gui.(name), 'Position', [190, h - 480 + 225 - 20 * i, 20, 20]);
        set(state.gui.(name), 'BackgroundColor', [0.8 0.8 0.8]);
        if(strcmp(function_tags{i}, 'batch'));
            set(state.gui.(name), 'Callback', 'gpsa_checkall f');
            set(state.gui.(name), 'Position', [190, h - 480 + 225 - 20 * i - 5, 20, 20]);
        end
    end % if stage is not util
    
    % Main Function Button
    name = sprintf('f%d_button', i);
    state.gui.(name) = uicontrol(state.gui.fig);
    set(state.gui.(name), 'Style', 'PushButton');
    set(state.gui.(name), 'Units', 'pixels');
    set(state.gui.(name), 'Position', [210, h - 480 + 225 - 20 * i, 120, 20]);
    set(state.gui.(name), 'BackgroundColor', [0.8 0.8 0.8]);
    set(state.gui.(name), 'String', function_list{i});
    fulltag = sprintf('gpsa_%s_%s', state.stage, function_tags{i});
    set(state.gui.(name), 'Tag', fulltag);
    set(state.gui.(name), 'Callback', ['gpsa_do ' fulltag]);
    if(strcmp(function_tags{i}, 'batch'));
        set(state.gui.(name), 'Position', [210, h - 480 + 225 - 20 * i - 5, 120, 20]);
        set(state.gui.(name), 'FontWeight', 'bold');
    end
    
    % Axes indicating function progress
    if(~strcmp(function_tags{i}, 'batch'));
        name = sprintf('f%d_status', i);
        state.gui.(name) = axes; %#ok<*LAXES>
        set(state.gui.(name), 'Units', 'pixels');
        set(state.gui.(name), 'Position', [331, h - 480 + 227 - 20 * i, 48, 18]);
        imshow(cat(3, zeros(10, 10), zeros(10, 10), zeros(10, 10)), 'Parent', state.gui.(name));
        axis(state.gui.(name), 'normal');
        axis(state.gui.(name), 'off');
    end % if not batch
end

%% Save the GUI state
gpsa_set(state);

%% Color the functions based on progress
gpsa_color_compute;

end % function