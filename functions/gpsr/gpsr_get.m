function structure = gpsr_get(structname)
% Retrieves a structure from the GPS ROIs GUI
%
% Author: Conrad Nied
%
% Input: The name of the structure you want to fetch
% Output: The structure from the GPSa guifig
%
% Changelog:
% 2012.10.09 - Created based on gpsa_get
% 2013.05.31 - Updated for GPS1.8/GPSr

% Set the structure name if the user leaves the input blank
if(~exist('structname', 'var'))
    structname = 'state';
end

% Get the state from the GPSr-menu or other data from GPSr-data
if(strcmp(structname, 'state'))
    if(ishghandle(6752000))
        structure = getappdata(6752000, structname);
    else
        error('GPSr-menu is closed');
    end
else % Is other data
    % Get the structure from the data figure's application data
    if(ishghandle(6752100))
        structure = getappdata(6752100, structname);
    else
        error('GPSr-data figure does not exist');
    end
end

end % function