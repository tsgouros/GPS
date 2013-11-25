function gpsa_set(structure, varargin)
% Saves a structure to the GPS: Analysis saving figure
%
% Author: Conrad Nied
%
% Input: The structure you want to save and optionally the name of the
% structure you want to save
% Output: None
%
% Changelog:
% 2012.09.17 - Created based on GPS 1.6 plot_set.m

if(nargin == 2)
    structname = varargin{1};
else
    if(isfield(structure, 'name'))
        structname = structure.name;
    else
        structname = 'struct';
    end
end

setappdata(6754000, structname, structure);

end % function