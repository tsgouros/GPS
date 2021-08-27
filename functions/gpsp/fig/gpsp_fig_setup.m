function gpsp_fig_setup
% Configures the GPS: Plotting graphical user interface
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012-07-05 as function apart from GPS_grangerplot.m
% 2012-08-01 Last change in GPS1.6
% 2012-10-11 Loosely adapted to GPS1.7
% 2013-06-28 Surface level changes to make it compatible with GPS1.8
% 2013-07-14 Changed to become gpsp_fig_setup, works in the new system
% 2013-08-12 Font customization

state = gpsp_get;

%% Set up figures

% Determine Locations
state.position.screen = get(0, 'ScreenSize');
state.position.guifig = [1, state.position.screen(4) - 700, 270, 600];

% Set GUI buttons
set(state.guifig, 'Units', 'Pixels');
set(state.guifig, 'Position', state.position.guifig)

% Set how to handle closing
set(state.guifig, 'CloseRequestFcn', 'gpsp_fig_closeall;');

% Start up the data holding figure
gpsp_fig_data;

% Return to the GUI
figure(state.guifig);

% Load the menus
gpsp_feat(state.feat_dataset, state);

%% Draw menu visuals
images = load('gpsp_images.mat');
set(state.feat_arrows, 'CData', images.feat_arrows);
set(state.feat_bubbles, 'CData', images.feat_bubbles);
set(state.feat_tcs, 'CData', images.feat_tcs);

% color_continuum = {'White', 'Grey', 'Gray', 'Black'};
% for i = 1:4
%     color = floor(gpsp_draw_colors(color_continuum{i}) * 255);
%     if(~sum(color)); lighten = ' color="ffffff"';
%     else lighten = '';
%     end
%     color_continuum{i} = sprintf('<html><span bgcolor="%02x%02x%02x"%s>%s</span></html>', color(1), color(2), color(3), lighten, color_continuum{i});
% end
% set(state.surf_bg, 'String', color_continuum);

fonts = listfonts;
set(state.tcs_font, 'String', fonts);
i_font = find(strcmp(fonts, 'Helvetica'));
if(~isempty(i_font)); set(state.tcs_font, 'Value', i_font); end

%% Set preliminary data
state.dir = gps_presets('dir');

% Populate List of Studies
studies = dir(gps_presets('studyparameters'));
studies = {studies([studies.isdir]).name};
studies = setdiff(studies, {'.', '..', 'figures', 'status', 'labels', 'images', 'screenshots', 'GPS'});
set(state.data_study, 'String', studies);

% Presume first Study (unless specific)
i_study = 1;
if(isfield(state, 'study'))
    i_study = find(strcmp(state.study, studies));
    if(isempty(i_study))
        i_study = 1;
    end
end
set(state.data_study, 'Value', i_study);
state.study = studies{i_study};

%% Set rest of GUI

% % Enable the base_email button if the client already is configured
% if(ispref('Internet') && ispref('Internet', 'SMTP_Username'))
%     set(state.base_email, 'Enable', 'on');
% end

% Update GPSP_vars structure
gpsp_set(state);
guidata(state.guifig, state);

%% Cascade

% Activate data loading tree of study-condition-set
gpsp_load_study;

end % function
