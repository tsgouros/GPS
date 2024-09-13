function varargout = gpsa_mri_functions
% Returns stage function information
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.03 - Created
% 2012.10.08 - Added Average Surface maker
% 2013.06.28 - Removed brain2mat
% 2015.09.11 - put brain2mat back in. (-tsg noticed, 3/27/2019)
% 2019.01-03 - Added explicit pathname references to environment vars.  -tsg

%function_list = {'Import', 'Find T1-MPRAGE',  'Organize', 'Build Surfaces', 'FS Average', 'Source Space', 'Setup Coreg', 'BE Model', 'BE Model to .fif', 'Average Surface'};
%function_tags = {'import', 'findfirstmprage', 'orgmri',   'surf',           'fsave',      'srcspace',     'setupcoreg',  'bem',      'bemmne',           'avesurf'};
function_list = {'Import', 'Find T1-MPRAGE',  'Organize', 'Build Surfaces', 'FS Average', 'Source Space', 'Setup Coreg', 'BE Model', 'BE Model to .fif', 'brain2mat', 'Average Surface'};
function_tags = {'import', 'findfirstmprage', 'orgmri',   'surf',           'fsave',      'srcspace',     'setupcoreg',  'bem',      'bemmne',           'brain2mat', 'avesurf'};

varargout{1} = function_tags;
if(nargout == 2)
    varargout{2} = function_list;
end
        
end % function
