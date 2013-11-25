function varargout = gpse_parameter(varargin)
% Saves a structure to the GPS: Edit saving figure
%
% Author: Conrad Nied
%
% Changelog:
% 2012.09.19 - Created based on GPS 1.7 gpsa_parameter.m
% 2013.04.05 - For GPS 1.8, gets parameters folder from gps_presets
% 2013.04.25 - Saves parameters in the GPS gui if it exists and loads from
% there first

if (nargout == 1) % Fetching a parameter
    if(nargin == 1)
        state = gpse_get('state');
        parameter = varargin{1};
    else
        state = varargin{1};
        parameter = varargin{2};
    end
    
    % Get it from the parameter file
    filename = sprintf('%s/%s/%s.mat', gps_presets('parameters'), state.study, parameter);
    if(exist(filename, 'file'))
        varargout{1} = load(filename);
    else
        varargout{1} = [];
    end % If the file exists
else % Saving a parameter
    parameter = varargin{1};
    
    if(isfield(parameter, 'study'));
        % Determine the filename
        filename = sprintf('%s/%s/%s.mat', gps_presets('parameters'), parameter.study, parameter.name);
        
        % Save the file
        save(filename, '-struct', 'parameter');
    end
end % fetching or saving

end % function