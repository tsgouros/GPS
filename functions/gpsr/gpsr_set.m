function gpsr_set(structure)
% Saves a structure to the GPS: Analysis saving figure
%
% Author: Conrad Nied
%
% Input: The structure you want to save and optionally the name of the
% structure you want to save
% Output: None
%
% Changelog:
% 2012.10.09 - Created based on GPS 1.7 gpsa_set.m
% 2013.05.31 - Updated for GPS1.8/GPSr

% Set the state in the GPSr-menu or other data in GPSr-data
if(strcmp(structure.name, 'state'))
    if(ishghandle(6752000))
        setappdata(6752000, structure.name, structure);
    else
        error('GPSr-menu is closed');
    end
else % Is other data
    % Get the structure from the data figure's application data
    if(ishghandle(6752100))
        setappdata(6752100, structure.name, structure);
    else
        error('GPSr-data figure does not exist');
    end
end

end % function