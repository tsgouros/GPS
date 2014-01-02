function varargout = gpsa_parameter(varargin)
% Saves or loads study information to the GPS parameter directory
%
% Author: Alexander Conrad Nied (anied@cs.washington.edu)
%
% Changelog:
% 2012-09-17 Created based on GPS 1.6 plot_set.m
% 2012-09-18 Properly set logic tree and parameter loading
% 2012-09-19 Forgot to SAVE parameters
% 2012-10-05 Saving can handle inputting the state as well (first)
% 2013-04-05 For GPS 1.8, gets parameters folder from gps_presets
% 2013-04-25 Saves parameters in the GPS gui if it exists and loads from
% there first
% 2013-07-02 Removed study structure clauses :/ it was causing bugs
% 2014-01-02 GPS1.9 Creates a study directory if necessary

if (nargout == 1) % Fetching a parameter
    if(nargin == 1)
        state = gpsa_get;
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
    if(nargin == 1)
        parameter = varargin{1};
    else
        parameter = varargin{2};
    end
    
    % Make sure the study output directory exists
    direc = sprintf('%s/%s', gps_presets('parameters'), parameter.study);
    if(~exist(direc, 'dir'))
        mkdir(direc);
    end
    
    filename = sprintf('%s/%s.mat', direc, parameter.name);
    
    % Save the file
    save(filename, '-struct', 'parameter');
end

end % function