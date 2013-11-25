function structure = gpse_get(structname)
% Retrieves a structure from the GPS Edit GUI
%
% Author: Conrad Nied
%
% Input: The name of the structure you want to fetch
% Output: The structure from the GPSe guifig
%
% Changelog:
% 2012.09.19 - Created from GPS1.7 gpsa_get
% 2012.10.07 - Defaults to the state structure

% Set the structure name if the user leaves the input blank
if(~exist('structname', 'var'))
    structname = 'state';
end

% Get the structure from the figure's application data
if(ishghandle(6753000))
    structure = getappdata(6753000, structname);
elseif(ishghandle(6754000)) % Try GPSa if GPSe isn't loaded
    structure = getappdata(6754000, structname);
else
    structure = [];
end

end % function