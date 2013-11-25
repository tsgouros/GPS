function varargout = gpsr_parameter(varargin)
% Saves(or gets) a structure to(from) the parameter directory for GPSr
%
% Author: Conrad Nied
%
% Changelog:
% 2012.10.09 - Created based on GPS 1.7 gpsa_parameter
% 2013.04.05 - For GPS 1.8, gets parameters folder from gps_presets
% 2013.04.29 - Saves parameters in the GPS gui if it exists and loads from
% there first

if (nargout == 1) % Fetching a parameter
    if(nargin == 1)
        state = gpsr_get;
        parameter = varargin{1};
    else
        state = varargin{1};
        parameter = varargin{2};
    end
    
    % Try getting it from the gps figure
    studystructs = gps_get(state.study);
    if(~isempty(studystructs) && isfield(studystructs, parameter))
        varargout{1} = studystructs.(parameter);
    else % Otherwise get it from the parameter file
        filename = sprintf('%s/%s/%s.mat', gps_presets('parameters'), state.study, parameter);
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
    
    filename = sprintf('%s/%s/%s.mat', gps_presets('parameters'), parameter.study, parameter.name);
    
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