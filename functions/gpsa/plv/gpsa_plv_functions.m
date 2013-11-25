function varargout = gpsa_plv_functions
% Returns stage function information
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.03 - Created
% 2012.10.17 - Pluralized ROIs
% 2013.01.15 - Added high resolution routine
% 2013.04.24 - GPS1.8 commented out high res routine

% function_list = {'High Res Maps', 'Reference ROIs', 'Gather Trials', 'Compute PLV', 'Morphed .stc', 'Average Subject'};
% function_tags = {'hifi', 'rois', 'trials', 'compute', 'stcave', 'avesubj'};
function_list = {'Reference ROIs', 'Gather Trials', 'Emptyroom Trials', 'Compute PLV', 'Morphed .stc', 'Average Subject'};
function_tags = {'rois', 'trials', 'trials_emptyroom', 'compute', 'stcave', 'avesubj'};

varargout{1} = function_tags;
if(nargout == 2)
    varargout{2} = function_list;
end
        
end % function