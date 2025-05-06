function gpsa_settings
% Used to edit settings of the GUI
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.04.05 - Finally created in GPS1.8
% 2013.05.15 - Changed subsubset to subset
% 2013.06.18 - Changed USERNAME to USER environmental lookup and simplified
%                function calls.

state = gpsa_get;

%% Setup settings editing GUI

% Get the position of the monitor
settings_state.gui.position.screen = get(0, 'ScreenSize');

% Start the figure
settings_state.gui.fig = 6754101;
figure(settings_state.gui.fig)

% Initialize the GUI figure
w = 160; % Width of the GUI
w_offset = state.gui.position.fig(1) + state.gui.position.fig(3) / 2 - w / 2;
h = 310; % Height of the GUI
h_offset = state.gui.position.fig(2) + state.gui.position.fig(4) / 2 - h / 2;
settings_state.gui.position.fig = [w_offset, h_offset, w, h];

clf(settings_state.gui.fig)
set(settings_state.gui.fig, 'Visible', 'on', 'NumberTitle', 'off',...
    'MenuBar', 'none', 'ToolBar', 'none', 'Color', state.gui.bgcolor,...
    'Units', 'pixels', 'Position', settings_state.gui.position.fig,...
    'Name', 'Settings');

% Draw the title
settings_state.gui.title = uicontrol(settings_state.gui.fig,...
    'Units', 'pixels', 'Position', [20, 265, 120, 25],...
    'BackgroundColor', state.gui.bgcolor, 'FontSize', 14,...
    'Style', 'Text', 'String', 'GPSa Settings');

%% User's Studies

% Title
user = getenv('USER');
settings_state.gui.study_title = uicontrol(settings_state.gui.fig,...
    'Units', 'pixels', 'Position', [20, 235, 120, 20],...
    'BackgroundColor', state.gui.bgcolor, 'FontSize', 10,...
    'Style', 'Text', 'String', sprintf('%s''s Studies', user));

% Get the list of studies
files = dir(gps_presets('studyparameters'));
studies = {files.name};
studies = setdiff(studies, {'.', '..', 'GPS'});

% Draw the list
settings_state.gui.study_list = uicontrol(settings_state.gui.fig,...
    'Units', 'pixels', 'Position', [20, 110, 120, 120],...
    'BackgroundColor', state.gui.bgcolor, 'FontSize', 10,...
    'Style', 'Listbox', 'String', studies, 'Max', length(studies));

% Try to load the list of studies specified for this user
userstudies_filename = sprintf('%s/GPS/userstudies.mat', gps_presets('studyparameters'));

if(exist(userstudies_filename, 'file'))
    userstudies = load(userstudies_filename);
    
    if(isfield(userstudies, user))
        [~, ~, i_studies] = intersect(userstudies.(user), studies);
        if(~isempty(i_studies))
            set(settings_state.gui.study_list, 'Value', i_studies);
        end
    end
end % If the preset file exists

%% Subset

% Title
settings_state.gui.subset_title = uicontrol(settings_state.gui.fig,...
    'Units', 'pixels', 'Position', [20, 80, 120, 20],...
    'BackgroundColor', state.gui.bgcolor, 'FontSize', 10,...
    'Style', 'Text', 'String', 'Subset');

% Draw the subset write-in
settings_state.gui.subset = uicontrol(settings_state.gui.fig,...
    'Units', 'pixels', 'Position', [20, 55, 120, 20],...
    'BackgroundColor', state.gui.bgcolor, 'FontSize', 10,...
    'Style', 'Edit', 'String', state.subset);

%% Saving

% Draw the set button
settings_state.gui.set = uicontrol(settings_state.gui.fig,...
    'Units', 'pixels', 'Position', [60, 20, 40, 25],...
    'BackgroundColor', state.gui.bgcolor, 'FontSize', 14,...
    'Style', 'PushButton', 'String', 'Set',...
    'Callback', ['uiresume(' num2str(settings_state.gui.fig) ');']);

% After the set button has been pressed
uiwait(settings_state.gui.fig);

if(~ishghandle(settings_state.gui.fig))
    fprintf('Settings menu closed without saving changes\n');
else
    % Save the userstudies
    i_studies = get(settings_state.gui.study_list, 'Value');
    userstudies.(user) = studies(i_studies);
    save(userstudies_filename, '-struct', 'userstudies');
    
    % Save the settings to the gpsa_state
    state.subset = get(settings_state.gui.subset, 'String');
    gpsa_set(state);
    gpsa_init_studies;
    
    % Remove this figure
    delete(settings_state.gui.fig)
end

end % function
