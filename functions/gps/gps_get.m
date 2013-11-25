function structure = gps_get(structname)
% Retrieves a structure from the GPS figure
%
% Author: Conrad Nied
%
% Input: The name of the structure you want to fetch
% Output: The structure from the GPSe guifig
%
% Changelog:
% 2013.04.25 - Created in GPS1.8 from gpse_get

% Set the structure name if the user leaves the input blank
if(~exist('structname', 'var'))
    structname = 'state';
end

% Get the structure from the figure's application data
if(ishghandle(6750000))
    structure = getappdata(6750000, structname);
else
    structure = [];
end

end % function