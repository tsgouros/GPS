function structure = gpsa_get(structname)
% Retrieves a structure from the GPS Analysis GUI
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Input: The name of the structure you want to fetch
% Output: The structure from the GPSa guifig
%
% Changelog:
% 2012.09.17 - Created based on GPS 1.6 plot_get.m
% 2012.09.18 - Provision for handle absence of figure
% 2012.09.19 - Add error provision and leaving input blank
% 2012.10.05 - Added provisions for a presumed state
% 2012.10.22 - Gets directory from presets
% 2013.07.02 - Gets figure number from gps_presets now

% Set the structure name if the user leaves the input blank
if(~exist('structname', 'var'))
    structname = 'state';
end

% Get the structure from the figure's application data
if(ishghandle(gps_presets('gpsafig')))
    structure = getappdata(gps_presets('gpsafig'), structname);
else
    if(strcmp(structname, 'state'))
        structure.dir = gps_presets('dir');
        structure.study = gps_presets('study');
    else
        error('Could not find %s', structname);
    end
end

end % function