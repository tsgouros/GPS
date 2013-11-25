function varargout = gpsa_util_functions
% Returns stage function information
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.03 - Created

function_list = {'FS: TkMedit', 'Visualize BEM', 'mne_browse_raw', 'mne_analyze', 'GPS: ROIs', 'GPS: Plot'};
function_tags = {'tkmedit', 'bem', 'browse', 'analyze', 'rois', 'plot'};

varargout{1} = function_tags;
if(nargout == 2)
    varargout{2} = function_list;
end
        
end % function