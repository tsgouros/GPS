function varargout = gpsa_granger_functions
% Returns stage function information
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012-10-03 Created
% 2013-04-25 GPS1.8 Renamed subset routine to ROI Timecourses
% 2013-04-26 Reordered, added in averaging routine placeholders
% 2013-04-29 Changed menu for organization redesign
% 2013-07-09 Reorganized signifiance testing
% 2019-07-29 Added compute_zeros

function_list = {'Process ROIs', 'MNI Coordinates', 'ROI Timecourses', 'Consolidate', 'Compute Granger', 'Comp. Granger (zeros)', 'Null Hypotheses', 'Get Significance'};
function_tags = {'rois', 'mni', 'roitcs', 'consolidate', 'compute', 'compute_zeros', 'nullhypo', 'significance'};

varargout{1} = function_tags;
if(nargout == 2)
    varargout{2} = function_list;
end
        
end % function
