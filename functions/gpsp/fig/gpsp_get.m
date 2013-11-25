function structure = gpsp_get(structname)
% Retrieves a structure from the GPS: Plotting GUI
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Input: The name of the structure you want to fetch
% Output: The structure from the GPSp datafig
%
% Changelog:
% 2012-10-11 GPS1.7 Created based on gpsr_get
% 2013-07-14 Adapted to GPS1.8's new plotting GUI

% Set the structure name if the user leaves the input blank
if(~exist('structname', 'var'))
    structname = 'GPSp_state';
end

% Get the structure from the figure's application data
handle = gpsp_fig_data;
if(ishghandle(handle))
    if(isappdata(handle, structname))
        structure = getappdata(handle, structname);
    else
        structure = [];
    end
else
    error('Data figure not initialized');
end

end % function