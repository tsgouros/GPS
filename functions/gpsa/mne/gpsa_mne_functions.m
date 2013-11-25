function varargout = gpsa_mne_functions
% Returns stage function information
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012.10.03 - Created

function_list = {'Average Waves', 'Forward Solution', 'Inverse Solution', 'Evoked Trials', 'Make .stc', 'Morphed .stc', 'Average Subject'};
function_tags = {'avewaves', 'fwd', 'inv', 'evoked', 'stc', 'stcave', 'avesubj'};

varargout{1} = function_tags;
if(nargout == 2)
    varargout{2} = function_list;
end
        
end % function