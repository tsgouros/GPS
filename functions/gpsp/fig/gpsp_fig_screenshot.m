function gpsp_fig_screenshot(varargin)
% Takes a screenshot of the state of the GUI and saves it to the images
% folder
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-08-09 Created as GPS1.8 gpsp_fig_screenshot

% folder = sprintf('%s/%s', gps_presets('imagedir'), datestr(now, 'yymmdd'));
% if(~exist(folder, 'dir')); mkdir(folder); end
% 
% filename = sprintf('%s/%s.png',...
%     folder, datestr(now, 'hhMMss'));%plot_image_filename(handles));

% Get the image
if(nargin == 1)
    fig = varargin{1};
else
    fig = gpsp_fig_surf;
end
frame = getframe(fig);

% Get the filename
[filename, folder] = uiputfile('~/Desktop/*.png');
filename = sprintf('%s/%s', folder, filename);

% Save the image
imwrite(frame.cdata, filename, 'png');

end