function varargout = gpsa_mri_functions
% Returns stage function information
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.03 - Created
% 2012.10.08 - Added Average Surface maker
% 2013.06.28 - Removed brain2mat

function_list = {'Import', 'Find T1-MPRAGE', 'Organize', 'Build Surfaces', 'FS Average', 'Source Space', 'Setup Coreg', 'BE Model', 'BE Model to .fif', 'Average Surface'};
function_tags = {'import', 'findfirstmprage', 'orgmri', 'surf', 'fsave', 'srcspace', 'setupcoreg', 'bem', 'bemmne', 'avesurf'};

varargout{1} = function_tags;
if(nargout == 2)
    varargout{2} = function_list;
end
        
end % function