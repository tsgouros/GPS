function varargout = gpsa_parameter(varargin)
% Saves or loads study information to the GPS parameter directory
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012.09.17 - Created based on GPS 1.6 plot_set.m
% 2012.09.18 - Properly set logic tree and parameter loading
% 2012.09.19 - Forgot to SAVE parameters
% 2012.10.05 - Saving can handle inputting the state as well (first)
% 2013.04.05 - For GPS 1.8, gets parameters folder from gps_presets
% 2013.04.25 - Saves parameters in the GPS gui if it exists and loads from
% there first

if (nargout == 1) % Fetching a parameter
    if(nargin == 1)
        state = gpsa_get;
        parameter = varargin{1};
    else
        state = varargin{1};
        parameter = varargin{2};
    end
    
    % Try getting it from the gps figure
    studystructs = gpsa_get(state.study);
    if(~isempty(studystructs) && isfield(studystructs, parameter))
        varargout{1} = studystructs.(parameter);
    else % Otherwise get it from the parameter file
        filename = sprintf('%s/%s/%s.mat', gps_presets('studyparameters'), state.study, parameter);
        if(exist(filename, 'file'))
            varargout{1} = load(filename);
        
            % And save it to the gps figure if possible to keep it in the ram
            if(~isfield(studystructs, 'name'))
                studystructs.name = state.study;
            end
            studystructs.(parameter) = varargout{1};
            gps_set(studystructs);
        else
            varargout{1} = [];
        end % If the file exists
    end
else % Saving a parameter
    if(nargin == 1)
        parameter = varargin{1};
    else
        parameter = varargin{2};
    end
    
    filename = sprintf('%s/%s/%s.mat', gps_presets('studyparameters'), parameter.study, parameter.name);
    
    % Save the file
    save(filename, '-struct', 'parameter');
    
    % And save it to the gps figure if possible to keep it in the ram
    studystructs = gps_get(parameter.study);
    if(~isfield(studystructs, 'name'))
        studystructs.name = parameter.study;
    end
    studystructs.(parameter.name) = parameter;
    gps_set(studystructs);
end

end % function
