function gpsa_checkall(varargin)
% Sets the check boxes in the GPSa GUI
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.03 - Created

%% Handle inputs

% Get inputted inputs
for i_argin = 1:nargin
    argument = varargin{i_argin};
    if(isstruct(argument))
        state = argument;
    elseif(ischar(argument))
        area = argument;
    end
end % for all inputs

% Check for inputs that haven't been given
if(~exist('state', 'var')); state = gpsa_get; end
if(~exist('area', 'var')); area = 'f'; end

%% Check all or uncheck all

% Get the status of the batch check box
for i_batch = 12:-1:1
    checkbox = sprintf('%s%d_check', area, i_batch);
    if(isfield(state.gui, checkbox) && ishghandle(state.gui.(checkbox))) % the last checkbox is the batch one always
        new_boolean = get(state.gui.(checkbox), 'Value');
        break;
    end % if the checkbox exists
end % For all boxes, looking for the batch one

% Change the statuses of the group check boxes
for i = 1:(i_batch - 1)
    checkbox = sprintf('%s%d_check', area, i);
    if(isfield(state.gui, checkbox)) % the last checkbox is the batch one always
        set(state.gui.(checkbox), 'Value', new_boolean);
    end % if the checkbox exists
end % For all boxes

end % function