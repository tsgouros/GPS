function varargout = gpsp_parameter(varargin)
% Saves(or gets) a structure to(from) the parameter directory for GPS:
% Plotting
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012-10-11 Created based on GPS 1.7 gpsr_parameter
% 2013-04-05 For GPS 1.8, gets parameters folder from gps_presets
% 2013-04-29 Saves parameters in the GPS gui if it exists and loads from
% there first
% 2013-07-14 Updated to new GPS1.8 interface

if (nargout == 1) % Fetching a parameter
    if(nargin == 1)
        state = gpsp_get;
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
    
    filename = sprintf('%s/%s/%s.mat', gps_presets('parameters'), parameter.study, parameter.name);
    
    % Save the file
    save(filename, '-struct', 'parameter');
end

end % function