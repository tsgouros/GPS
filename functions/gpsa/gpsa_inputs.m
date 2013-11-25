function [state, operation] = gpsa_inputs(vargin)
% Reads standard inputs for GPS: Analysis routines, a string and a state
% structure if possible
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012.10.03 - Created to simplify function starts

% Operation field, list of flags for what to return
%  c = conduct
%  p = report progress
%  t = report type

% For each argument inputted
for i_argin = 1:length(vargin)
    argument = vargin{i_argin};
    if(isstruct(argument))
        state = argument;
    elseif(ischar(argument))
        operation = argument;
    end
end % For each argument inputted

% Handle missing input values with defaults
if(~exist('state', 'var')); state = gpsa_get; end
if(~exist('operation', 'var'))
    if(isfield(state, 'operation'))
        operation = state.operation;
    else
        if(nargout == 1)
            operation = 'cp';
        else
            operation = 'c';
        end
    end % If operation is defined in the state
end % If we don't have the operation

end % function