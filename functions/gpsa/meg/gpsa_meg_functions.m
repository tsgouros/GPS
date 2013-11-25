function varargout = gpsa_meg_functions
% Returns stage function information
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.03 - Created

function_list = {'Import', 'Extract Events', 'Process Events', 'Bad Channels', 'EOG Projections', 'Coregistration'};
function_tags = {'import', 'eveext', 'eveproc', 'bad', 'eog', 'coreg'};

varargout{1} = function_tags;
if(nargout == 2)
    varargout{2} = function_list;
end
        
end % function