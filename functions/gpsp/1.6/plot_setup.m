function plot_setup(GPSP_vars)
% Configures the grangerplotting GUI for startup
%
% Author: Conrad Nied
%
% Date Created: 2012.07.05 as function apart from GPS_grangerplot.m
% Last Modified: 2012.08.01
%
% Input: The structure you want to save and optionally the name of the
% structure you want to save
% Output: None
% 2012.10.11 - Loosely adapted to GPS1.7
% 2013.06.28 - Surface level changes to make it compatible with GPS1.8

% Choose default command line output for GPS_grangerplot
GPSP_vars.output = GPSP_vars.guifig;

%% Set up figures

% Determine Locations
position_screen        = get(0, 'ScreenSize');
position_guifig        = [1, position_screen(4) - 624, 270, 600];
position_datafig       = [1, 1, 300, 10];
position_brainfig      = [320, position_screen(4) - 667, 888, 666];
position_timecoursefig = [320, position_screen(4) - 667, 888, 666];

% Set GUI buttons
set(GPSP_vars.guifig, 'Units', 'Pixels');
set(GPSP_vars.guifig, 'Position', position_guifig)
set(GPSP_vars.feat_panel, 'Units', 'Pixels');
set(GPSP_vars.feat_panel, 'Position', [10 365 138 200])
% set(GPSP_vars.feat_display, 'Units', 'Pixels');
% set(GPSP_vars.feat_display, 'Position', [160 380 90 21])
% set(GPSP_vars.base_special, 'Units', 'Pixels');
% set(GPSP_vars.base_special, 'Position', [176 421 58 21])
% set(GPSP_vars.base_email_config, 'Units', 'Pixels');
% set(GPSP_vars.base_email_config, 'Position', [160 452 90 21])
% set(GPSP_vars.base_email, 'Units', 'Pixels');
% set(GPSP_vars.base_email, 'Position', [160 478 90 21])
% set(GPSP_vars.base_save, 'Units', 'Pixels');
% set(GPSP_vars.base_save, 'Position', [160 504 90 21])
% set(GPSP_vars.base_draw, 'Units', 'Pixels');
% set(GPSP_vars.base_draw, 'Position', [167 530 76 35])
% set(GPSP_vars.free_title_text, 'Units', 'Pixels');
% set(GPSP_vars.free_title_text, 'Position', [21 583 222 30])

% datafig, to save structures to
GPSP_vars.datafig = 6757000;
figure(GPSP_vars.datafig);
clf(GPSP_vars.datafig);
set(GPSP_vars.datafig, 'Menubar', 'none');
set(GPSP_vars.datafig, 'Toolbar', 'none');
set(GPSP_vars.datafig, 'Name', 'Data (GPS Plot)');
set(GPSP_vars.datafig, 'Numbertitle', 'off');
% title(gca, {'This figure contains data for GPS\_plot.', 'Do not close until you are done with GPS\_plot'});
set(GPSP_vars.datafig, 'Units', 'Pixels');
set(GPSP_vars.datafig, 'Position', position_datafig);

% timecoursefig, for displaying timecourse plots
GPSP_vars.display_timecoursefig = 6757002;
figure(GPSP_vars.display_timecoursefig);
set(GPSP_vars.display_timecoursefig, 'Name', 'Timecourses (GPS Plot)');
set(GPSP_vars.display_timecoursefig, 'Numbertitle', 'off');
set(GPSP_vars.display_timecoursefig, 'Units', 'Pixels');
set(GPSP_vars.display_timecoursefig, 'Position', position_timecoursefig);
GPSP_vars.display_timecourseaxes = gca;
set(GPSP_vars.display_timecourseaxes, 'Units', 'Normalized');
set(GPSP_vars.display_timecourseaxes, 'Position', [.1 .1 0.8 0.8]);

% brainfig, for displaying the brain
GPSP_vars.display_brainfig = 6757001;
figure(GPSP_vars.display_brainfig);
set(GPSP_vars.display_brainfig, 'Name', 'Brain (GPS Plot)');
set(GPSP_vars.display_brainfig, 'Numbertitle', 'off');
set(GPSP_vars.display_brainfig, 'Units', 'Pixels');
set(GPSP_vars.display_brainfig, 'Position', position_brainfig);
set(GPSP_vars.display_brainfig, 'Renderer', 'OpenGL');
GPSP_vars.display_brainaxes = gca;
set(GPSP_vars.display_brainaxes, 'Units', 'Normalized');
set(GPSP_vars.display_brainaxes, 'Position', [0.05 0.05 0.9 0.9]);

% Return to the GUI
figure(GPSP_vars.guifig);

gpsp_feat(GPSP_vars.feat_dataset, GPSP_vars);
return

%% Set preliminary data
GPSP_vars.dir = gps_presets('dir');
GPSP_vars.savedir = gps_presets('parameters');

% Populate List of Studies
studies = dir(GPSP_vars.savedir);
studies = {studies([studies.isdir]).name};
studies = setdiff(studies, {'.', '..', 'figures', 'status', 'labels', 'images', 'screenshots'});
set(GPSP_vars.data_study, 'String', studies);

% Presume first Study (unless specific)
if(strcmp(getenv('USER'), 'dgow') || strcmp(getenv('USER'), 'conrad') || strcmp(getenv('USER'), 'seppo'))
    i_study = find(strcmp('PTC3', studies));
    set(GPSP_vars.data_study, 'Value', i_study);
elseif(strcmp(getenv('USER'), 'vancelet')|| strcmp(getenv('USER'), 'bbolson')) 
    i_study = find(strcmp('SPhon', studies));
    set(GPSP_vars.data_study, 'Value', i_study);
else
    i_study = get(GPSP_vars.data_study, 'Value');
end
studies = get(GPSP_vars.data_study, 'String');
GPSP_vars.study = studies{i_study};

% Activate data loading tree of study-condition-set
plot_data_study(GPSP_vars);
GPSP_vars = guidata(GPSP_vars.guifig);

% Make the default frames
plot_frames(GPSP_vars);
GPSP_vars = guidata(GPSP_vars.guifig);

%% Set rest of GUI

% Enable the base_email button if the client already is configured
if(ispref('Internet') && ispref('Internet', 'SMTP_Username'))
    set(GPSP_vars.base_email, 'Enable', 'on');
end

% Remove Redundant Panels
% set(GPSP_vars.display_axes, 'Position', [271 15 730 550]);
plot_menus(GPSP_vars.guifig, GPSP_vars)

% Update GPSP_vars structure
guidata(GPSP_vars.guifig, GPSP_vars);

% UIWAIT makes GPS_grangerplot wait for user response (see UIRESUME)
% uiwait(GPSP_vars.figure1);

end % function