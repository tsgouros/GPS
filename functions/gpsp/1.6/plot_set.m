function plot_set(structure, varargin)
% Saves a structure to the GPS plot datafigure
%
% Author: Conrad Nied
%
% Date Created: 2012.07.05
% Last Modified: 2012.07.05
%
% Input: The structure you want to save and optionally the name of the
% structure you want to save
% Output: None

if(nargin == 2)
    structname = varargin{1};
else
    if(isfield(structure, 'name'))
        structname = structure.name;
    else
        structname = 'struct';
    end
end

setappdata(675700, structname, structure);

end % function