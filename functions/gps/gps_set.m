function gps_set(structure, varargin)
% Saves a structure to the GPS figure
%
% Author: Conrad Nied
%
% Input: The structure you want to save and optionally the name of the
% structure you want to save
% Output: None
%
% Changelog:
% 2013.04.25 - Created in GPS1.8 from gpse_get

if(nargin == 2)
    structname = varargin{1};
else
    if(isfield(structure, 'name'))
        structname = structure.name;
    else
        structname = 'struct';
    end
end

if(ishghandle(6750000))
    setappdata(6750000, structname, structure);
end

end % function