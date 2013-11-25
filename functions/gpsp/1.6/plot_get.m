function structure = plot_get(structname)
% Retrieves a structure from the GPS plot datafigure
%
% Author: Conrad Nied
%
% Date Created: 2012.07.05
% Last Modified: 2012.07.05
%
% Input: The name of the structure you want to fetch
% Output: The structure from the datafig

structure = getappdata(675700, structname);

end % function